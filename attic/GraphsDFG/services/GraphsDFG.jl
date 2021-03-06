
# For visualization
import Graphs: attributes, vertex_index
# Export attributes, these are enumerates as properties for the variables and factors
# REF: http://www.graphviz.org/documentation/
function attributes(v::GraphsNode, g::T)::AttributeDict where T <:GenericIncidenceList
    AttributeDict(
        "label" => v.dfgNode.label,
        "color" => v.dfgNode isa DFGVariable ? "red" : "blue",
        "shape" => v.dfgNode isa DFGVariable ? "ellipse" : "box",
        "fillcolor" => v.dfgNode isa DFGVariable ? "red" : "blue"
        )
end

# This is insanely important - if we don't provide a valid index, the edges don't work correctly.
vertex_index(v::GraphsNode) = v.index

# Accessors
# getLabelDict(dfg::GraphsDFG) = dfg.labelDict
# getDescription(dfg::GraphsDFG) = dfg.description
# setDescription(dfg::GraphsDFG, description::String) = dfg.description = description
# getAddHistory(dfg::GraphsDFG) = dfg.addHistory
# getSolverParams(dfg::GraphsDFG) = dfg.solverParams
# function setSolverParams(dfg::GraphsDFG, solverParams::T) where T <: AbstractParams
#     dfg.solverParams = solverParams
# end

"""
    $(SIGNATURES)
Gets an empty and unique CloudGraphsDFG derived from an existing DFG.
"""
function _getDuplicatedEmptyDFG(dfg::GraphsDFG)::GraphsDFG
    newDfg = GraphsDFG{typeof(dfg.solverParams)}(;
        userId=dfg.userId, robotId=dfg.robotId, sessionId=dfg.sessionId,
        params=deepcopy(dfg.solverParams))
    newDfg.description ="(Copy of) $(dfg.description)"
    return newDfg
end

function exists(dfg::GraphsDFG, node::N) where N <: DFGNode
    return haskey(dfg.labelDict, node.label)
end
exists(dfg::GraphsDFG, nId::Symbol) = haskey(dfg.labelDict, nId)

function isVariable(dfg::GraphsDFG, sym::Symbol)
    return exists(dfg, sym) && dfg.g.vertices[dfg.labelDict[sym]].dfgNode isa DFGVariable
end

function isFactor(dfg::GraphsDFG, sym::Symbol)
    return exists(dfg, sym) && dfg.g.vertices[dfg.labelDict[sym]].dfgNode isa DFGFactor
end

function addVariable!(dfg::GraphsDFG, variable::DFGVariable)::DFGVariable
    if haskey(dfg.labelDict, variable.label)
        error("Variable '$(variable.label)' already exists in the factor graph")
    end
    dfg.nodeCounter += 1
    variable._dfgNodeParams._internalId = dfg.nodeCounter
    v = GraphsNode(dfg.nodeCounter, variable)
    Graphs.add_vertex!(dfg.g, v)
    push!(dfg.labelDict, variable.label=>variable._dfgNodeParams._internalId)
    # Track insertion
    push!(dfg.addHistory, variable.label)

    return variable
end

function addFactor!(dfg::GraphsDFG, factor::DFGFactor)::DFGFactor

    if haskey(dfg.labelDict, factor.label)
        error("Factor '$(factor.label)' already exists in the factor graph")
    end

    variableLabels = factor._variableOrderSymbols
    for v in variableLabels
        if !(v in keys(dfg.labelDict))
            error("Variable '$(v)' not found in graph when creating Factor '$(factor.label)'")
        end
    end

    dfg.nodeCounter += 1
    factor._dfgNodeParams._internalId = dfg.nodeCounter

    fNode = GraphsNode(dfg.nodeCounter, factor)
    f = Graphs.add_vertex!(dfg.g, fNode)
    # Add index
    push!(dfg.labelDict, factor.label=>factor._dfgNodeParams._internalId)
    # Add the edges...
    for varLbl in variableLabels
        variable = getVariable(dfg, varLbl)
        v = dfg.g.vertices[variable._dfgNodeParams._internalId]
        edge = Graphs.make_edge(dfg.g, v, f)
        Graphs.add_edge!(dfg.g, edge)
    end
    # Track insertion
    # push!(dfg.addHistory, factor.label)

    return factor
