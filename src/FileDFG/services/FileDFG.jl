
"""
    $(SIGNATURES)
Save a DFG to a folder. Will create/overwrite folder if it exists.

# Example
```julia
using DistributedFactorGraphs, IncrementalInference
# Create a DFG - can make one directly, e.g. GraphsDFG{NoSolverParams}() or use IIF:
dfg = initfg()
# ... Add stuff to graph using either IIF or DFG:
v1 = addVariable!(dfg, :a, ContinuousScalar, labels = [:POSE], solvable=0)
# Now save it:
saveDFG(dfg, "/tmp/saveDFG")
```
"""
function saveDFG(dfg::AbstractDFG, folder::String; compress::Symbol=:gzip)
    variables = getVariables(dfg)
    factors = getFactors(dfg)
    varFolder = "$folder/variables"
    factorFolder = "$folder/factors"
    # Folder preparations
    if !isdir(folder)
        @info "Folder '$folder' doesn't exist, creating..."
        mkpath(folder)
    end
    !isdir(varFolder) && mkpath(varFolder)
    !isdir(factorFolder) && mkpath(factorFolder)
    # Clearing out the folders
    map(f -> rm("$varFolder/$f"), readdir(varFolder))
    map(f -> rm("$factorFolder/$f"), readdir(factorFolder))
    # Variables
    for v in variables
        vPacked = packVariable(dfg, v)
        io = open("$varFolder/$(v.label).json", "w")
        JSON2.write(io, vPacked)
        close(io)
    end
    # Factors
    for f in factors
        fPacked = packFactor(dfg, f)
        io = open("$folder/factors/$(f.label).json", "w")
        JSON2.write(io, fPacked)
        close(io)
    end

    # compress newly saved folder, skip if not supported format
    !(compress in [:gzip]) && return
    savepath = folder[end] == '/' ? folder[1:end-1] : folder
    savedir = dirname(savepath)
    savename = splitpath(string(savepath))[end]
    @assert savename != ""
    # temporarily change working directory to get correct zipped path
    here = Base.pwd()
    Base.cd(savedir)
    run(`tar -zcf $savepath.tar.gz $savename`)
    Base.rm(savename, recursive=true)
    Base.cd(here)
end

"""
    $(SIGNATURES)
Load a DFG from a saved folder. Always provide the IIF module as the second
parameter.

# Example
```julia
using DistributedFactorGraphs, IncrementalInference
# Create a DFG - can make one directly, e.g. GraphsDFG{NoSolverParams}() or use IIF:
dfg = initfg()
# Load the graph
loadDFG("/tmp/savedgraph.tar.gz", IncrementalInference, dfg)
loadDFG("/tmp/savedgraph", IncrementalInference, dfg) # alternative
# Use the DFG as you do normally.
ls(dfg)
```
"""
function loadDFG(dst::String, iifModule, dfgLoadInto::G; loaddir=joinpath("/","tmp","caesar","random")) where G <: AbstractDFG
    # Check if zipped destination (dst)
    folder = Base.isdir(dst) ? dst : dst*".tar.gz"
    sdst = split(dst, '.')
    if sdst[end] == "gz" && sdst[end-1] == "tar"
      Base.mkpath(loaddir)
      folder = joinpath(loaddir, splitpath(string(sdst[end-2]))[end] )
      @info "loadDF detected a gzip tarball -- unpacking via $folder now..."
      Base.rm(folder, recursive=true, force=true)
      # unzip the tar file
      run(`tar -zxf $dst -C $loaddir`)
    end
    variables = DFGVariable[]
    factors = DFGFactor[]
    varFolder = "$folder/variables"
    factorFolder = "$folder/factors"
    # Folder preparations
    !isdir(folder) && error("Can't load DFG graph - folder '$folder' doesn't exist")
    !isdir(varFolder) && error("Can't load DFG graph - folder '$folder' doesn't exist")
    !isdir(factorFolder) && error("Can't load DFG graph - folder '$folder' doesn't exist")

    varFiles = readdir(varFolder)
    factorFiles = readdir(factorFolder)
    for varFile in varFiles
        io = open("$varFolder/$varFile")
        packedData = JSON2.read(io, Dict{String, Any})
        push!(variables, unpackVariable(dfgLoadInto, packedData))
    end
    @info "Loaded $(length(variables)) variables - $(map(v->v.label, variables))"
    @info "Inserting variables into graph..."
    # Adding variables
    map(v->addVariable!(dfgLoadInto, v), variables)

    for factorFile in factorFiles
        io = open("$factorFolder/$factorFile")
        packedData = JSON2.read(io, Dict{String, Any})
        push!(factors, unpackFactor(dfgLoadInto, packedData, iifModule))
    end
    @info "Loaded $(length(variables)) factors - $(map(f->f.label, factors))"
    @info "Inserting factors into graph..."
    # # Adding factors
    map(f->addFactor!(dfgLoadInto, f._variableOrderSymbols, f), factors)

    # Finally, rebuild the CCW's for the factors to completely reinflate them
    @info "Rebuilding CCW's for the factors..."
    for factor in factors
        iifModule.rebuildFactorMetadata!(dfgLoadInto, factor)
    end

    # PATCH - To update the fncargvID for factors, it's being cleared somewhere in rebuildFactorMetadata.
    # TEMPORARY
    # TODO: Remove in future
    map(f->solverData(f).fncargvID = f._variableOrderSymbols, getFactors(dfgLoadInto))

    return dfgLoadInto
end
