"""
$(TYPEDEF)
"""
mutable struct GenericFunctionNodeData{T, S}
  fncargvID::Array{Int,1}
  eliminated::Bool
  potentialused::Bool
  edgeIDs::Array{Int,1}
  frommodule::S #Union{Symbol, AbstractString}
  fnc::T
  multihypo::String # likely to moved when GenericWrapParam is refactored
  certainhypo::Vector{Int}
  GenericFunctionNodeData{T, S}() where {T, S} = new{T,S}()
  GenericFunctionNodeData{T, S}(x1, x2, x3, x4, x5::S, x6::T, x7::String="", x8::Vector{Int}=Int[]) where {T, S} = new{T,S}(x1, x2, x3, x4, x5, x6, x7, x8)
  GenericFunctionNodeData(x1, x2, x3, x4, x5::S, x6::T, x7::String="", x8::Vector{Int}=Int[]) where {T, S} = new{T,S}(x1, x2, x3, x4, x5, x6, x7, x8)
  # GenericFunctionNodeData(x1, x2, x3, x4, x5::S, x6::T, x7::String) where {T, S} = new{T,S}(x1, x2, x3, x4, x5, x6, x7)
end

"""
    $(SIGNATURES)
Fundamental structure for a DFG factor.
"""
mutable struct DFGFactor{T, S} <: DFGNode
    label::Symbol
    data::GenericFunctionNodeData{T, S}
    _internalId::Int64
    DFGFactor{T, S}(label::Symbol) where {T, S} = new{T, S}(label, GenericFunctionNodeData{T, S}(), 0)
    DFGFactor{T, S}(label::Symbol, _internalId::Int64) where {T, S} = new{T, S}(label, GenericFunctionNodeData{T, S}(), _internalId)
end
