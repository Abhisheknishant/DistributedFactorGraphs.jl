import Base: ==

"""
    $(TYPEDEF)
GeneralBigDataEntry is a generic multipurpose data entry that creates a unique
reproducible key using userId_robotId_sessionId_variableId_key.
"""
mutable struct GeneralBigDataEntry <: AbstractBigDataEntry
    key::Symbol
    originalKey::Symbol
    createdTimestamp::DateTime
    lastUpdatedTimestamp::DateTime
    mimeType::String
end

## TODO: Move this
function ==(a::GeneralBigDataEntry, b::GeneralBigDataEntry)
    return a.key == b.key &&
        a.originalKey == b.originalKey &&
        a.mimeType == b.mimeType &&
        Dates.value(a.createdTimestamp - b.createdTimestamp) < 1000 &&
        Dates.value(a.lastUpdatedTimestamp - b.lastUpdatedTimestamp) < 1000 #1 second
end


# Clean up and move this.
"""
    $(SIGNATURES)
Generates a unique key for the entry - userId_robotId_sessionId_variable_key.
Simple.
"""
function uniqueKey(dfg::G, v::V, key::Symbol) where {G <: AbstractDFG, V <: AbstractDFGVariable}
    key = join(String.([dfg.userId, dfg.robotId, dfg.sessionId, label(v), String(key)]), "_")
    return Symbol(key)
end

GeneralBigDataEntry(key::Symbol,
                    originalKey::Symbol;
                    mimeType::String="application/octet-stream") =
                        GeneralBigDataEntry(key, originalKey, now(), now(), mimeType)

function GeneralBigDataEntry(dfg::G,
                             var::V,
                             originalKey::Symbol;
                             mimeType::String="application/octet-stream") where {G <: AbstractDFG, V <: AbstractDFGVariable}
    return GeneralBigDataEntry(uniqueKey(dfg, var, originalKey),
                               originalKey,
                               mimeType=mimeType)
end

# Types <: AbstractBigDataEntry
"""
    $(TYPEDEF)
BigDataEntry in MongoDB.
"""
struct MongodbBigDataEntry <: AbstractBigDataEntry
    key::Symbol
    oid::NTuple{12, UInt8} #mongodb object id
    #maybe other fields such as:
    #flags::Bool ready, valid, locked, permissions
    #MIMEType::Symbol
end


"""
    $(TYPEDEF)
BigDataEntry in a file.
"""
struct FileBigDataEntry <: AbstractBigDataEntry
    key::Symbol
    filename::String
end
