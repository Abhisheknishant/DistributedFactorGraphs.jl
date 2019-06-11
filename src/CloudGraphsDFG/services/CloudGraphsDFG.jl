"""
    $(SIGNATURES)
Create a new CloudGraphs-based DFG factor graph using a Neo4j.Connection.
"""
function CloudGraphsDFG(neo4jConnection::Neo4j.Connection, userId::String, robotId::String, sessionId::String, encodePackedTypeFunc, getPackedTypeFunc, decodePackedTypeFunc; description::String="CloudGraphs DFG", solverParams::Any=nothing)
    graph = Neo4j.getgraph(neo4jConnection)
    neo4jInstance = Neo4jInstance(neo4jConnection, graph)
    return CloudGraphsDFG(neo4jInstance, description, userId, robotId, sessionId, encodePackedTypeFunc, getPackedTypeFunc, decodePackedTypeFunc, Dict{Symbol, Int64}(), Dict{Symbol, DFGVariable}(), Dict{Symbol, DFGFactor}(), Symbol[], solverParams)
end
"""
    $(SIGNATURES)
Create a new CloudGraphs-based DFG factor graph by specifying the Neo4j connection information.
"""
function CloudGraphsDFG(host::String, port::Int, dbUser::String, dbPassword::String, userId::String, robotId::String, sessionId::String, encodePackedTypeFunc, getPackedTypeFunc, decodePackedTypeFunc; description::String="CloudGraphs DFG", solverParams::Any=nothing)
    neo4jConnection = Neo4j.Connection(host, port=port, user=dbUser, password=dbPassword);
    return CloudGraphsDFG(neo4jConnection, userId, robotId, sessionId, encodePackedTypeFunc, getPackedTypeFunc, decodePackedTypeFunc, description=description, solverParams=solverParams)
end

# Accessors
getLabelDict(dfg::CloudGraphsDFG) = dfg.labelDict
getDescription(dfg::CloudGraphsDFG) = dfg.description
setDescription(dfg::CloudGraphsDFG, description::String) = dfg.description = description
getAddHistory(dfg::CloudGraphsDFG) = dfg.addHistory
getSolverParams(dfg::CloudGraphsDFG) = dfg.solverParams
setSolverParams(dfg::CloudGraphsDFG, solverParams::Any) = dfg.solverParams = solverParams

"""
    $(SIGNATURES)
True if the variable or factor exists in the graph.
"""
function exists(dfg::CloudGraphsDFG, nId::Symbol)
    # If in the dictionary, then shortcut return true
    haskey(dfg.labelDict, nId) && return true
    # Otherwise try get it
    nodeId = _tryGetNeoNodeIdFromNodeLabel(dfg.neo4jInstance, dfg.userId, dfg.robotId, dfg.sessionId, nId)
    if nodeId != nothing
        push!(dfg.labelDict, nId=>nodeId)
        return true
    end
    return false
end
function exists(dfg::CloudGraphsDFG, node::N) where N <: DFGNode
    return exists(dfg, node.label)
end


"""
    $(SIGNATURES)
Add a DFGVariable to a DFG.
"""
function addVariable!(dfg::CloudGraphsDFG, variable::DFGVariable)::Bool
    if haskey(dfg.labelDict, variable.label) || exists(dfg, variable) # It's in our local cache or in DB already
        error("Variable '$(variable.label)' already exists in the factor graph")
    end
    props = Dict{String, Any}()
    props["label"] = string(variable.label)
    props["timestamp"] = string(variable.timestamp)
    props["tags"] = JSON2.write(variable.tags)
    props["estimateDict"] = JSON2.write(variable.estimateDict)
    props["solverDataDict"] = JSON2.write(Dict(keys(variable.solverDataDict) .=> map(vnd -> pack(dfg, vnd), values(variable.solverDataDict))))
    props["smallData"] = JSON2.write(variable.smallData)
    props["ready"] = variable.ready
    props["backendset"] = variable.backendset
    # Don't handle big data at the moment.

    neo4jNode = Neo4j.createnode(dfg.neo4jInstance.graph, props);
    variable._internalId = neo4jNode.id
    Neo4j.updatenodelabels(neo4jNode, union([string(variable.label), "VARIABLE", dfg.userId, dfg.robotId, dfg.sessionId], variable.tags))

    # Graphs.add_vertex!(dfg.g, v)
    push!(dfg.labelDict, variable.label=>variable._internalId)
    push!(dfg.variableCache, variable.label=>variable)
    # Track insertion
    push!(dfg.addHistory, variable.label)

    return true
