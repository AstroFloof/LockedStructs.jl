@show @elapsed using LockedStructs
@show @elapsed using Test
@show @elapsed using BenchmarkTools: @benchmark
@show @elapsed using InteractiveUtils: @code_lowered


macro LS_GET_TEST(expr::Expr) quote
    
    let (n::Int, b::Bool, sy::Symbol) = @time $expr
        @test n == 0
        @test !b
        @test sy === :hi
        @info '\n' n b sy
        println()
    end
        
    @info @code_lowered $expr
    println()

end |> esc end

@testset "Getters" begin 

    @info "Starting tests and benchmarks for get methods"

    struct Singleton <: LockedStruct # example
        # what's in here doesn't matter
        number::Int
        bool::Bool
        symbol::Symbol
        @inline Singleton(; number::Int=0, bool::Bool=false, symbol::Symbol=:hi) = begin
            if !isassigned(singleton)
                @lock sng_lock singleton[] = new(number, bool, symbol)
            end
            return sng_lock, singleton
        end
    end

    singleton = Ref{Singleton}()
    sng_lock = ReentrantLock()


    # Use of bare values to pass lock and singleton
    locket, sg = Singleton()
    @info locket sg
    @LS_GET_TEST @LMFAO locket sg number bool symbol
    @LS_GET_TEST @LMFAO locket sg :number :bool :symbol

    # Use of call to pass lock and singleton
    @LS_GET_TEST @LMFAO Singleton() number bool symbol
    @LS_GET_TEST @LMFAO Singleton() :number :bool :symbol


    @info "Running benchmarks"
    display_bench(b) = begin display(b); println() end
    display_bench.(
        [
            @benchmark @LMFAO $locket $sg number bool symbol
            @benchmark @LMFAO $locket $sg :number :bool :symbol
            @benchmark @LMFAO Singleton() number bool symbol
            @benchmark @LMFAO Singleton() :number :bool :symbol

        ]
    )    

    @info "Tests and benchmarks for getter methods are finished."
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
        @LMFAO! MSingleton() number = 1  bool = true  symbol = :hello
        n, b, sy = @LMFAO MSingleton() number bool symbol
        n == 1 && b && sy === :hello
    end

    @test begin
        @LMFAO! MSingleton() :number = 1  :bool = true  :symbol = :hello
        n, b, sy = @LMFAO MSingleton() number bool symbol
        n == 1 && b && sy === :hello
    end

    @test begin
        @LMFAO! MSingleton() :number += 1
        n, b, sy = @LMFAO MSingleton() number bool symbol
        n == 2 && b && sy === :hello
    end

end