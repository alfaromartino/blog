x       = [2,3,4]
lazy(x) = sum(@~(x .* x .* log.(x)))

@btime lazy(ref($x))