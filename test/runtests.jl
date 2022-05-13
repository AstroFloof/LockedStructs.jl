@show @elapsed using LockedStructs
@show @elapsed using Test

@testset begin 
    ncalls = 0

    struct Singleton <: LockedStruct # example
        # what's in here doesn't matter
        number::Int
        bool::Bool
        symbol::Symbol
        Singleton(; number::Int=0, bool::Bool=false, symbol::Symbol=:hi) = begin
            if !isassigned(singleton)
                singleton[] = new(number, bool, symbol)
                global ncalls
                ncalls += 1
            end
            
            return sng_lock, singleton
        end
    end

    global const singleton = Ref{Singleton}()
    global const sng_lock = ReentrantLock()

    @test ncalls == 0
    Singleton()
    @test ncalls == 1

    # Use of call to pass lock and singleton
    n, b, sy = @LMFAO Singleton() number bool symbol
    global ncalls
    @test ncalls == 1
    @test n == 0
    @test !b
    @test sy === :hi
    @info '\n' n b sy

    # Use of bare values to pass lock and singleton
    locket, sg = Singleton()
    @test ncalls == 1
    n, b, sy = @LMFAO locket sg :number :bool :symbol
    @test n == 0
    @test !b
    @test sy === :hi
    @info locket sg
    @info '\n' n b sy

end