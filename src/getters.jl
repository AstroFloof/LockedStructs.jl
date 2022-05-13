include("common.jl")

# Locking Multiple Field Access Operation
@inline function LMFAO(lk::ReentrantLock, objref::Base.RefValue{T}, fields::Symbol...) where T <: LockedStruct
    return @lock lk let obj::T = objref[]
        NTuple{length(fields), Any}(getfield(obj, f) for f in fields)
    end
end

macro LMFAO(lk::Symbol, objref::Symbol, fields::Symbol...) quote 

    $LMFAO($lk, $objref, $fields...) 

end |> esc end

macro LMFAO(call::Expr, fields::Symbol...) quote 
    
    $LMFAO($call..., $fields...) 

end |> esc end

macro LMFAO(lk::Symbol, objref::Symbol, fields::QuoteNode...) quote

    $LMFAO($lk, $objref, $norm_quote_or_symbol.($fields)...) 

end |> esc end

macro LMFAO(call::Expr, fields::QuoteNode...) quote 

    $LMFAO($call..., $norm_quote_or_symbol.($fields)...) 

end |> esc end