end

# """
#     $(SIGNATURES)
# Add a DFGFactor to a DFG.
# """
# function addFactor!(dfg::CloudGraphsDFG, variables::Vector{DFGVariable}, factor::DFGFactor)::Bool
#     if haskey(dfg.labelDict, factor.label)
#         error("Factor '$(factor.label)' already exists in the factor graph")
#     end
#     for v in variables
#         if !(v.label in keys(dfg.labelDict))
#             error("Variable '$(v.label)' not found in graph when creating Factor '$(factor.label)'")
#         end
#     end
#     dfg.nodeCounter += 1
#     factor._internalId = dfg.nodeCounter
#     factor._variableOrderSymbols = map(v->v.label, variables)
#     fNode = GraphsNode(dfg.nodeCounter, factor)
#     f = Graphs.add_vertex!(dfg.g, fNode)
#     # Add index
#     push!(dfg.labelDict, factor.label=>factor._internalId)
#     # Add the edges...
#     for variable in variables
#         v = dfg.g.vertices[variable._internalId]
#         edge = Graphs.make_edge(dfg.g, v, f)
#         Graphs.add_edge!(dfg.g, edge)
#     end
#     # Track insertion
#     push!(dfg.addHistory, factor.label)
#
#     return true
# end

"""
    $(SIGNATURES)
Get a DFGVariable from a DFG using its underlying integer ID.
"""
function getVariable(dfg::CloudGraphsDFG, variableId::Int64)::DFGVariable
    props = getnodeproperties(dfg.neo4jInstance.graph, variableId)
    # Time to do deserialization
    # props["label"] = Symbol(variable.label)
    timestamp = DateTime(props["timestamp"])
    tags =  JSON2.read(props["tags"], Vector{Symbol})
    estimateDict = JSON2.read(props["estimateDict"], Dict{Symbol, VariableEstimate})
    smallData = nothing
    smallData = JSON2.read(props["smallData"], Dict{String, String})

    packed = JSON2.read(props["solverDataDict"], Dict{String, PackedVariableNodeData})
    solverData = Dict(Symbol.(keys(packed)) .=> map(p -> unpack(dfg, p), values(packed)))

    # Rebuild DFGVariable
    variable = DFGVariable(Symbol(props["label"]), variableId)
    variable.timestamp = timestamp
    variable.tags = tags
    variable.estimateDict = estimateDict
    variable.solverDataDict = solverData
    variable.smallData = smallData
    variable.ready = props["ready"]
    variable.backendset = props["backendset"]

    # Add to cache
    push!(dfg.variableCache, variable.label=>variable)

    return variable
end


"""
    $(SIGNATURES)
Get a DFGVariable from a DFG using its label.
"""
function getVariable(dfg::CloudGraphsDFG, label::Union{Symbol, String}, skipCache::Bool=false)::DFGVariable
    if typeof(label) == String
        label = Symbol(label)
    end
    !skipCache && haskey(dfg.variableCache, label) && return dfg.variableCache[label]
    # Else try get it
    nodeId = _tryGetNeoNodeIdFromNodeLabel(dfg.neo4jInstance, dfg.userId, dfg.robotId, dfg.sessionId, label)
    if nodeId == nothing
        error("Unable to retrieve the ID for variable '$label'. Please check your connection to the database and that the variable exists.")
    end

    return getVariable(dfg, nodeId)
end

#
# """
#     $(SIGNATURES)
# Get a DFGFactor from a DFG using its underlying integer ID.
# """
# function getFactor(dfg::CloudGraphsDFG, factorId::Int64)::DFGFactor
#     @warn "This may be slow, rather use by getFactor(dfg, label)"
#     #TODO: This may be slow (O(n)), can we make it better?
#     if !(factorId in values(dfg.labelDict))
#         error("Factor ID '$(factorId)' does not exist in the factor graph")
#     end
#     return dfg.g.vertices[factorId].dfgNode
# end
#
# """
#     $(SIGNATURES)
# Get a DFGFactor from a DFG using its label.
# """
# function getFactor(dfg::CloudGraphsDFG, label::Union{Symbol, String})::DFGFactor
#     if typeof(label) == String
#         label = Symbol(label)
#     end
#     if !haskey(dfg.labelDict, label)
#         error("Factor label '$(label)' does not exist in the factor graph")
#     end
#     return dfg.g.vertices[dfg.labelDict[label]].dfgNode
# end

