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