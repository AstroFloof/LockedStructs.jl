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
        
    @info @macroexpand $expr
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

macro LS_SET_TEST(expr::Expr) quote
    
    @info @macroexpand1 $expr
    $expr
    @LMFAO MSingleton() number bool symbol mut

end |> esc end


@testset "Setters" begin

    mutable struct MSingleton <: LockedStruct # example
        # what's in here doesn't matter
        number::Int
        bool::Bool
        symbol::Symbol
        mut::Vector{Int}
        @inline MSingleton(; number::Int=0, bool::Bool=false, symbol::Symbol=:hi, mut::Vector{Int}=Int[]) = begin
            if !isassigned(singleton)
                @lock sng_lock singleton[] = new(number, bool, symbol, mut)
            end
            return sng_lock, singleton
        end
    end

    singleton = Ref{MSingleton}()
    sng_lock = ReentrantLock()

    @test begin
        n, b, sy, m = @LS_SET_TEST @LMFAO! MSingleton() number = 1  bool = true  symbol = :hello
        @info '\n' n, b, sy, m
        n == 1 && b && sy === :hello
    end

    @test begin
        n, b, sy, m = @LS_SET_TEST @LMFAO! MSingleton() :number = 1  :bool = true  :symbol = :hello
        @info '\n' n, b, sy, m
        n == 1 && b && sy === :hello
    end

    @test begin
        n, b, sy, m = @LS_SET_TEST @LMFAO! MSingleton() :number += 1
        @info '\n' n, b, sy, m
        n == 2 && b && sy === :hello
    end

    @test begin
        n, b, sy, m = @LS_SET_TEST @LMFAO! MSingleton() push!(mut, 1)
        @info '\n' n, b, sy, m
        length(m) == 1 && m[1] == 1
    end

    locket, sg = MSingleton()

    @test begin
        n, b, sy, m = @LS_SET_TEST @LMFAO! locket sg number = 1  bool = true  symbol = :hello
        @info '\n' n, b, sy, m
        n == 1 && b && sy === :hello
    end

    @test begin
        n, b, sy, m = @LS_SET_TEST @LMFAO! locket sg :number = 1  :bool = true  :symbol = :hello
        @info '\n' n, b, sy, m
        n == 1 && b && sy === :hello
    end

    @test begin
        n, b, sy, m = @LS_SET_TEST @LMFAO! locket sg :number += 1
        @info '\n' n, b, sy, m
        n == 2 && b && sy === :hello
    end

    should_not_compile = quote @LMFAO! MSingleton() 1 + 1 end

    @test_throws LoadError @eval $should_not_compile

    @info "Running benchmarks"
    display_bench(b) = begin display(b); println() end
    display_bench.(
        [
            @benchmark @LMFAO! $locket $sg   number = 1   bool = true   symbol = :hello
            @benchmark @LMFAO! $locket $sg  :number = 1  :bool = true  :symbol = :hello
            @benchmark @LMFAO! MSingleton()  number = 1   bool = true   symbol = :hello
            @benchmark @LMFAO! MSingleton() :number = 1  :bool = true  :symbol = :hello
            @benchmark @LMFAO! $locket $sg  :number += 1
            @benchmark @LMFAO! MSingleton()
        ]
    )

end