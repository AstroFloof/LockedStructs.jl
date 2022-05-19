using .Meta: isoperator

function LMFAO!_gen(expr::Expr)::Expr

    let field::QuoteNode

        if expr.head |> isoperator

            field = stoq(expr.args[1])
            Expr(
                expr.head,
                Expr(
                    :.,
                    :obj,
                    field
                ),
                stoq(eval(expr.args[2]))
            )

        elseif expr.head === :call 

            field = stoq(expr.args[2])
            Expr(
                :call,
                expr.args[1],
                Expr(
                    :.,
                    :obj,
                    field
                ),
                expr.args[3]
            )

        else

            ex = ArgumentError("If you got here, good job. Please open an issue at https://github.com/AstroFloof/LockedStructs.jl")
            @error exception=ex
            throw(ex)

        end
    end
end
    

macro LMFAO!(lk::Symbol, objref::Symbol, fields::Expr...) 
    generated_codes::NTuple{length(fields), Expr} = NTuple{length(fields), Expr}(
        LMFAO!_gen(f) for f in fields
    )
    quote 

        @lock $lk let obj = $objref[]
            $(generated_codes...)
        end

end |> esc end


macro LMFAO!(call::Expr, fields::Expr...) let objtype::Expr = RefTypeExpr(call.args[1]); quote 

    let (lk::ReentrantLock, ref::$objtype) = $call
        @LMFAO!(lk, ref, $(fields...))
    end

end |> esc end end