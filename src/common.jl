
@inline @generated qtos(x) = x === QuoteNode ? :(x.value)      : :(x)
@inline @generated stoq(x) = x === Symbol    ? :(QuoteNode(x)) : :(x)
@inline RefTypeExpr(ref::Symbol)::Expr = Expr(
    :curly, 
    Expr(
        :., 
        :Base, 
        QuoteNode(:RefValue)
    ), 
    ref
)