"""
    $(SIGNATURES)
Update a complete DFGVariable in the DFG.
"""
function updateVariable!(dfg::CloudGraphsDFG, variable::DFGVariable)::DFGVariable
    if !exists(dfg, variable)
        @warn "Variable '$(variable.label)' doesn't exist in the graph, so adding it."
        addVariable(dfg, variable)
    else
        nodeId = _tryGetNeoNodeIdFromNodeLabel(dfg.neo4jInstance, dfg.userId, dfg.robotId, dfg.sessionId, variable.label)
        neo4jNode = Neo4j.getnode(dfg.neo4jInstance.graph, nodeId)
        props = getnodeproperties(dfg.neo4jInstance.graph, nodeId)

        props["label"] = string(variable.label)
        props["timestamp"] = string(variable.timestamp)
        props["tags"] = JSON2.write(variable.tags)
        props["estimateDict"] = JSON2.write(variable.estimateDict)
        props["solverDataDict"] = JSON2.write(Dict(keys(variable.solverDataDict) .=> map(vnd -> pack(dfg, vnd), values(variable.solverDataDict))))
        props["smallData"] = JSON2.write(variable.smallData)
        props["ready"] = variable.ready
        props["backendset"] = variable.backendset
        # Don't handle big data at the moment.
        Neo4j.updatenodeproperties(neo4jNode, props)
        Neo4j.updatenodelabels(neo4jNode, union([string(variable.label), "VARIABLE", dfg.userId, dfg.robotId, dfg.sessionId], variable.tags))
    end
    return variable
end

# """
#     $(SIGNATURES)
# Update a complete DFGFactor in the DFG.
# """
# function updateFactor!(dfg::CloudGraphsDFG, factor::DFGFactor)::DFGFactor
#     if !haskey(dfg.labelDict, factor.label)
#         error("Factor label '$(factor.label)' does not exist in the factor graph")
#     end
#     dfg.g.vertices[dfg.labelDict[factor.label]].dfgNode = factor
#     return factor
# end
#
"""
    $(SIGNATURES)
Delete a DFGVariable from the DFG using its label.
"""
function deleteVariable!(dfg::CloudGraphsDFG, label::Symbol)::DFGVariable
    variable = nothing
    if haskey(dfg.variableCache, label)
        variable = dfg.variableCache[label]
    else
        # Else try get it
        variable = getVariable(dfg, label)
    end
    if variable == nothing
        error("Unable to retrieve the ID for variable '$label'. Please check your connection to the database and that the variable exists.")
    end

    # Perform detach+deletion
    _getNeoNodesFromCyphonQuery(dfg.neo4jInstance, "(node) where id(node)=$(variable._internalId) detach delete node ")

    # Clearing history
    dfg.addHistory = setdiff(dfg.addHistory, [label])
    haskey(dfg.variableCache, label) && delete!(dfg.variableCache, label)
    haskey(dfg.labelDict, label) && delete!(dfg.labelDict, label)
    return variable
