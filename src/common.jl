@inline function norm_quote_or_symbol(qt_or_sym::T)::Symbol where {T <: Union{QuoteNode, Symbol}}
    T == QuoteNode ? qt_or_sym.value : qt_or_sym
end

const OP_TABLE = Dict{Symbol, Function}(
    # addition
    :+= => +,
    :-= => -,

    # multiplicative
    :*= => *,
    :^= => ^,

    # divisive
    :/= => /,
    ://= => //,
    :\= => \,
    :÷= => ÷,
    :%= => %,

    # bitwise
    :&= => &,
    :|= => |,
    :⊻= => ⊻,
    :<<= => <<,
    :>>= => >>,
    :>>>= => >>>,

    # broadcasted addition
    :.+= => .+,
    :.-= => .-,

    # broadcasted multiplicative
    :.*= => .*,
    :.^= => .^,

    # broadcasted divisive
    :./= => ./,
    :.//= => .//,
    :.\= => .\,
    :.÷= => .÷,
    :.%= => .%,

    # broadcasted bitwise
    :.&= => .&,
    :.|= => .|,
    :.⊻= => .⊻,
    :.<<= => .<<,
    :.>>= => .>>,
    :.>>>= => .>>>,
)

const REFTYPE{T} = Base.RefValue{T}

import Base: |>
@inline |>(x::Tuple{Vararg{Any}}, f::Function) = f(x...)
@inline <|(f::Function, x::Tuple{Vararg{Any}}) = f(x...)
