@inline function norm_quote_or_symbol(qt_or_sym::T) where {T <: Union{QuoteNode, Symbol}}
    T == QuoteNode ? qt_or_sym.value : qt_or_sym
end