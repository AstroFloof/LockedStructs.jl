module LockedStructs
    export LockedStruct
    export @LMFAO
    # export @LMFAO!

    abstract type LockedStruct end

    # Locking Multiple Field Access Operation
    function LMFAO(lk::ReentrantLock, objref::Base.RefValue{T}, fields::Symbol...) where T <: LockedStruct

        @assert typeof(lk) === ReentrantLock

        @lock lk let obj::T = objref[]
            NTuple{length(fields), Any}(getfield(obj, f) for f in fields)
        end

    end

    macro LMFAO(lk::Symbol, objref::Symbol, fields::Symbol...) quote 

        LockedStructs.LMFAO($lk, $objref, $fields...) 

    end |> esc end

    macro LMFAO(call::Expr, fields::Symbol...) quote 

        LockedStructs.LMFAO(eval($call)..., $fields...) 

    end |> esc end

    macro LMFAO(lk::Symbol, objref::Symbol, fields::QuoteNode...) quote

        LockedStructs.LMFAO($lk, $objref, (f.value for f in $fields)...) 

    end |> esc end

    macro LMFAO(call::Expr, fields::QuoteNode...) quote 

        LockedStructs.LMFAO(eval($call)..., (f.value for f in $fields)...) 

    end |> esc end

    function LMFAO!(lk::ReentrantLock, objref::Base.RefValue{T}, mut_ops::Expr...) where T <: LockedStruct

        @assert typeof(lk) === ReentrantLock

        @lock lk let obj::T = objref[]

            @info "Before" obj
            for op in mut_ops
                if op.head === :(=)
                    setproperty!(obj, op.args[1], @eval $op.args[2])
                elseif op.head === :call 
                    nothing # TODO
                end
            end 
            @info "After" obj
        end
        nothing
    end
end