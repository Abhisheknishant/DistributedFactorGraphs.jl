## ===== Interface for an AbstractDFG =====

"""
    $(SIGNATURES)

De-serialization of IncrementalInference objects require discovery of foreign types.

Example:

Template to tunnel types from a user module:
```julia
# or more generic solution -- will always try Main if available
IIF.setSerializationNamespace!(Main)

# or a specific package such as RoME if you import all variable and factor types into a specific module.
using RoME
IIF.setSerializationNamespace!(RoME)
```
"""
function setSerializationModule!(dfg::G, mod::Module)::Nothing where G <: AbstractDFG
    @warn "Setting serialization module from AbstractDFG - override this in the '$(typeof(dfg)) structure! This is being ignored."
end

function getSerializationModule(dfg::G)::Module where G <: AbstractDFG
    @warn "Retrieving serialization module from AbstractDFG - override this in the '$(typeof(dfg)) structure! This is returning Main"
    return Main
end

# Accessors
function getLabelDict(dfg::G) where G <: AbstractDFG
    error("getLabelDict not implemented for $(typeof(dfg))")
end
function getDescription(dfg::G) where G <: AbstractDFG
    error("getDescription not implemented for $(typeof(dfg))")
end
function setDescription(dfg::G, description::String) where G <: AbstractDFG
    error("setDescription not implemented for $(typeof(dfg))")
end
function getAddHistory(dfg::G) where G <: AbstractDFG
    error("getAddHistory not implemented for $(typeof(dfg))")
end
function getSolverParams(dfg::G) where G <: AbstractDFG
    error("getSolverParams not implemented for $(typeof(dfg))")
end
function setSolverParams(dfg::G, solverParams::T) where {G <: AbstractDFG, T <: AbstractParams}
    error("setSolverParams not implemented for $(typeof(dfg))")
end

# Get user, robot, and session "small" data.
# function getUserData(dfg::G)::Dict{Symbol, String} where {G <: AbstractDFG}
#     error("getUserData not implemented for $(typeof(dfg))")
# end
# function setUserData(dfg::G, data::Dict{Symbol, String})::Bool where {G <: AbstractDFG}
#     error("setUserData not implemented for $(typeof(dfg))")
# end
# function getRobotData(dfg::G)::Dict{Symbol, String} where {G <: AbstractDFG}
#     error("getRobotData not implemented for $(typeof(dfg))")
# end
# function setRobotData(dfg::G, data::Dict{Symbol, String})::Bool where {G <: AbstractDFG}
#     error("setRobotData not implemented for $(typeof(dfg))")
# end
# function getSessionData(dfg::G)::Dict{Symbol, String} where {G <: AbstractDFG}
#     error("getSessionData not implemented for $(typeof(dfg))")
# end
# function setSessionData(dfg::G, data::Dict{Symbol, String})::Bool where {G <: AbstractDFG}
#     error("setSessionData not implemented for $(typeof(dfg))")
# end

getUserData(dfg::AbstractDFG)::Dict{Symbol, String} = return dfg.userData
function setUserData(dfg::AbstractDFG, data::Dict{Symbol, String})::Bool
    dfg.userData = data
    return true
end
getRobotData(dfg::AbstractDFG)::Dict{Symbol, String} = return dfg.robotData
function setRobotData(dfg::AbstractDFG, data::Dict{Symbol, String})::Bool
    dfg.robotData = data
    return true
end
getSessionData(dfg::AbstractDFG)::Dict{Symbol, String} = return dfg.sessionData
function setSessionData(dfg::AbstractDFG, data::Dict{Symbol, String})::Bool
    dfg.sessionData = data
    return true
end

pushUserData!(dfg::AbstractDFG, pair::Pair{Symbol,String}) = push!(dfg.userData, pair)
pushRobotData!(dfg::AbstractDFG, pair::Pair{Symbol,String}) = push!(dfg.userData, pair)
pushSessionData!(dfg::AbstractDFG, pair::Pair{Symbol,String}) = push!(dfg.userData, pair)