end

#moved to abstract
# function addFactor!(dfg::GraphsDFG, variableIds::Vector{Symbol}, factor::DFGFactor)::DFGFactor
#     variables = map(vId -> getVariable(dfg, vId), variableIds)
#     return addFactor!(dfg, variables, factor)
# end

# TODO: Confirm we can remove this.
# function getVariable(dfg::GraphsDFG, variableId::Int64)::DFGVariable
#     @warn "This may be slow, rather use by getVariable(dfg, label)"
#     #TODO: This may be slow (O(n)), can we make it better?
#     if !(variableId in values(dfg.labelDict))
#         error("Variable ID '$(variableId)' does not exist in the factor graph")
#     end
#     return dfg.g.vertices[variableId].dfgNode
# end

function getVariable(dfg::GraphsDFG, label::Union{Symbol, String})::DFGVariable
    if typeof(label) == String
        label = Symbol(label)
    end
    if !haskey(dfg.labelDict, label)
        error("Variable label '$(label)' does not exist in the factor graph")
    end
    node = dfg.g.vertices[dfg.labelDict[label]].dfgNode
    !isa(node, AbstractDFGVariable) && error("Node with label '$(label)' is not a variable")
    return node
end

function getFactor(dfg::GraphsDFG, factorId::Int64)::DFGFactor
    @warn "This may be slow, rather use by getFactor(dfg, label)"
    #TODO: This may be slow (O(n)), can we make it better?
    if !(factorId in values(dfg.labelDict))
        error("Factor ID '$(factorId)' does not exist in the factor graph")
    end
    return dfg.g.vertices[factorId].dfgNode
end

function getFactor(dfg::GraphsDFG, label::Union{Symbol, String})::DFGFactor
    if typeof(label) == String
        label = Symbol(label)
    end
    if !haskey(dfg.labelDict, label)
        error("Factor label '$(label)' does not exist in the factor graph")
    end
    node = dfg.g.vertices[dfg.labelDict[label]].dfgNode
    !isa(node, AbstractDFGFactor) && error("Node with label '$(label)' is not a factor")
    return node
end

function updateVariable!(dfg::GraphsDFG, variable::DFGVariable)::DFGVariable
    if !haskey(dfg.labelDict, variable.label)
        @warn "Variable label '$(variable.label)' does not exist in the factor graph, adding"
        return addVariable!(dfg, variable)
    end
    dfg.g.vertices[dfg.labelDict[variable.label]].dfgNode = variable
    return variable
end

function updateFactor!(dfg::GraphsDFG, factor::DFGFactor)::DFGFactor
    if !haskey(dfg.labelDict, factor.label)
        @warn "Factor label '$(factor.label)' does not exist in the factor graph, adding"
        return addFactor!(dfg, factor._variableOrderSymbols, factor)
    end
    dfg.g.vertices[dfg.labelDict[factor.label]].dfgNode = factor
    return factor
end

function deleteVariable!(dfg::GraphsDFG, label::Symbol)#::Tuple{AbstractDFGVariable, Vector{<:AbstractDFGFactor}}
    if !haskey(dfg.labelDict, label)
        error("Variable label '$(label)' does not exist in the factor graph")
    end

    deleteNeighbors = true # reserved, orphaned factors are not supported at this time
    if deleteNeighbors
        neigfacs = map(l->deleteFactor!(dfg, l), getNeighbors(dfg, label))
    end


    variable = dfg.g.vertices[dfg.labelDict[label]].dfgNode
    delete_vertex!(dfg.g.vertices[dfg.labelDict[label]], dfg.g)
    delete!(dfg.labelDict, label)
    return variable, neigfacs
end

function deleteFactor!(dfg::GraphsDFG, label::Symbol)::DFGFactor
    if !haskey(dfg.labelDict, label)
        error("Factor label '$(label)' does not exist in the factor graph")
    end
    factor = dfg.g.vertices[dfg.labelDict[label]].dfgNode
    delete_vertex!(dfg.g.vertices[dfg.labelDict[label]], dfg.g)
    delete!(dfg.labelDict, label)
    return factor
