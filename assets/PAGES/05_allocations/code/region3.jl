x       = rand(10) # vector for testing
foo2(x) = x[1:2]

@btime foo2(ref($x))