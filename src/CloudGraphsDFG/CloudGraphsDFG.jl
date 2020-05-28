module CloudGraphsDFGs

using ...DistributedFactorGraphs

import ...DistributedFactorGraphs:  setSolverParams!,
                                    getFactor,
                                    setDescription!,
                                    # getLabelDict,
                                    getUserData,
                                    setUserData!,
                                    getRobotData,
                                    setRobotData!,
                                    getSessionData,
                                    setSessionData!,
                                    addVariable!,
                                    getVariable,
                                    getAddHistory,
                                    addFactor!,
                                    getSolverParams,
                                    exists,
                                    isVariable,
                                    isFactor,
                                    getDescription,
                                    updateVariable!,
                                    updateFactor!,
                                    deleteVariable!,
                                    deleteFactor!,
                                    getVariables,
                                    listVariables,
                                    ls,
                                    getFactors,
                                    listFactors,
                                    lsf,
                                    isConnected,
                                    getNeighbors,
                                    buildSubgraph,
                                    copyGraph!,
                                    getBiadjacencyMatrix,
                                    _getDuplicatedEmptyDFG,
                                    toDot,
                                    toDotFile,
                                    AbstractBigDataEntry,
                                    isValidLabel,
                                    _invalidIds,#TODO Export from DFG
                                    _validLabelRegex, #TODO Export from DFG
                                    updateUserData!,
                                    getUserData,
                                    deleteUserData!,
                                    emptyUserData!,
                                    updateRobotData!,
                                    getRobotData,
                                    deleteRobotData!,
                                    emptyRobotData!,
                                    updateSessionData!,
                                    getSessionData,
                                    deleteSessionData!,
                                    emptySessionData!,
                                    listTags,
                                    mergeTags!,
                                    removeTags!,
                                    emptyTags!,
                                    addVariableSolverData!,
                                    updateVariableSolverData!,
                                    deleteVariableSolverData!,
                                    getVariableSolverData,
                                    mergeVariableData!,
                                    getPPE,
                                    addPPE!,
                                    listPPEs,
                                    deletePPE!,
                                    updatePPE!,
                                    packPPE,
                                    unpackPPE,
                                    getSolvable,
                                    setSolvable!

using Neo4j
using Base64

using DocStringExtensions
using Requires
using Dates
using Distributions
using Reexport
using JSON
using Unmarshal
using JSON2 # JSON2 requires all properties to be in correct sequence, can't guarantee that from DB.
using LinearAlgebra
using SparseArrays
using UUIDs

# Entities
include("entities/CloudGraphsDFG.jl")
include("entities/CGStructure.jl")

# Services
include("services/CommonFunctions.jl")
include("services/CGStructure.jl")
include("services/CloudGraphsDFG.jl")

# Exports
export Neo4jInstance, CloudGraphsDFG

# Additional exports for CGStructure
export copySession!
# Please be careful with these
# With great power comes great "Oh crap, I deleted everything..."
export clearSession!!, clearRobot!!, clearUser!!
export createSession, createRobot, createUser, createDfgSessionIfNotExist
export existsSession, existsRobot, existsUser
export getSession, getRobot, getUser
export updateSession, updateRobot, updateUser
export lsSessions, lsRobots, lsUsers

end
