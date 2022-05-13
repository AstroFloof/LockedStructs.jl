@show @elapsed using LockedStructs
@show @elapsed using Test

@testset "Getters" begin 
    ncalls = 0
    struct Singleton <: LockedStruct # example
        # what's in here doesn't matter
        number::Int
        bool::Bool
        symbol::Symbol
        Singleton(; number::Int=0, bool::Bool=false, symbol::Symbol=:hi) = begin
            if !isassigned(singleton)
                @lock sng_lock singleton[] = new(number, bool, symbol)
            end
            return sng_lock, singleton
        end
    end

    singleton = Ref{Singleton}()
    sng_lock = ReentrantLock()

    # Use of call to pass lock and singleton
    n, b, sy = @LMFAO Singleton() number bool symbol

    @test n == 0
    @test !b
    @test sy === :hi
    @info '\n' n b sy

    # Use of bare values to pass lock and singleton
    locket, sg = Singleton()
    n, b, sy = @LMFAO locket sg :number :bool :symbol
    @test n == 0
    @test !b
    @test sy === :hi
    @info locket sg
    @info '\n' n b sy
end

@testset "Setters" begin

    mutable struct MSingleton <: LockedStruct # example
        # what's in here doesn't matter
        number::Int
        bool::Bool
        symbol::Symbol
        MSingleton(; number::Int=0, bool::Bool=false, symbol::Symbol=:hi) = begin
            if !isassigned(singleton)
                @lock sng_lock singleton[] = new(number, bool, symbol)
            end
            return sng_lock, singleton
        end
    end

    singleton = Ref{MSingleton}()
    sng_lock = ReentrantLock()

    @test_throws ArgumentError LockedStructs.LMFAO!(MSingleton()..., :(1 + 1))

    @test begin
        @LMFAO! MSingleton() number = 1 bool = true symbol = :hello
        n, b, sy = @LMFAO MSingleton() number bool symbol
        n == 1 && b && sy === :hello
    end

    @test begin
        @LMFAO! MSingleton() :number = 1 :bool = true :symbol = :hello
        n, b, sy = @LMFAO MSingleton() number bool symbol
        n == 1 && b && sy === :hello
    end

    @test begin
        @LMFAO! MSingleton() :number += 1
        n, b, sy = @LMFAO MSingleton() number bool symbol
        n == 2 && b && sy === :hello
    end

end