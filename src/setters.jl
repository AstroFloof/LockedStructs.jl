include("ops.jl")
include("common.jl")
using .Meta: isoperator

function LMFAO!(lk::ReentrantLock, objref::Base.RefValue{T}, mut_ops::Expr...) where T <: LockedStruct

    @assert typeof(lk) === ReentrantLock

    @lock lk let obj::T = objref[]

        for op in mut_ops

            var::Symbol = norm_quote_or_symbol(op.args[1])
            expr = eval(op.args[2])

            if op.head === :(=)

                setproperty!(obj, var, expr)

            elseif op.head === :call 

                ex = ArgumentError("Use of function calls like \"($op)\" without explicit assigment to a field is not supported yet.")
                @error exception=ex
                throw(ex)

            elseif op.head |> isoperator

                f::Function = get(OP_TABLE, op.head, missing)

                if f |> ismissing
                    ex = ArgumentError("Use of the operator \"($op.head)\" on a field is not supported.")
                    @error exception=ex
                    throw(ex)
                end

                modifyfield!(obj, var, f, expr)
            
            else
                ex = ArgumentError("If you got here, good job. Please open an issue at https://github.com/AstroFloof/LockedStructs.jl")
                @error exception=ex
                throw(ex)
    end end end
    return nothing
end

macro LMFAO!(lk::Symbol, objref::Symbol, fields::Expr...) quote 

    LockedStructs.LMFAO!($lk, $objref, $fields...) 

end |> esc end

macro LMFAO!(call::Expr, fields::Expr...) quote 

    LockedStructs.LMFAO!(eval($call)..., $fields...) 

end |> esc end