end

function getVariables(dfg::GraphsDFG,
                      regexFilter::Union{Nothing, Regex}=nothing;
                      tags::Vector{Symbol}=Symbol[],
                      solvable::Int=0)::Vector{DFGVariable}
    #
    variables = map(v -> v.dfgNode, filter(n -> (n.dfgNode isa DFGVariable) && (solvable != 0 ? solvable <= isSolvable(n.dfgNode) : true), Graphs.vertices(dfg.g)))
    # filter on solvable

    # filter on regex
    if regexFilter != nothing
        variables = filter(v -> occursin(regexFilter, String(v.label)), variables)
    end

    # filter on tags
    if length(tags) > 0
        mask = map(v -> length(intersect(v.tags, tags)) > 0, variables )
        return variables[mask]
    end
    return variables
end

function getFactors(dfg::GraphsDFG, regexFilter::Union{Nothing, Regex}=nothing; tags::Vector{Symbol}=Symbol[], solvable::Int=0)::Vector{DFGFactor}
    factors = map(v -> v.dfgNode, filter(n -> (n.dfgNode isa DFGFactor) && (solvable != 0 ? solvable <= isSolvable(n.dfgNode) : true), Graphs.vertices(dfg.g)))

    if regexFilter != nothing
        factors = filter(f -> occursin(regexFilter, String(f.label)), factors)
    end

    if length(tags) > 0
        mask = map(v -> length(intersect(v.tags, tags)) > 0, factors )
        return factors[mask]
    end
    return factors
end

function isConnected(dfg::GraphsDFG)::Bool
    return length(Graphs.connected_components(dfg.g)) == 1
end

function getNeighbors(dfg::GraphsDFG, node::T; solvable::Int=0)::Vector{Symbol}  where T <: DFGNode
    if !haskey(dfg.labelDict, node.label)
        error("Variable/factor with label '$(node.label)' does not exist in the factor graph")
    end
    vert = dfg.g.vertices[dfg.labelDict[node.label]]
    neighbors = in_neighbors(vert, dfg.g) #Don't use out_neighbors! It enforces directiveness even if we don't want it
    # Additional filtering
    neighbors = solvable != 0 ? filter(v -> solvable <= isSolvable(v.dfgNode), neighbors) : neighbors
    # Variable sorting (order is important)
    if node isa DFGFactor
        order = intersect(node._variableOrderSymbols, map(v->v.dfgNode.label, neighbors))
        return order
    end

    return map(n -> n.dfgNode.label, neighbors)
end

function getNeighbors(dfg::GraphsDFG, label::Symbol; solvable::Int=0)::Vector{Symbol}  where T <: DFGNode
    if !haskey(dfg.labelDict, label)
        error("Variable/factor with label '$(label)' does not exist in the factor graph")
    end
    vert = dfg.g.vertices[dfg.labelDict[label]]
    neighbors = in_neighbors(vert, dfg.g) #Don't use out_neighbors! It enforces directiveness even if we don't want it
    # Additional filtering
    neighbors = solvable != 0 ? filter(v -> isSolvable(v.dfgNode) >= solvable, neighbors) : neighbors
    # Variable sorting when using a factor (function order is important)
    if vert.dfgNode isa DFGFactor
        vert.dfgNode._variableOrderSymbols
        order = intersect(vert.dfgNode._variableOrderSymbols, map(v->v.dfgNode.label, neighbors))
        return order
    end

    return map(n -> n.dfgNode.label, neighbors)
end

"""
    $(SIGNATURES)
Produces a dot-format of the graph for visualization.
"""
function toDot(dfg::GraphsDFG)::String
    return Graphs.to_dot(dfg.g)
end

function toDotFile(dfg::GraphsDFG, fileName::String="/tmp/dfg.dot")::Nothing
    open(fileName, "w") do fid
        write(fid, Graphs.to_dot(dfg.g))
    end
    return nothing
end