popUserData!(dfg::AbstractDFG, key::Symbol) = pop!(dfg.userData, key)
popRobotData!(dfg::AbstractDFG, key::Symbol) = pop!(dfg.userData, key)
popSessionData!(dfg::AbstractDFG, key::Symbol) = pop!(dfg.userData, key)

"""
    $(SIGNATURES)
True if the variable or factor exists in the graph.
"""
function exists(dfg::G, node::N) where {G <: AbstractDFG, N <: DFGNode}
    error("exists not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Add a DFGVariable to a DFG.
"""
function addVariable!(dfg::G, variable::V)::Bool where {G <: AbstractDFG, V <: AbstractDFGVariable}
    error("addVariable! not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Add a DFGFactor to a DFG.
"""
function addFactor!(dfg::G, variables::Vector{V}, factor::F)::Bool where {G <: AbstractDFG, V <: AbstractDFGVariable, F <: AbstractDFGFactor}
    error("addFactor! not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Add a DFGFactor to a DFG.
"""
function addFactor!(dfg::G, variableIds::Vector{Symbol}, factor::F)::Bool where {G <: AbstractDFG, F <: AbstractDFGFactor}
    error("addFactor! not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Get a DFGVariable from a DFG using its underlying integer ID.
"""
function getVariable(dfg::G, variableId::Int64)::AbstractDFGVariable where G <: AbstractDFG
    error("getVariable not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Get a DFGVariable from a DFG using its label.
"""
function getVariable(dfg::G, label::Union{Symbol, String})::AbstractDFGVariable where G <: AbstractDFG
    return getVariable(dfg, Symbol(label))
end

"""
    $(SIGNATURES)
Get a DFGFactor from a DFG using its underlying integer ID.
"""
function getFactor(dfg::G, factorId::Int64)::AbstractDFGFactor where G <: AbstractDFG
    error("getFactor not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Get a DFGFactor from a DFG using its label.
"""
function getFactor(dfg::G, label::Union{Symbol, String})::AbstractDFGFactor where G <: AbstractDFG
    return getFactor(dfg, Symbol(label))
end

"""
    $(SIGNATURES)
Update a complete DFGVariable in the DFG.
"""
function updateVariable!(dfg::G, variable::V)::AbstractDFGVariable where {G <: AbstractDFG, V <: AbstractDFGVariable}
    error("updateVariable! not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Update a complete DFGFactor in the DFG.
"""
function updateFactor!(dfg::G, factor::F)::AbstractDFGFactor where {G <: AbstractDFG, F <: AbstractDFGFactor}
    error("updateFactor! not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Delete a DFGVariable from the DFG using its label.
"""
function deleteVariable!(dfg::G, label::Symbol)::AbstractDFGVariable where G <: AbstractDFG
    error("deleteVariable! not implemented for $(typeof(dfg))")
end

#Alias
"""
    $(SIGNATURES)
Delete a referenced DFGVariable from the DFG.
"""
function deleteVariable!(dfg::G, variable::V)::AbstractDFGVariable where {G <: AbstractDFG, V <: AbstractDFGVariable}
    return deleteVariable!(dfg, variable.label)
end

"""
    $(SIGNATURES)
Delete a DFGFactor from the DFG using its label.
"""
function deleteFactor!(dfg::G, label::Symbol)::AbstractDFGFactor where G <: AbstractDFG
    error("deleteFactors not implemented for $(typeof(dfg))")
end

# Alias
"""
    $(SIGNATURES)
Delete the referened DFGFactor from the DFG.
"""
function deleteFactor!(dfg::G, factor::F)::AbstractDFGFactor where {G <: AbstractDFG, F <: AbstractDFGFactor}
    return deleteFactor!(dfg, factor.label)
end

"""
    $(SIGNATURES)
List the DFGVariables in the DFG.
Optionally specify a label regular expression to retrieves a subset of the variables.
Tags is a list of any tags that a node must have (at least one match).
"""
function getVariables(dfg::G, regexFilter::Union{Nothing, Regex}=nothing; tags::Vector{Symbol}=Symbol[], solvable::Int=0)::Vector{AbstractDFGVariable} where G <: AbstractDFG
    error("getVariables not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Get a list of IDs of the DFGVariables in the DFG.
Optionally specify a label regular expression to retrieves a subset of the variables.
Tags is a list of any tags that a node must have (at least one match).

Example
```julia
getVariableIds(dfg, r"l", tags=[:APRILTAG;])
```

Related

ls
"""
function getVariableIds(dfg::G, regexFilter::Union{Nothing, Regex}=nothing; tags::Vector{Symbol}=Symbol[], solvable::Int=0)::Vector{Symbol} where G <: AbstractDFG
  vars = getVariables(dfg, regexFilter, tags=tags, solvable=solvable)
  return map(v -> v.label, vars)
end

# Alias
"""
    $(SIGNATURES)
List the DFGVariables in the DFG.
Optionally specify a label regular expression to retrieves a subset of the variables.
Tags is a list of any tags that a node must have (at least one match).

"""
function ls(dfg::G, regexFilter::Union{Nothing, Regex}=nothing; tags::Vector{Symbol}=Symbol[], solvable::Int=0)::Vector{Symbol} where G <: AbstractDFG
    return getVariableIds(dfg, regexFilter, tags=tags, solvable=solvable)
end

"""
    $(SIGNATURES)
List the DFGFactors in the DFG.
Optionally specify a label regular expression to retrieves a subset of the factors.
"""
function getFactors(dfg::G, regexFilter::Union{Nothing, Regex}=nothing; solvable::Int=0)::Vector{AbstractDFGFactor} where G <: AbstractDFG
    error("getFactors not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Get a list of the IDs of the DFGFactors in the DFG.
Optionally specify a label regular expression to retrieves a subset of the factors.
"""
function getFactorIds(dfg::G, regexFilter::Union{Nothing, Regex}=nothing; solvable::Int=0)::Vector{Symbol} where G <: AbstractDFG
    return map(f -> f.label, getFactors(dfg, regexFilter, solvable=solvable))
end

"""
    $(SIGNATURES)
List the DFGFactors in the DFG.
Optionally specify a label regular expression to retrieves a subset of the factors.
"""
# Alias
function lsf(dfg::G, regexFilter::Union{Nothing, Regex}=nothing; solvable::Int=0)::Vector{Symbol} where G <: AbstractDFG
    return getFactorIds(dfg, regexFilter, solvable=solvable)
end

"""
    $(SIGNATURES)
Alias for getNeighbors - returns neighbors around a given node label.
"""
function lsf(dfg::G, label::Symbol; solvable::Int=0)::Vector{Symbol} where G <: AbstractDFG
  return getNeighbors(dfg, label, solvable=solvable)
end

"""
    $(SIGNATURES)
Checks if the graph is fully connected, returns true if so.
"""
function isFullyConnected(dfg::G)::Bool where G <: AbstractDFG
    error("isFullyConnected not implemented for $(typeof(dfg))")
end

#Alias
"""
    $(SIGNATURES)
Checks if the graph is not fully connected, returns true if it is not contiguous.
"""
function hasOrphans(dfg::G)::Bool where G <: AbstractDFG
    return !isFullyConnected(dfg)
end

"""
    $(SIGNATURES)
Retrieve a list of labels of the immediate neighbors around a given variable or factor.
"""
function getNeighbors(dfg::G, node::T; solvable::Int=0)::Vector{Symbol}  where {G <: AbstractDFG, T <: DFGNode}
    error("getNeighbors not implemented for $(typeof(dfg))")
end
"""
    $(SIGNATURES)
Retrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.
"""
function getNeighbors(dfg::G, label::Symbol; solvable::Int=0)::Vector{Symbol} where G <: AbstractDFG
    error("getNeighbors not implemented for $(typeof(dfg))")
end

# Aliases
"""
    $(SIGNATURES)
Retrieve a list of labels of the immediate neighbors around a given variable or factor.
"""
function ls(dfg::G, node::T; solvable::Int=0)::Vector{Symbol} where {G <: AbstractDFG, T <: DFGNode}
    return getNeighbors(dfg, node, solvable=solvable)
end
"""
    $(SIGNATURES)
Retrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.
"""
function ls(dfg::G, label::Symbol; solvable::Int=0)::Vector{Symbol} where G <: AbstractDFG
    return getNeighbors(dfg, label, solvable=solvable)
end

"""
    $SIGNATURES

Variables or factors may or may not be 'solvable', depending on a user definition.  Useful for ensuring atomic transactions.

Related

isSolveInProgress
"""
isSolvable(var::Union{DFGVariable, DFGFactor})::Int = var.solvable

"""
    $SIGNATURES

Variables or factors may or may not be 'solvable', depending on a user definition.  Useful for ensuring atomic transactions.

Related

isSolveInProgress
"""
getSolvable(var::Union{DFGVariable, DFGFactor})::Int = var.solvable

"""
    $SIGNATURES

Get 'solvable' parameter for either a variable or factor.
"""
function getSolvable(dfg::AbstractDFG, sym::Symbol)
  if isVariable(dfg, sym)
    return getVariable(dfg, sym).solvable
  elseif isFactor(dfg, sym)
    return getFactor(dfg, sym).solvable
  end
end

"""
    $SIGNATURES

Which variables or factors are currently being used by an active solver.  Useful for ensuring atomic transactions.

DevNotes:
- Will be renamed to `data.solveinprogress` which will be in VND, not DFGNode -- see DFG #201

Related

isSolvable
"""
function isSolveInProgress(var::Union{DFGVariable, DFGFactor}; solveKey::Symbol=:default)::Int
    # Variable
    var isa DFGVariable && return haskey(solverDataDict(var), solveKey) ? solverDataDict(var)[solveKey].solveInProgress : 0
    # Factor
    return solverData(var).solveInProgress
end

"""
    $SIGNATURES

Set the `solvable` parameter for either a variable or factor.
"""
function setSolvable!(dfg::AbstractDFG, sym::Symbol, solvable::Int)::Int
  if isVariable(dfg, sym)
    getVariable(dfg, sym).solvable = solvable
  elseif isFactor(dfg, sym)
    getFactor(dfg, sym).solvable = solvable
  end
  return solvable
end

"""
    $SIGNATURES

Set the `solvable` parameter for either a variable or factor.
"""
function setSolvable!(node::N, solvable::Int)::Int where N <: DFGNode
  node.solvable = solvable
  return solvable
end

"""
    $(SIGNATURES)
Gets an empty and unique CloudGraphsDFG derived from an existing DFG.
"""
function _getDuplicatedEmptyDFG(dfg::G)::G where G <: AbstractDFG
    error("_getDuplicatedEmptyDFG not implemented for $(typeof(dfg))")
end

# TODO: NEED TO FIGURE OUT SIGNATURE FOR DEFAULT ARGS


# TODO export, test and overwrite in LightGraphs and CloudGraphsDFG
"""
    $(SIGNATURES)
Build a list of all unique neighbors inside 'distance'
"""
function getNeighborhood(dfg::AbstractDFG, label::Symbol, distance::Int)::Vector{Symbol}
    neighborList = Set{Symbol}([label])
    curList = Set{Symbol}([label])

    for dist in 1:distance
        newNeighbors = Set{Symbol}()
        for node in curList
            neighbors = getNeighbors(dfg, node)
            for neighbor in neighbors
                push!(neighborList, neighbor)
                push!(newNeighbors, neighbor)
            end
        end
        curList = newNeighbors
    end
    return collect(neighborList)
end

"""
    $(SIGNATURES)
Retrieve a deep subgraph copy around a given variable or factor.
Optionally provide a distance to specify the number of edges should be followed.
Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created.
Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.
Note: Always returns the node at the center, but filters around it if solvable is set.
"""
function getSubgraphAroundNode(dfg::AbstractDFG, node::DFGNode, distance::Int=1, includeOrphanFactors::Bool=false, addToDFG::AbstractDFG=_getDuplicatedEmptyDFG(dfg); solvable::Int=0)::AbstractDFG

    if !exists(dfg, node.label)
        error("Variable/factor with label '$(node.label)' does not exist in the factor graph")
    end

    neighbors = getNeighborhood(dfg, node.label, distance)

    # for some reason: always returns the node at the center with  || (nlbl == node.label)
    solvable != 0 && filter!(nlbl -> (getSolvable(dfg, nlbl) >= solvable) || (nlbl == node.label), neighbors)

    # Copy the section of graph we want
    _copyIntoGraph!(dfg, addToDFG, neighbors, includeOrphanFactors)
    return addToDFG
end

"""
    $(SIGNATURES)
Get a deep subgraph copy from the DFG given a list of variables and factors.
Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created.
Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.
"""
function getSubgraph(dfg::G,
                     variableFactorLabels::Vector{Symbol},
                     includeOrphanFactors::Bool=false,
                     addToDFG::H=_getDuplicatedEmptyDFG(dfg))::H where {G <: AbstractDFG, H <: AbstractDFG}
    for label in variableFactorLabels
        if !exists(dfg, label)
            error("Variable/factor with label '$(label)' does not exist in the factor graph")
        end
    end

    _copyIntoGraph!(dfg, addToDFG, variableFactorLabels, includeOrphanFactors)
    return addToDFG
end

"""
    $(SIGNATURES)
Common function for copying nodes from one graph into another graph.
This is overridden in specialized implementations for performance.
NOTE: copyGraphMetadata not supported yet.
"""
function _copyIntoGraph!(sourceDFG::G, destDFG::H, variableFactorLabels::Vector{Symbol}, includeOrphanFactors::Bool=false; copyGraphMetadata::Bool=false)::Nothing where {G <: AbstractDFG, H <: AbstractDFG}
    # Split into variables and factors
    sourceVariables = map(vId->getVariable(sourceDFG, vId), intersect(getVariableIds(sourceDFG), variableFactorLabels))
    sourceFactors = map(fId->getFactor(sourceDFG, fId), intersect(getFactorIds(sourceDFG), variableFactorLabels))
    if length(sourceVariables) + length(sourceFactors) != length(variableFactorLabels)
        rem = symdiff(map(v->v.label, sourceVariables), variableFactorLabels)
        rem = symdiff(map(f->f.label, sourceFactors), variableFactorLabels)
        error("Cannot copy because cannot find the following nodes in the source graph: $rem")
    end

    # Now we have to add all variables first,
    for variable in sourceVariables
        if !exists(destDFG, variable)
            addVariable!(destDFG, deepcopy(variable))
        end
    end
    # And then all factors to the destDFG.
    for factor in sourceFactors
        # Get the original factor variables (we need them to create it)
        sourceFactorVariableIds = getNeighbors(sourceDFG, factor)
        # Find the labels and associated variables in our new subgraph
        factVariableIds = Symbol[]
        for variable in sourceFactorVariableIds
            if exists(destDFG, variable)
                push!(factVariableIds, variable)
            end
        end
        # Only if we have all of them should we add it (otherwise strange things may happen on evaluation)
        if includeOrphanFactors || length(factVariableIds) == length(sourceFactorVariableIds)
            if !exists(destDFG, factor)
                addFactor!(destDFG, factVariableIds, deepcopy(factor))
            end
        end
    end

    if copyGraphMetadata
        setUserData(destDFG, getUserData(sourceDFG))
        setRobotData(destDFG, getRobotData(sourceDFG))
        setSessionData(destDFG, getSessionData(sourceDFG))
    end
    return nothing
end

"""
    $(SIGNATURES)
Merges and updates solver and estimate data for a variable (variable can be from another graph).
Note: Makes a copy of the estimates and solver data so that there is no coupling
between graphs.
"""
function mergeUpdateVariableSolverData!(dfg::AbstractDFG, sourceVariable::AbstractDFGVariable)::AbstractDFGVariable
    if !exists(dfg, sourceVariable)
        error("Source variable '$(sourceVariable.label)' doesn't exist in the graph.")
    end
    var = getVariable(dfg, sourceVariable.label)
    # We don't know which graph this came from, must be copied!
    merge!(var.ppeDict, deepcopy(sourceVariable.ppeDict))
    # If this variable has solverDataDict (summaries do not)
    :solverDataDict in fieldnames(typeof(var)) && merge!(var.solverDataDict, deepcopy(sourceVariable.solverDataDict))
    return sourceVariable
end

"""
    $(SIGNATURES)
Common function to update all solver data and estimates from one graph to another.
This should be used to push local solve data back into a cloud graph, for example.
"""
function mergeUpdateGraphSolverData!(sourceDFG::G, destDFG::H, varSyms::Vector{Symbol})::Nothing where {G <: AbstractDFG, H <: AbstractDFG}
    # Update all variables in the destination
    # (For now... we may change this soon)
    for variableId in varSyms
        mergeUpdateVariableSolverData!(destDFG, getVariable(sourceDFG, variableId))
    end
end

"""
    $(SIGNATURES)
Get an adjacency matrix for the DFG, returned as a Matrix{Union{Nothing, Symbol}}.
Rows are all factors, columns are all variables, and each cell contains either nothing or the symbol of the relating factor.
The first row and first column are factor and variable headings respectively.
"""
function getAdjacencyMatrix(dfg::AbstractDFG; solvable::Int=0)::Matrix{Union{Nothing, Symbol}}
    #
    varLabels = sort(map(v->v.label, getVariables(dfg, solvable=solvable)))
    factLabels = sort(map(f->f.label, getFactors(dfg, solvable=solvable)))
    vDict = Dict(varLabels .=> [1:length(varLabels)...].+1)

    adjMat = Matrix{Union{Nothing, Symbol}}(nothing, length(factLabels)+1, length(varLabels)+1)
    # Set row/col headings
    adjMat[2:end, 1] = factLabels
    adjMat[1, 2:end] = varLabels
    for (fIndex, factLabel) in enumerate(factLabels)
        factVars = getNeighbors(dfg, getFactor(dfg, factLabel), solvable=solvable)
        map(vLabel -> adjMat[fIndex+1,vDict[vLabel]] = factLabel, factVars)
    end
    return adjMat
end

"""
    $(SIGNATURES)
Get an adjacency matrix for the DFG, returned as a tuple: adjmat::SparseMatrixCSC{Int}, var_labels::Vector{Symbol) fac_labels::Vector{Symbol).
Rows are the factors, columns are the variables, with the corresponding labels in fac_labels,var_labels.
"""
function getAdjacencyMatrixSparse(dfg::G; solvable::Int=0)::Tuple{SparseMatrixCSC, Vector{Symbol}, Vector{Symbol}} where G <: AbstractDFG
    varLabels = map(v->v.label, getVariables(dfg, solvable=solvable))
    factLabels = map(f->f.label, getFactors(dfg, solvable=solvable))

    vDict = Dict(varLabels .=> [1:length(varLabels)...])

    adjMat = spzeros(Int, length(factLabels), length(varLabels))

    for (fIndex, factLabel) in enumerate(factLabels)
        factVars = getNeighbors(dfg, getFactor(dfg, factLabel), solvable=solvable)
        map(vLabel -> adjMat[fIndex,vDict[vLabel]] = 1, factVars)
    end
    return adjMat, varLabels, factLabels
end

"""
    $SIGNATURES

Returns state of vertex data `.initialized` flag.

Notes:
- used by both factor graph variable and Bayes tree clique logic.
"""
function isInitialized(var::DFGVariable; key::Symbol=:default)::Bool
      data = solverData(var, key)
      if data == nothing
        @error "Variable does not have solver data $(key)"
        return false
      else
          return data.initialized
    end
end

function isInitialized(dfg::AbstractDFG, label::Symbol; key::Symbol=:default)::Bool
  return isInitialized(getVariable(dfg, label), key=key)
end


"""
    $SIGNATURES

Return whether `sym::Symbol` represents a variable vertex in the graph DFG.
Checks whether it both exists in the graph and is a variable.
(If you rather want a quick for type, just do node isa DFGVariable)
"""
function isVariable(dfg::G, sym::Symbol) where G <: AbstractDFG
	error("isVariable not implemented for $(typeof(dfg))")
end
# Alias - bit ridiculous but know it'll come up at some point. Does existential and type check.
function isVariable(dfg::G, node::N)::Bool where {G <: AbstractDFG, N <: DFGNode}
	return isVariable(dfg, node.label)
end

"""
    $SIGNATURES

Return whether `sym::Symbol` represents a factor vertex in the graph DFG.
Checks whether it both exists in the graph and is a factor.
(If you rather want a quicker for type, just do node isa DFGFactor)
"""
function isFactor(dfg::G, sym::Symbol) where G <: AbstractDFG
	error("isFactor not implemented for $(typeof(dfg))")
end
# Alias - bit ridiculous but know it'll come up at some point. Does existential and type check.
function isFactor(dfg::G, node::N)::Bool where {G <: AbstractDFG, N <: DFGNode}
	return isFactor(dfg, node.label)
end

"""
    $SIGNATURES

Return reference to the user factor in `<:AbstractDFG` identified by `::Symbol`.
"""
getFactorFunction(fcd::GenericFunctionNodeData) = fcd.fnc.usrfnc!
getFactorFunction(fc::DFGFactor) = getFactorFunction(solverData(fc))
function getFactorFunction(dfg::G, fsym::Symbol) where G <: AbstractDFG
  getFactorFunction(getFactor(dfg, fsym))
end


"""
    $SIGNATURES

Display and return to console the user factor identified by tag name.
"""
showFactor(fgl::G, fsym::Symbol) where G <: AbstractDFG = @show getFactor(fgl,fsym)


"""
    $(SIGNATURES)
Produces a dot-format of the graph for visualization.
"""
function toDot(dfg::AbstractDFG)::String
    #TODO implement convert
    graphsdfg = GraphsDFG{AbstractParams}()
    DistributedFactorGraphs._copyIntoGraph!(dfg, graphsdfg, union(getVariableIds(dfg), getFactorIds(dfg)), true)

    # Calls down to GraphsDFG.toDot
    return toDot(graphsdfg)
end

"""
    $(SIGNATURES)
Produces a dot file of the graph for visualization.
Download XDot to see the data

Note
- Default location "/tmp/dfg.dot" -- MIGHT BE REMOVED
- Can be viewed with the `xdot` system application.
- Based on graphviz.org
"""
function toDotFile(dfg::AbstractDFG, fileName::String="/tmp/dfg.dot")::Nothing
    #TODO implement convert
    graphsdfg = GraphsDFG{AbstractParams}()
    DistributedFactorGraphs._copyIntoGraph!(dfg, graphsdfg, union(getVariableIds(dfg), getFactorIds(dfg)), true)

    open(fileName, "w") do fid
        write(fid,Graphs.to_dot(graphsdfg.g))
    end
    return nothing
end

"""
    $(SIGNATURES)
Get a summary of the graph (first-class citizens of variables and factors).
Returns a AbstractDFGSummary.
"""
function getSummary(dfg::G)::AbstractDFGSummary where {G <: AbstractDFG}
    vars = map(v -> convert(DFGVariableSummary, v), getVariables(dfg))
    facts = map(f -> convert(DFGFactorSummary, f), getFactors(dfg))
    return AbstractDFGSummary(
        Dict(map(v->v.label, vars) .=> vars),
        Dict(map(f->f.label, facts) .=> facts),
        dfg.userId,
        dfg.robotId,
        dfg.sessionId)
end

"""
$(SIGNATURES)
Get a summary graph (first-class citizens of variables and factors) with the same structure as the original graph.
Note this is a copy of the original.
Returns a LightDFG{NoSolverParams, DFGVariableSummary, DFGFactorSummary}.
"""
function getSummaryGraph(dfg::G)::LightDFG{NoSolverParams, DFGVariableSummary, DFGFactorSummary} where {G <: AbstractDFG}
    summaryDfg = LightDFG{NoSolverParams, DFGVariableSummary, DFGFactorSummary}(
        description="Summary of $(dfg.description)",
        userId=dfg.userId,
        robotId=dfg.robotId,
        sessionId=dfg.sessionId)
    for v in getVariables(dfg)
        newV = addVariable!(summaryDfg, convert(DFGVariableSummary, v))
    end
    for f in getFactors(dfg)
        addFactor!(summaryDfg, getNeighbors(dfg, f), convert(DFGFactorSummary, f))
    end
    return summaryDfg
end
