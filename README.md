# LockedStructs.jl

## Experiments with lock-once-get-many-attribute structs

### Usage:
First define a struct that has a lock on it. For the purposes of demonstration and testing I use a singleton type.
```julia
struct MyStruct <: LockedStruct
    v::String
    MyStruct(; v::String="Hi, I'm a singleton!") = begin
        if !isassigned(struct_ref)
            struct_ref[] = new(v=v)
        end

        return struct_lock, struct_ref
    end
end

struct_lock = ReentrantLock()
struct_ref = Ref{MyStruct}()
```
Now we can either use the bare values of the lock and reference
```julia
v = @LMFAO struct_lock struct_ref value
```
Or use the constructor call itself
```julia
v = @LMFAO MyStruct() value
```
This also works on multiple values (that's the point after all).
Names are separated by spaces, like so.
```julia
v1, v2, v3 = @LMFAO MyBiggerStruct() value1 value2 value3
```
You can even use symbols if you (or your touchy IDE) prefer.
```julia
v1, v2, v3 = @LMFAO MyBiggerStruct() :value1 :value2 :value3
```

---------------

### Hold on, why not use `Base.Threads.Atomic`?
#### First, why would you? The answer is speed.
On the same machine, the struct found in `test/runtests.jl` takes about 100-110 nanoseconds to access three values, while the near-equivalent using `Atomic` values is orders of magnitude faster (around 2 ns using getproperty, 1.6ns using getfield).
```julia
using Base.Threads, BenchmarkTools
struct Test
    a::Atomic{Int}
    b::Atomic{Bool}
    c::Atomic{Int}
end

t = Test(Atomic{Int}(0), Atomic{Bool}(false), Atomic{Int}(2))
rt = Ref{Test}(t)
@benchmark a, b, c = getproperty.($rt, (:a, :b, :c))
```
#### However, it's not as flexible.
`Atomic` only supports primitive types, while this theoretically supports every data type. This is why I was unable to use `Atomic{Symbol}` above as a test of relative performance. Since Symbols are pointers anyway, Int will do as a placeholder.

For fields that could be mutated after accessing from the struct, ~~either find a way not to, or perhaps pass a second lock field beside it to use before mutating it.~~
You can mutate it safely using the mutating `@LMFAO!` macro, which is experimental at the moment. See `test/runtests.jl` for current usage.

#### But what happened to all those poor nanoseconds?
Unfortunately, it seems like all the bottleneck is locking and unlocking. If you were to run
```julia
struct UnsafeTest
    a::Int
    b::Bool
    c::Symbol
end

ut = UnsafeTest(0, false, :("this is slow :("))
rut = Ref{UnsafeTest}(ut)
lk = ReentrancLock()
@benchmark a, b, c = @lock $lk getproperty.($rut, (:a, :b, :c))
```

You'll find performance almost identical to this package. Hopefully there will be improvements to lock performance in future versions of Julia so this package can be more reasonable.

In conclusion, don't use this package for simple structs that use primitive types. This is for everything else!

### Performance Tips
The function call read method has now been optimized such that there is very little overhead from the call of the function anymore. In `test/runtests.jl` the Singleton constructor is `@inline`. When I omit that decorator, it takes double the time, so I recommend doing the same.

### Why LMFAO?

It's a silly acronym, but it stands for Locking Multiple Field Access Operation in this context.

Other syntaxes could be possible, like these:
- overloading `getindex` such that `MyStruct[:value1, :value2]` would work
- functors?

However, Julia's macro system seems to work well enough, considering I managed to optimize access time down to one-tenth of a microsecond.
