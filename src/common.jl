@generated function norm_quote_or_symbol(qt_or_sym)
    if qt_or_sym == Symbol
        return quote qt_or_sym end 
    elseif qt_or_sym == QuoteNode
        return quote qt_or_sym.value end
    else
        throw(ArgumentError("Unsupported argument"))
    end
end