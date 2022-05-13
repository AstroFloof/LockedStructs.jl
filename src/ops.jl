const OP_TABLE = Dict{Symbol, Function}(
    # addition
    :+= => +,
    :-= => -,

    # multiplicative
    :*= => *,
    :^= => ^,

    # divisive
    :/= => /,
    ://= => //,
    :\= => \,
    :÷= => ÷,
    :%= => %,

    # bitwise
    :&= => &,
    :|= => |,
    :⊻= => ⊻,
    :<<= => <<,
    :>>= => >>,
    :>>>= => >>>,

    # broadcasted addition
    :.+= => .+,
    :.-= => .-,

    # broadcasted multiplicative
    :.*= => .*,
    :.^= => .^,

    # broadcasted divisive
    :./= => ./,
    :.//= => .//,
    :.\= => .\,
    :.÷= => .÷,
    :.%= => .%,

    # broadcasted bitwise
    :.&= => .&,
    :.|= => .|,
    :.⊻= => .⊻,
    :.<<= => .<<,
    :.>>= => .>>,
    :.>>>= => .>>>,
)