# LockedStructs.jl

## Experiments with lock-once-get-many-attribute structs

### Usage:
#### Reading 
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
#### Writing

For fields that could be mutated after accessing from the struct, you can mutate it safely using the mutating `@LMFAO!` macro.

First define a locked mutable struct. Once again, I use a singleton type.
```julia
mutable struct MyMStruct <: LockedStruct
    i::Int
    v::Vector{Int}
    MyMStruct(; i::Int=0, v::Vector{Int}=Int[]) = begin
        if !isassigned(struct_ref)
            struct_ref[] = new(i=i, v=v)
        end

        return struct_lock, struct_ref
    end
end

struct_lock = ReentrantLock()
struct_ref = Ref{MyMStruct}()
```
Now you can say
```julia
@LMFAO! struct_lock struct_ref i += 1
i = @LMFAO struct_lock struct_ref i
@info i
```
and `i` will be `1`. Essentially each expression is mutated at compile time such that symbols are translated to fields of the struct. To that end,
```julia
@LMFAO! struct_lock struct_ref push!(v, 1) i = 9
i, v = @LMFAO struct_lock struct_ref i v
@info i v 
```
and it will be completely valid. `v` is now `Int[1]` and `i` is now `9`.

All the things such as use of function calls to retrieve lock and reference, and the use of symbols still apply. As you can see in `test/runtests.jl` all variances are properly normalized into a properly formed expression.

---------------

### Hold on, why not use `Base.Threads.Atomic`?
#### First, what are the benefits? Speed.
On the same machine, the struct found in `test/runtests.jl` takes about 100-110 nanoseconds to access three values, while the near-equivalent using `Atomic` values is orders of magnitude faster (around 2 ns using `getproperty`, 1.6 ns using `getfield`).
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
`Atomic` only supports primitive types, while this theoretically supports every data type. This is why I was unable to use `Atomic{Symbol}` above as a test of relative performance. Since Symbols are pointers anyway, `Int` will do as a placeholder.

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
lk = ReentrantLock()
@benchmark a, b, c = @lock $lk getproperty.($rut, (:a, :b, :c))
```
you'll find performance almost identical to this package. Hopefully there will be improvements to lock performance in future versions of Julia so this package can be more reasonable.

In conclusion, don't use this package for simple structs that use primitive types. This is for everything else!

### Performance Tips
The function call read method has now been optimized such that there is very little overhead from the call of the function anymore. In `test/runtests.jl` the Singleton constructor is `@inline`. When I omit that decorator, it takes double the time, so I recommend doing the same.

### Why LMFAO?

It's a silly acronym, but it stands for Locking Multiple Field Access Operation in this context.

Other syntaxes could be possible, like these:
- overloading `getindex` such that `MyStruct[:value1, :value2]` would work
- functors?

However, Julia's macro system seems to work well enough for the time being, since I managed to optimize access time down to what it would be if you didn't use the macro.
