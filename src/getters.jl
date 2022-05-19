# Locking Multiple Field Access Operation

macro LMFAO(lk::Symbol, objref::Symbol, fields::Symbol...) 
   
    return_syms::Expr = Expr(:tuple, fields...)
    quote 

        lock($lk)
        try
            (; $(fields...)) = $objref[]
            $return_syms
        finally
            unlock($lk)
        end

end |> esc end


macro LMFAO(call::Expr, fields::Symbol...) let reftype::Expr = RefTypeExpr(call.args[1]); quote 
   
    #=
        This `$reftype` thing is a weird way to type the ref but it works.
        It seems to be quick enough of a runtime lookup to enable the type-based optimizations
        that are crucial to performance here.
        The tests give this result
        Typed performance medians: 110-120 ns
        Untyped performance medians: 420 ns (hehe)
        `Base.RefValue` typing perf. medians: 500-505 ns (what even)
    =#
    let (lk::ReentrantLock, ref::$reftype) = $call
        @LMFAO(lk, ref, $(fields...)) 
    end

end |> esc end end


macro LMFAO(lk::Symbol, objref::Symbol, fields::QuoteNode...) quote
 
    @LMFAO($lk, $objref, $((fields .|> qtos)...)) 

end |> esc end


macro LMFAO(call::Expr, fields::QuoteNode...) quote 

    @LMFAO($call, $((fields .|> qtos)...))

end |> esc end