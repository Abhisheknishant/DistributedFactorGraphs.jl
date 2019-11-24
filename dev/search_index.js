var documenterSearchIndex = {"docs":
[{"location":"apis/graphs/#The-Graphs.jl-DistributedFactorGraph-API-1","page":"Graphs.jl","title":"The Graphs.jl DistributedFactorGraph API","text":"","category":"section"},{"location":"ref_api/#Common-API-Interface-1","page":"Common API Interface","title":"Common API Interface","text":"","category":"section"},{"location":"getting_started/#Getting-Started-1","page":"Introduction","title":"Getting Started","text":"","category":"section"},{"location":"variable_factor_serialization/#Serialization-of-Variables-and-Factors-1","page":"Serialization of Variables and Factors","title":"Serialization of Variables and Factors","text":"","category":"section"},{"location":"variable_factor_serialization/#","page":"Serialization of Variables and Factors","title":"Serialization of Variables and Factors","text":"If you are transferring variables and factors over a wire you need to serialize and deserialize variables and factors.","category":"page"},{"location":"variable_factor_serialization/#Packing-and-Unpacking-1","page":"Serialization of Variables and Factors","title":"Packing and Unpacking","text":"","category":"section"},{"location":"variable_factor_serialization/#","page":"Serialization of Variables and Factors","title":"Serialization of Variables and Factors","text":"Packing is done with the exposed functions packVariable()::Dict{String, Any} and packFactor()::Dict{String, Any}. You can then serialize this into a string or JSON as you would normally.","category":"page"},{"location":"variable_factor_serialization/#","page":"Serialization of Variables and Factors","title":"Serialization of Variables and Factors","text":"Note: When you deserialize a factor and want to use it for solving, you must call IncrementalInference.rebuildFactorMetadata!(dfgLoadInto, factor) to reinflate it completely. Please review FileDFG service for an example.","category":"page"},{"location":"variable_factor_serialization/#","page":"Serialization of Variables and Factors","title":"Serialization of Variables and Factors","text":"For example:","category":"page"},{"location":"variable_factor_serialization/#","page":"Serialization of Variables and Factors","title":"Serialization of Variables and Factors","text":"using DistributedFactorGraphs\nusing IncrementalInference, RoME\n\n# Make a variable and a factor:\n# Make a simple graph\ndfg = GraphsDFG{SolverParams}(params=SolverParams())\n# Add the first pose :x0\nx0 = addVariable!(dfg, :x0, Pose2)\n# Add at a fixed location PriorPose2 to pin :x0 to a starting location (10,10, pi/4)\nprior = addFactor!(dfg, [:x0], PriorPose2( MvNormal([10; 10; 1.0/8.0], Matrix(Diagonal([0.1;0.1;0.05].^2))) ) )\n\n# Now serialize them:\npVariable = packVariable(dfg, x0)\npFactor = packFactor(dfg, prior)\n\n# And we can deserialize them\nupVariable = unpackVariable(dfg, pVariable)\n# FYI: The graph is used in unpackFactor to find the variables that the factor links to.\nupFactor = unpackFactor(dfg, pFactor, IncrementalInference)\n# Note, you need to call IncrementalInference.rebuildFactorMetadata!(dfgLoadInto, factor)\n# to make it useable. Please add an issue if this poses a problem or causes issues.","category":"page"},{"location":"variable_factor_serialization/#","page":"Serialization of Variables and Factors","title":"Serialization of Variables and Factors","text":"As a more complex example, we can use JSON2 to stringify the data and write it to a folder of files as FileDFG does:","category":"page"},{"location":"variable_factor_serialization/#","page":"Serialization of Variables and Factors","title":"Serialization of Variables and Factors","text":"using DistributedFactorGraphs\nusing IncrementalInference, RoME\n\n# Make a variable and a factor:\n# Make a simple graph\ndfg = GraphsDFG{SolverParams}(params=SolverParams())\n# Add the first pose :x0\nx0 = addVariable!(dfg, :x0, Pose2)\n# Add at a fixed location PriorPose2 to pin :x0 to a starting location (10,10, pi/4)\nprior = addFactor!(dfg, [:x0], PriorPose2( MvNormal([10; 10; 1.0/8.0], Matrix(Diagonal([0.1;0.1;0.05].^2))) ) )\n\n# Slightly fancier example: We can use JSON2, we can serialize to a string\nvarFolder = \"/tmp\"\nfor v in getVariables(dfg)\n    vPacked = packVariable(dfg, v)\n    io = open(\"$varFolder/$(v.label).json\", \"w\")\n    JSON2.write(io, vPacked)\n    close(io)\nend\n# Factors\nfor f in getFactors(dfg)\n    fPacked = packFactor(dfg, f)\n    io = open(\"$folder/factors/$(f.label).json\", \"w\")\n    JSON2.write(io, fPacked)\n    close(io)\nend","category":"page"},{"location":"variables_and_factors/#Variables-and-Factors-1","page":"Variables and Factors","title":"Variables and Factors","text":"","category":"section"},{"location":"#Introduction-1","page":"Home","title":"Introduction","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"This package is a specialized Julia graphing wrapper.","category":"page"},{"location":"#Installation-1","page":"Home","title":"Installation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"This package is not yet registered with JuliaLang/METADATA.jl, but can be easily installed in Julia 0.6 with:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"julia> ]add https://github.com/GearsAD/GraffSDK.jl.git","category":"page"},{"location":"#Manual-Outline-1","page":"Home","title":"Manual Outline","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Pages = [\n    \"index.md\"\n    \"getting_started.md\"\n    \"variables_and_factors.md\"\n    \"ref_api.md\"\n    \"example.md\"\n    \"func_ref.md\"\n]","category":"page"},{"location":"func_ref/#Function-Reference-1","page":"Reference","title":"Function Reference","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"Pages = [\n    \"func_ref.md\"\n]\nDepth = 3","category":"page"},{"location":"func_ref/#Graph-Types-1","page":"Reference","title":"Graph Types","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"GraphsDFG","category":"page"},{"location":"func_ref/#Creating-DFG-Factor-Graphs-1","page":"Reference","title":"Creating DFG Factor Graphs","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"addVariable!\naddFactor!","category":"page"},{"location":"func_ref/#DistributedFactorGraphs.addVariable!","page":"Reference","title":"DistributedFactorGraphs.addVariable!","text":"Add a DFGVariable to a DFG.\n\n\n\n\n\naddVariable!(dfg, variable)\n\n\nAdd a DFGVariable to a DFG.\n\n\n\n\n\naddVariable!(dfg, variable)\n\n\nAdd a DFGVariable to a DFG.\n\n\n\n\n\naddVariable!(dfg, variable)\n\n\nAdd a DFGVariable to a DFG.\n\n\n\n\n\naddVariable!(dfg, variable)\n\n\nAdd a DFGVariable to a DFG.\n\n\n\n\n\naddVariable!(dfg, variable)\n\n\nAdd a DFGVariable to a DFG.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.addFactor!","page":"Reference","title":"DistributedFactorGraphs.addFactor!","text":"addFactor!(dfg, variables, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variableIds, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variables, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variableIds, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variables, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variableIds, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variables, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variableIds, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variables, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variableLabels, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variables, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\naddFactor!(dfg, variableLabels, factor)\n\n\nAdd a DFGFactor to a DFG.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Getting-Factor-Graph-Nodes-1","page":"Reference","title":"Getting Factor Graph Nodes","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"getVariables\ngetFactors\ngetVariable\ngetFactor\ngetNeighbors\nls\nlsf","category":"page"},{"location":"func_ref/#DistributedFactorGraphs.getVariables","page":"Reference","title":"DistributedFactorGraphs.getVariables","text":"List the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\ngetVariables(dfg)\ngetVariables(dfg, regexFilter; tags, solvable)\n\n\nList the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\ngetVariables(dfg)\ngetVariables(dfg, regexFilter; tags)\n\n\nList the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\ngetVariables(dfg)\ngetVariables(dfg, regexFilter; tags)\n\n\nList the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\ngetVariables(dfg)\ngetVariables(dfg, regexFilter; tags)\n\n\nList the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\ngetVariables(dfg)\ngetVariables(dfg, regexFilter; tags)\n\n\nList the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.getFactors","page":"Reference","title":"DistributedFactorGraphs.getFactors","text":"List the DFGFactors in the DFG. Optionally specify a label regular expression to retrieves a subset of the factors.\n\n\n\n\n\ngetFactors(dfg)\ngetFactors(dfg, regexFilter)\n\n\nList the DFGFactors in the DFG. Optionally specify a label regular expression to retrieves a subset of the factors.\n\n\n\n\n\ngetFactors(dfg)\ngetFactors(dfg, regexFilter)\n\n\nList the DFGFactors in the DFG. Optionally specify a label regular expression to retrieves a subset of the factors.\n\n\n\n\n\ngetFactors(dfg)\ngetFactors(dfg, regexFilter)\n\n\nList the DFGFactors in the DFG. Optionally specify a label regular expression to retrieves a subset of the factors.\n\n\n\n\n\ngetFactors(dfg)\ngetFactors(dfg, regexFilter)\n\n\nList the DFGFactors in the DFG. Optionally specify a label regular expression to retrieves a subset of the factors.\n\n\n\n\n\ngetFactors(dfg)\ngetFactors(dfg, regexFilter)\n\n\nList the DFGFactors in the DFG. Optionally specify a label regular expression to retrieves a subset of the factors.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.getVariable","page":"Reference","title":"DistributedFactorGraphs.getVariable","text":"Get a DFGVariable from a DFG using its underlying integer ID.\n\n\n\n\n\nGet a DFGVariable from a DFG using its label.\n\n\n\n\n\ngetVariable(dfg, variableId)\n\n\nGet a DFGVariable from a DFG using its underlying integer ID.\n\n\n\n\n\ngetVariable(dfg, label)\n\n\nGet a DFGVariable from a DFG using its label.\n\n\n\n\n\ngetVariable(dfg, variableId)\n\n\nGet a DFGVariable from a DFG using its underlying integer ID.\n\n\n\n\n\ngetVariable(dfg, label)\n\n\nGet a DFGVariable from a DFG using its label.\n\n\n\n\n\ngetVariable(dfg, variableId)\n\n\nGet a DFGVariable from a DFG using its underlying integer ID.\n\n\n\n\n\ngetVariable(dfg, label)\n\n\nGet a DFGVariable from a DFG using its label.\n\n\n\n\n\ngetVariable(dfg, label)\n\n\nGet a DFGVariable from a DFG using its label.\n\n\n\n\n\ngetVariable(dfg, label)\n\n\nGet a DFGVariable from a DFG using its label.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.getFactor","page":"Reference","title":"DistributedFactorGraphs.getFactor","text":"getFactor(dfg, factorId)\n\n\nGet a DFGFactor from a DFG using its underlying integer ID.\n\n\n\n\n\ngetFactor(dfg, label)\n\n\nGet a DFGFactor from a DFG using its label.\n\n\n\n\n\ngetFactor(dfg, factorId)\n\n\nGet a DFGFactor from a DFG using its underlying integer ID.\n\n\n\n\n\ngetFactor(dfg, label)\n\n\nGet a DFGFactor from a DFG using its label.\n\n\n\n\n\ngetFactor(dfg, factorId)\n\n\nGet a DFGFactor from a DFG using its underlying integer ID.\n\n\n\n\n\ngetFactor(dfg, label)\n\n\nGet a DFGFactor from a DFG using its label.\n\n\n\n\n\ngetFactor(dfg, factorId)\n\n\nGet a DFGFactor from a DFG using its underlying integer ID.\n\n\n\n\n\ngetFactor(dfg, label)\n\n\nGet a DFGFactor from a DFG using its label.\n\n\n\n\n\ngetFactor(dfg, label)\n\n\nGet a DFGFactor from a DFG using its label.\n\n\n\n\n\ngetFactor(dfg, label)\n\n\nGet a DFGFactor from a DFG using its label.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.getNeighbors","page":"Reference","title":"DistributedFactorGraphs.getNeighbors","text":"getNeighbors(dfg, node; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\ngetNeighbors(dfg, label; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\ngetNeighbors(dfg, node; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\ngetNeighbors(dfg, label; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\ngetNeighbors(dfg, node; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\ngetNeighbors(dfg, label; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\ngetNeighbors(dfg, node; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\ngetNeighbors(dfg, label; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\ngetNeighbors(dfg, node; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\ngetNeighbors(dfg, label; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\ngetNeighbors(dfg, node; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\ngetNeighbors(dfg, label; ready, backendset)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.ls","page":"Reference","title":"DistributedFactorGraphs.ls","text":"ls(dfg)\nls(dfg, regexFilter; tags)\n\n\nList the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\nls(dfg)\nls(dfg, regexFilter; tags)\n\n\nList the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\nls(dfg, label)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\nls(dfg)\nls(dfg, regexFilter)\n\n\nList the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\nls(dfg, label)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\nls(dfg)\nls(dfg, regexFilter; tags)\n\n\nList the DFGVariables in the DFG. Optionally specify a label regular expression to retrieves a subset of the variables.\n\n\n\n\n\nls(dfg, node)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor.\n\n\n\n\n\nls(dfg, label)\n\n\nRetrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.lsf","page":"Reference","title":"DistributedFactorGraphs.lsf","text":"Alias for getNeighbors - returns neighbors around a given node label.\n\n\n\n\n\nlsf(dfg, label)\n\n\nAlias for getNeighbors - returns neighbors around a given node label.\n\n\n\n\n\nlsf(dfg)\nlsf(dfg, regexFilter)\n\n\nList the DFGFactors in the DFG. Optionally specify a label regular expression to retrieves a subset of the factors.\n\n\n\n\n\nlsf(dfg, label)\n\n\nGet neighbors around a given node. TODO: Refactor this\n\n\n\n\n\nlsf(dfg, label)\n\n\nAlias for getNeighbors - returns neighbors around a given node label.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Updating-Factor-Graph-Nodes-1","page":"Reference","title":"Updating Factor Graph Nodes","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"updateVariable!\nupdateFactor!","category":"page"},{"location":"func_ref/#DistributedFactorGraphs.updateVariable!","page":"Reference","title":"DistributedFactorGraphs.updateVariable!","text":"Update a complete DFGVariable in the DFG.\n\n\n\n\n\nupdateVariable!(dfg, variable)\n\n\nUpdate a complete DFGVariable in the DFG.\n\n\n\n\n\nupdateVariable!(dfg, variable)\n\n\nUpdate a complete DFGVariable in the DFG.\n\n\n\n\n\nupdateVariable!(dfg, variable)\n\n\nUpdate a complete DFGVariable in the DFG.\n\n\n\n\n\nupdateVariable!(dfg, variable)\n\n\nUpdate a complete DFGVariable in the DFG.\n\n\n\n\n\nupdateVariable!(dfg, variable)\n\n\nUpdate a complete DFGVariable in the DFG.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.updateFactor!","page":"Reference","title":"DistributedFactorGraphs.updateFactor!","text":"updateFactor!(dfg, factor)\n\n\nUpdate a complete DFGFactor in the DFG.\n\n\n\n\n\nupdateFactor!(dfg, factor)\n\n\nUpdate a complete DFGFactor in the DFG.\n\n\n\n\n\nupdateFactor!(dfg, factor)\n\n\nUpdate a complete DFGFactor in the DFG.\n\n\n\n\n\nupdateFactor!(dfg, factor)\n\n\nUpdate a complete DFGFactor in the DFG.\n\n\n\n\n\nupdateFactor!(dfg, variables, factor)\n\n\nUpdate a complete DFGFactor in the DFG and update its relationships.\n\n\n\n\n\nupdateFactor!(dfg, variableIds, factor)\n\n\nUpdate a complete DFGFactor in the DFG and update it's relationships.\n\n\n\n\n\nupdateFactor!(dfg, factor)\n\n\nUpdate a complete DFGFactor in the DFG.\n\n\n\n\n\nupdateFactor!(dfg, factor)\n\n\nUpdate a complete DFGFactor in the DFG.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Deleting-Factor-Graph-Nodes-1","page":"Reference","title":"Deleting Factor Graph Nodes","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"deleteVariable!\ndeleteFactor!","category":"page"},{"location":"func_ref/#DistributedFactorGraphs.deleteVariable!","page":"Reference","title":"DistributedFactorGraphs.deleteVariable!","text":"Delete a DFGVariable from the DFG using its label.\n\n\n\n\n\ndeleteVariable!(dfg, variable)\n\n\nDelete a referenced DFGVariable from the DFG.\n\n\n\n\n\ndeleteVariable!(dfg, label)\n\n\nDelete a DFGVariable from the DFG using its label.\n\n\n\n\n\ndeleteVariable!(dfg, label)\n\n\nDelete a DFGVariable from the DFG using its label.\n\n\n\n\n\ndeleteVariable!(dfg, variable)\n\n\nDelete a referenced DFGVariable from the DFG.\n\n\n\n\n\ndeleteVariable!(dfg, label)\n\n\nDelete a DFGVariable from the DFG using its label.\n\n\n\n\n\ndeleteVariable!(dfg, variable)\n\n\nDelete a referenced DFGVariable from the DFG.\n\n\n\n\n\ndeleteVariable!(dfg, label)\n\n\nDelete a DFGVariable from the DFG using its label.\n\n\n\n\n\ndeleteVariable!(dfg, label)\n\n\nDelete a DFGVariable from the DFG using its label.\n\n\n\n\n\ndeleteVariable!(dfg, variable)\n\n\nDelete a referenced DFGVariable from the DFG.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.deleteFactor!","page":"Reference","title":"DistributedFactorGraphs.deleteFactor!","text":"Delete a DFGFactor from the DFG using its label.\n\n\n\n\n\nDelete the referened DFGFactor from the DFG.\n\n\n\n\n\ndeleteFactor!(dfg, label)\n\n\nDelete a DFGFactor from the DFG using its label.\n\n\n\n\n\ndeleteFactor!(dfg, label)\n\n\nDelete a DFGFactor from the DFG using its label.\n\n\n\n\n\ndeleteFactor!(dfg, factor)\n\n\nDelete the referened DFGFactor from the DFG.\n\n\n\n\n\ndeleteFactor!(dfg, label)\n\n\nDelete a DFGFactor from the DFG using its label.\n\n\n\n\n\ndeleteFactor!(dfg, factor)\n\n\nDelete the referened DFGFactor from the DFG.\n\n\n\n\n\ndeleteFactor!(dfg, label)\n\n\nDelete a DFGFactor from the DFG using its label.\n\n\n\n\n\ndeleteFactor!(dfg, label)\n\n\nDelete a DFGFactor from the DFG using its label.\n\n\n\n\n\ndeleteFactor!(dfg, factor)\n\n\nDelete the referened DFGFactor from the DFG.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Getting-Adjacency-Matrix-1","page":"Reference","title":"Getting Adjacency Matrix","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"getAdjacencyMatrix","category":"page"},{"location":"func_ref/#DistributedFactorGraphs.getAdjacencyMatrix","page":"Reference","title":"DistributedFactorGraphs.getAdjacencyMatrix","text":"Get an adjacency matrix for the DFG, returned as a Matrix{Union{Nothing, Symbol}}. Rows are all factors, columns are all variables, and each cell contains either nothing or the symbol of the relating factor. The first row and first column are factor and variable headings respectively.\n\n\n\n\n\ngetAdjacencyMatrix(dfg)\n\n\nGet an adjacency matrix for the DFG, returned as a Matrix{Union{Nothing, Symbol}}. Rows are all factors, columns are all variables, and each cell contains either nothing or the symbol of the relating factor. The first row and first column are factor and variable headings respectively.\n\n\n\n\n\ngetAdjacencyMatrix(dfg)\n\n\nGet an adjacency matrix for the DFG, returned as a Matrix{Union{Nothing, Symbol}}. Rows are all factors, columns are all variables, and each cell contains either nothing or the symbol of the relating factor. The first row and first column are factor and variable headings respectively. This is optimized for database usage.\n\n\n\n\n\ngetAdjacencyMatrix(dfg)\n\n\nGet an adjacency matrix for the DFG, returned as a Matrix{Union{Nothing, Symbol}}. Rows are all factors, columns are all variables, and each cell contains either nothing or the symbol of the relating factor. The first row and first column are factor and variable headings respectively.\n\n\n\n\n\ngetAdjacencyMatrix(dfg)\n\n\nGet an adjacency matrix for the DFG, returned as a Matrix{Union{Nothing, Symbol}}. Rows are all factors, columns are all variables, and each cell contains either nothing or the symbol of the relating factor. The first row and first column are factor and variable headings respectively.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Validating-Factor-Graph-Connectivity-1","page":"Reference","title":"Validating Factor Graph Connectivity","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"isFullyConnected\nhasOrphans","category":"page"},{"location":"func_ref/#DistributedFactorGraphs.isFullyConnected","page":"Reference","title":"DistributedFactorGraphs.isFullyConnected","text":"Checks if the graph is fully connected, returns true if so.\n\n\n\n\n\nisFullyConnected(dfg)\n\n\nChecks if the graph is fully connected, returns true if so.\n\n\n\n\n\nisFullyConnected(dfg)\n\n\nChecks if the graph is fully connected, returns true if so.\n\n\n\n\n\nisFullyConnected(dfg)\n\n\nChecks if the graph is fully connected, returns true if so.\n\n\n\n\n\nisFullyConnected(dfg)\n\n\nChecks if the graph is fully connected, returns true if so.\n\n\n\n\n\nisFullyConnected(dfg)\n\n\nChecks if the graph is fully connected, returns true if so.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.hasOrphans","page":"Reference","title":"DistributedFactorGraphs.hasOrphans","text":"Checks if the graph is not fully connected, returns true if it is not contiguous.\n\n\n\n\n\nhasOrphans(dfg)\n\n\nChecks if the graph is not fully connected, returns true if it is not contiguous.\n\n\n\n\n\nhasOrphans(dfg)\n\n\nChecks if the graph is not fully connected, returns true if it is not contiguous.\n\n\n\n\n\nhasOrphans(dfg)\n\n\nChecks if the graph is not fully connected, returns true if it is not contiguous.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Copying-Subgraphs-1","page":"Reference","title":"Copying Subgraphs","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"getSubgraphAroundNode\ngetSubgraph","category":"page"},{"location":"func_ref/#DistributedFactorGraphs.getSubgraphAroundNode","page":"Reference","title":"DistributedFactorGraphs.getSubgraphAroundNode","text":"getSubgraphAroundNode(dfg, node)\ngetSubgraphAroundNode(dfg, node, distance)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors, addToDFG)\n\n\nRetrieve a deep subgraph copy around a given variable or factor. Optionally provide a distance to specify the number of edges should be followed. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\ngetSubgraphAroundNode(dfg, node)\ngetSubgraphAroundNode(dfg, node, distance)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors, addToDFG)\n\n\nRetrieve a deep subgraph copy around a given variable or factor. Optionally provide a distance to specify the number of edges should be followed. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\ngetSubgraphAroundNode(dfg, node)\ngetSubgraphAroundNode(dfg, node, distance)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors, addToDFG)\n\n\nRetrieve a deep subgraph copy around a given variable or factor. Optionally provide a distance to specify the number of edges should be followed. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\ngetSubgraphAroundNode(dfg, node)\ngetSubgraphAroundNode(dfg, node, distance)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors, addToDFG)\n\n\nRetrieve a deep subgraph copy around a given variable or factor. Optionally provide a distance to specify the number of edges should be followed. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\ngetSubgraphAroundNode(dfg, node)\ngetSubgraphAroundNode(dfg, node, distance)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors, addToDFG)\n\n\nRetrieve a deep subgraph copy around a given variable or factor. Optionally provide a distance to specify the number of edges should be followed. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\ngetSubgraphAroundNode(dfg, node)\ngetSubgraphAroundNode(dfg, node, distance)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors)\ngetSubgraphAroundNode(dfg, node, distance, includeOrphanFactors, addToDFG)\n\n\nRetrieve a deep subgraph copy around a given variable or factor. Optionally provide a distance to specify the number of edges should be followed. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.getSubgraph","page":"Reference","title":"DistributedFactorGraphs.getSubgraph","text":"getSubgraph(dfg, variableFactorLabels)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors, addToDFG)\n\n\nGet a deep subgraph copy from the DFG given a list of variables and factors. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\ngetSubgraph(dfg, variableFactorLabels)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors, addToDFG)\n\n\nGet a deep subgraph copy from the DFG given a list of variables and factors. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\ngetSubgraph(dfg, variableFactorLabels)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors, addToDFG)\n\n\nGet a deep subgraph copy from the DFG given a list of variables and factors. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\ngetSubgraph(dfg, variableFactorLabels)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors, addToDFG)\n\n\nGet a deep subgraph copy from the DFG given a list of variables and factors. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\ngetSubgraph(dfg, variableFactorLabels)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors)\ngetSubgraph(dfg, variableFactorLabels, includeOrphanFactors, addToDFG)\n\n\nGet a deep subgraph copy from the DFG given a list of variables and factors. Optionally provide an existing subgraph addToDFG, the extracted nodes will be copied into this graph. By default a new subgraph will be created. Note: By default orphaned factors (where the subgraph does not contain all the related variables) are not returned. Set includeOrphanFactors to return the orphans irrespective of whether the subgraph contains all the variables.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Summaries-1","page":"Reference","title":"Summaries","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"getSummary\ngetSummaryGraph","category":"page"},{"location":"func_ref/#DistributedFactorGraphs.getSummary","page":"Reference","title":"DistributedFactorGraphs.getSummary","text":"Get a summary of the graph (first-class citizens of variables and factors). Returns a AbstractDFGSummary.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.getSummaryGraph","page":"Reference","title":"DistributedFactorGraphs.getSummaryGraph","text":"Get a summary graph (first-class citizens of variables and factors) with the same structure as the original graph. Note this is a copy of the original. Returns a LightDFG{NoSolverParams, DFGVariableSummary, DFGFactorSummary}.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Visualization-and-Plotting-1","page":"Reference","title":"Visualization and Plotting","text":"","category":"section"},{"location":"func_ref/#","page":"Reference","title":"Reference","text":"toDot\ntoDotFile\ndfgplot","category":"page"},{"location":"func_ref/#DistributedFactorGraphs.toDot","page":"Reference","title":"DistributedFactorGraphs.toDot","text":"toDot(dfg)\n\n\nProduces a dot-format of the graph for visualization.\n\n\n\n\n\ntoDot(dfg)\n\n\nProduces a dot-format of the graph for visualization.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#DistributedFactorGraphs.toDotFile","page":"Reference","title":"DistributedFactorGraphs.toDotFile","text":"toDotFile(dfg)\ntoDotFile(dfg, fileName)\n\n\nProduces a dot file of the graph for visualization. Download XDot to see the data\n\nNote\n\nDefault location \"/tmp/dfg.dot\" – MIGHT BE REMOVED\nCan be viewed with the xdot system application.\nBased on graphviz.org\n\n\n\n\n\n","category":"function"},{"location":"example/#Example-1","page":"Example","title":"Example","text":"","category":"section"}]
}