end
#
# #Alias
# """
#     $(SIGNATURES)
# Delete a referenced DFGVariable from the DFG.
# """
# deleteVariable!(dfg::CloudGraphsDFG, variable::DFGVariable)::DFGVariable = deleteVariable(dfg, variable.label)
#
# """
#     $(SIGNATURES)
# Delete a DFGFactor from the DFG using its label.
# """
# function deleteFactor!(dfg::CloudGraphsDFG, label::Symbol)::DFGFactor
#     if !haskey(dfg.labelDict, label)
#         error("Factor label '$(label)' does not exist in the factor graph")
#     end
#     factor = dfg.g.vertices[dfg.labelDict[label]].dfgNode
#     delete_vertex!(dfg.g.vertices[dfg.labelDict[label]], dfg.g)
#     delete!(dfg.labelDict, label)
#     return factor
# end
#
# # Alias
# """
#     $(SIGNATURES)
# Delete the referened DFGFactor from the DFG.
# """
# deleteFactor!(dfg::CloudGraphsDFG, factor::DFGFactor)::DFGFactor = deleteFactor!(dfg, factor.label)
#
# # # Returns a flat vector of the vertices, keyed by ID.
# # # Assuming only variables here for now - think maybe not, should be variables+factors?
# """
#     $(SIGNATURES)
# List the DFGVariables in the DFG.
# Optionally specify a label regular expression to retrieves a subset of the variables.
# """
# function ls(dfg::CloudGraphsDFG, regexFilter::Union{Nothing, Regex}=nothing)::Vector{DFGVariable}
#     variables = map(v -> v.dfgNode, filter(n -> n.dfgNode isa DFGVariable, vertices(dfg.g)))
#     if regexFilter != nothing
#         variables = filter(v -> occursin(regexFilter, String(v.label)), variables)
#     end
#     return variables
# end
#
# # Alias
# """
#     $(SIGNATURES)
# List the DFGVariables in the DFG.
# Optionally specify a label regular expression to retrieves a subset of the variables.
# """
# getVariables(dfg::CloudGraphsDFG, regexFilter::Union{Nothing, Regex}=nothing)::Vector{DFGVariable} = ls(dfg, regexFilter)
#
# """
#     $(SIGNATURES)
# Get a list of IDs of the DFGVariables in the DFG.
# Optionally specify a label regular expression to retrieves a subset of the variables.
# """
# getVariableIds(dfg::CloudGraphsDFG, regexFilter::Union{Nothing, Regex}=nothing)::Vector{Symbol} = map(v -> v.label, ls(dfg, regexFilter))
#
# """
#     $(SIGNATURES)
# List the DFGFactors in the DFG.
# Optionally specify a label regular expression to retrieves a subset of the factors.
# """
# function lsf(dfg::CloudGraphsDFG, regexFilter::Union{Nothing, Regex}=nothing)::Vector{DFGFactor}
#     factors = map(v -> v.dfgNode, filter(n -> n.dfgNode isa DFGFactor, vertices(dfg.g)))
#     if regexFilter != nothing
#         factors = filter(f -> occursin(regexFilter, String(f.label)), factors)
#     end
#     return factors
# end
# function lsf(dfg::CloudGraphsDFG, label::Symbol)::Vector{Symbol}
#   return GraphsJl.getNeighbors(dfg, label)
# end
#
# # Alias
# """
#     $(SIGNATURES)
# List the DFGFactors in the DFG.
# Optionally specify a label regular expression to retrieves a subset of the factors.
# """
# getFactors(dfg::CloudGraphsDFG, regexFilter::Union{Nothing, Regex}=nothing)::Vector{DFGFactor} = lsf(dfg, regexFilter)
#
# """
#     $(SIGNATURES)
# Get a list of the IDs of the DFGFactors in the DFG.
# Optionally specify a label regular expression to retrieves a subset of the factors.
# """
# getFactorIds(dfg::CloudGraphsDFG, regexFilter::Union{Nothing, Regex}=nothing)::Vector{Symbol} = map(f -> f.label, lsf(dfg, regexFilter))
#
# """
#     $(SIGNATURES)
# Checks if the graph is fully connected, returns true if so.
# """
# function isFullyConnected(dfg::CloudGraphsDFG)::Bool
#     return length(connected_components(dfg.g)) == 1
# end
#
# #Alias
# """
#     $(SIGNATURES)
# Checks if the graph is not fully connected, returns true if it is not contiguous.
# """
# hasOrphans(dfg::CloudGraphsDFG)::Bool = !isFullyConnected(dfg)
#
# """
#     $(SIGNATURES)
# Retrieve a list of labels of the immediate neighbors around a given variable or factor.
# """
# function getNeighbors(dfg::CloudGraphsDFG, node::T; ready::Union{Nothing, Int}=nothing, backendset::Union{Nothing, Int}=nothing)::Vector{Symbol}  where T <: DFGNode
#     if !haskey(dfg.labelDict, node.label)
#         error("Variable/factor with label '$(node.label)' does not exist in the factor graph")
#     end
#     vert = dfg.g.vertices[dfg.labelDict[node.label]]
#     neighbors = in_neighbors(vert, dfg.g) #Don't use out_neighbors! It enforces directiveness even if we don't want it
#     # Additional filtering
#     neighbors = ready != nothing ? filter(v -> v.ready == ready, neighbors) : neighbors
#     neighbors = backendset != nothing ? filter(v -> v.backendset == backendset, neighbors) : neighbors
#     # Variable sorting (order is important)
#     if node isa DFGFactor
#         order = intersect(node._variableOrderSymbols, map(v->v.dfgNode.label, neighbors))
#         return order
#     end
#
#     return map(n -> n.dfgNode.label, neighbors)
# end
# """
#     $(SIGNATURES)
# Retrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.
# """
# function getNeighbors(dfg::CloudGraphsDFG, label::Symbol; ready::Union{Nothing, Int}=nothing, backendset::Union{Nothing, Int}=nothing)::Vector{Symbol}  where T <: DFGNode
#     if !haskey(dfg.labelDict, label)
#         error("Variable/factor with label '$(label)' does not exist in the factor graph")
#     end
#     vert = dfg.g.vertices[dfg.labelDict[label]]
#     neighbors = in_neighbors(vert, dfg.g) #Don't use out_neighbors! It enforces directiveness even if we don't want it
#     # Additional filtering
#     neighbors = ready != nothing ? filter(v -> v.ready == ready, neighbors) : neighbors
#     neighbors = backendset != nothing ? filter(v -> v.backendset == backendset, neighbors) : neighbors
#     # Variable sorting when using a factor (function order is important)
#     if vert.dfgNode isa DFGFactor
#         vert.dfgNode._variableOrderSymbols
#         order = intersect(vert.dfgNode._variableOrderSymbols, map(v->v.dfgNode.label, neighbors))
#         return order
#     end
#
#     return map(n -> n.dfgNode.label, neighbors)
# end
#
# # Aliases
# """
#     $(SIGNATURES)
# Retrieve a list of labels of the immediate neighbors around a given variable or factor.
# """
# function ls(dfg::CloudGraphsDFG, node::T)::Vector{Symbol} where T <: DFGNode
#     return getNeighbors(dfg, node)
# end
# """
#     $(SIGNATURES)
# Retrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.
# """
# function ls(dfg::CloudGraphsDFG, label::Symbol)::Vector{Symbol} where T <: DFGNode
#     return getNeighbors(dfg, label)
# end
#
# function _copyIntoGraph!(sourceDFG::CloudGraphsDFG, destDFG::CloudGraphsDFG, variableFactorLabels::Vector{Symbol}, includeOrphanFactors::Bool=false)::Nothing
#     # Split into variables and factors
#     verts = map(id -> sourceDFG.g.vertices[sourceDFG.labelDict[id]], variableFactorLabels)
#     sourceVariables = filter(n -> n.dfgNode isa DFGVariable, verts)
#     sourceFactors = filter(n -> n.dfgNode isa DFGFactor, verts)
#
#     # Now we have to add all variables first,
#     for variable in sourceVariables
#         if !haskey(destDFG.labelDict, variable.dfgNode.label)
#             addVariable!(destDFG, deepcopy(variable.dfgNode))
#         end
#     end
#     # And then all factors to the destDFG.
#     for factor in sourceFactors
#         if !haskey(destDFG.labelDict, factor.dfgNode.label)
#             # Get the original factor variables (we need them to create it)
#             variables = in_neighbors(factor, sourceDFG.g)
#             # Find the labels and associated variables in our new subgraph
#             factVariables = DFGVariable[]
#             for variable in variables
#                 if haskey(destDFG.labelDict, variable.dfgNode.label)
#                     push!(factVariables, getVariable(destDFG, variable.dfgNode.label))
#                     #otherwise ignore
#                 end
#             end
#
#             # Only if we have all of them should we add it (otherwise strange things may happen on evaluation)
#             if includeOrphanFactors || length(factVariables) == length(variables)
#                 addFactor!(destDFG, factVariables, deepcopy(factor.dfgNode))
#             end
#         end
#     end
#     return nothing
# end
#
# """
#     $(SIGNATURES)
# Retrieve a deep subgraph copy around a given variable or factor.
# Optionally provide a distance to specify the number of edges should be followed.
# Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created.
# Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.
# """
# function getSubgraphAroundNode(dfg::CloudGraphsDFG, node::T, distance::Int64=1, includeOrphanFactors::Bool=false, addToDFG::CloudGraphsDFG=CloudGraphsDFG())::CloudGraphsDFG where T <: DFGNode
#     if !haskey(dfg.labelDict, node.label)
#         error("Variable/factor with label '$(node.label)' does not exist in the factor graph")
#     end
#
#     # Build a list of all unique neighbors inside 'distance'
#     neighborList = Dict{Symbol, Any}()
#     push!(neighborList, node.label => dfg.g.vertices[dfg.labelDict[node.label]])
#     curList = Dict{Symbol, Any}(node.label => dfg.g.vertices[dfg.labelDict[node.label]])
#     for dist in 1:distance
#         newNeighbors = Dict{Symbol, Any}()
#         for (key, node) in curList
#             neighbors = in_neighbors(node, dfg.g) #Don't use out_neighbors! It enforces directiveness even if we don't want it
#             for neighbor in neighbors
#                 if !haskey(neighborList, neighbor.dfgNode.label)
#                     push!(neighborList, neighbor.dfgNode.label => neighbor)
#                     push!(newNeighbors, neighbor.dfgNode.label => neighbor)
#                 end
#             end
#         end
#         curList = newNeighbors
#     end
#
#     # Copy the section of graph we want
#     _copyIntoGraph!(dfg, addToDFG, collect(keys(neighborList)), includeOrphanFactors)
#     return addToDFG
# end
#
# """
#     $(SIGNATURES)
# Get a deep subgraph copy from the DFG given a list of variables and factors.
# Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created.
# Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.
# """
# function getSubgraph(dfg::CloudGraphsDFG, variableFactorLabels::Vector{Symbol}, includeOrphanFactors::Bool=false, addToDFG::CloudGraphsDFG=CloudGraphsDFG())::CloudGraphsDFG
#     for label in variableFactorLabels
#         if !haskey(dfg.labelDict, label)
#             error("Variable/factor with label '$(label)' does not exist in the factor graph")
#         end
#     end
#
#     _copyIntoGraph!(dfg, addToDFG, variableFactorLabels, includeOrphanFactors)
#     return addToDFG
# end
#
# """
#     $(SIGNATURES)
# Get an adjacency matrix for the DFG, returned as a Matrix{Union{Nothing, Symbol}}.
# Rows are all factors, columns are all variables, and each cell contains either nothing or the symbol of the relating factor.
# The first row and first column are factor and variable headings respectively.
# """
# function getAdjacencyMatrix(dfg::CloudGraphsDFG)::Matrix{Union{Nothing, Symbol}}
#     varLabels = sort(map(v->v.label, getVariables(dfg)))
#     factLabels = sort(map(f->f.label, getFactors(dfg)))
#     vDict = Dict(varLabels .=> [1:length(varLabels)...].+1)
#
#     adjMat = Matrix{Union{Nothing, Symbol}}(nothing, length(factLabels)+1, length(varLabels)+1)
#     # Set row/col headings
#     adjMat[2:end, 1] = factLabels
#     adjMat[1, 2:end] = varLabels
#     for (fIndex, factLabel) in enumerate(factLabels)
#         factVars = getNeighbors(dfg, getFactor(dfg, factLabel))
#         map(vLabel -> adjMat[fIndex+1,vDict[vLabel]] = factLabel, factVars)
#     end
#     return adjMat
# end
#
# """
#     $(SIGNATURES)
# Produces a dot-format of the graph for visualization.
# """
# function toDot(dfg::CloudGraphsDFG)::String
#     m = PipeBuffer()
#     write(m,Graphs.to_dot(dfg.g))
#     data = take!(m)
#     close(m)
#     return String(data)
# end
#
# """
#     $(SIGNATURES)
# Produces a dot file of the graph for visualization.
# Download XDot to see the data
#
# Note
# - Default location "/tmp/dfg.dot" -- MIGHT BE REMOVED
# - Can be viewed with the `xdot` system application.
# - Based on graphviz.org
# """
# function toDotFile(dfg::CloudGraphsDFG, fileName::String="/tmp/dfg.dot")::Nothing
#     open(fileName, "w") do fid
#         write(fid,Graphs.to_dot(dfg.g))
#     end
#     return nothing
# end
#
# function __init__()
#     @require DataFrames="a93c6f00-e57d-5684-b7b6-d8193f3e46c0" begin
#         if isdefined(Main, :DataFrames)
#             """
#                 $(SIGNATURES)
#             Get an adjacency matrix for the DFG as a DataFrame.
#             Rows are all factors, columns are all variables, and each cell contains either nothing or the symbol of the relating factor.
#             The first column is the factor headings.
#             """
#             function getAdjacencyMatrixDataFrame(dfg::CloudGraphsDFG)::Main.DataFrames.DataFrame
#                 varLabels = sort(map(v->v.label, getVariables(dfg)))
#                 factLabels = sort(map(f->f.label, getFactors(dfg)))
#                 adjDf = DataFrames.DataFrame(:Factor => Union{Missing, Symbol}[])
#                 for varLabel in varLabels
#                     adjDf[varLabel] = Union{Missing, Symbol}[]
#                 end
#                 for (i, factLabel) in enumerate(factLabels)
#                     push!(adjDf, [factLabel, DataFrames.missings(length(varLabels))...])
#                     factVars = getNeighbors(dfg, getFactor(dfg, factLabel))
#                     map(vLabel -> adjDf[vLabel][i] = factLabel, factVars)
#                 end
#                 return adjDf
#             end
#         end
#     end
# end
