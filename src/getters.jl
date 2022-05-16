
# Locking Multiple Field Access Operation
@inline function LMFAO(lk::ReentrantLock, objref::Base.RefValue{T}, fields::NTuple{N, Symbol})::NTuple{N, Any} where {T <: LockedStruct, N}
    return @lock lk NTuple{N, Any}(fields .|> f -> getfield(objref[], f))
end


macro LMFAO(lk::Symbol, objref::Symbol, fields::Symbol...) quote 

    $LMFAO($lk, $objref, $fields) 

end |> esc end


macro LMFAO(call::Expr, fields::Symbol...) let type::Symbol = call.args[1]; quote 
    
    let (lk::ReentrantLock, ref::$REFTYPE{$type}) = $call
        $LMFAO(lk, ref, $fields) 
    end

end |> esc end end


macro LMFAO(lk::Symbol, objref::Symbol, fields::QuoteNode...) quote

    $LMFAO($lk, $objref, $(fields .|> norm_quote_or_symbol)) 

end |> esc end


macro LMFAO(call::Expr, fields::QuoteNode...) let type::Symbol = call.args[1]; quote 
    
    let (lk::ReentrantLock, objref::$REFTYPE{$type}) = $call
        $LMFAO(lk, objref, $(fields .|> norm_quote_or_symbol)) 
    end 

end |> esc end end