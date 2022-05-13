module LockedStructs
    export LockedStruct
    export @LMFAO
    export @LMFAO!

    abstract type LockedStruct end

    include("getters.jl")
    include("setters.jl")
    
end