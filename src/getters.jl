include("common.jl")

# Locking Multiple Field Access Operation
@inline function LMFAO(lk::ReentrantLock, objref::Base.RefValue{T}, fields::NTuple{N, Symbol})::NTuple{N, Any} where {T <: LockedStruct, N}
    return @lock lk let obj::T = objref[]
        NTuple{N, Any}(getfield(obj, f) for f in fields)
    end
end

macro LMFAO(lk::Symbol, objref::Symbol, fields::Symbol...) quote 

    $LMFAO($lk, $objref, $fields) 

end |> esc end

macro LMFAO(call::Expr, fields::Symbol...) let type::Symbol = call.args[1]; quote 
    
    lk::ReentrantLock, ref::Base.RefValue{$type} = $call
    $LMFAO(lk, ref, $fields) 

end |> esc end end

macro LMFAO(lk::Symbol, objref::Symbol, fields::QuoteNode...) quote

    $LMFAO($lk, $objref, $(norm_quote_or_symbol.(fields))) 

end |> esc end

macro LMFAO(call::Expr, fields::QuoteNode...) let type::Symbol = call.args[1]; quote 
    
    lk::ReentrantLock, ref::Base.RefValue{$type} = $call
    $LMFAO(lk, ref, $(norm_quote_or_symbol.(fields))) 

end |> esc end end