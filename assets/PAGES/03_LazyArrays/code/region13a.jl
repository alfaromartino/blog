x        = [2,3,4]
eager(x) = sum(x .* x .* log.(x))

@btime eager(ref($x))