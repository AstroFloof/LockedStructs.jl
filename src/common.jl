@inline qtos(qt::QuoteNode)::Symbol = qt.value
@inline qtos(sym::Symbol)::Symbol = sym
@inline function qtos(x::T)::T where T
    x
end

@inline stoq(sym::Symbol)::QuoteNode = QuoteNode(sym)
@inline stoq(qt::QuoteNode)::QuoteNode = qt
@inline function stoq(x::T)::T where T 
    x 
end

import Base: convert
@inline convert(t::Type{Symbol}, q::QuoteNode) = qtos(q)

const REFTYPE{T} = Base.RefValue{T}
