x       = rand(10) # vector for testing
foo1(x) = x[[1,2]]

@btime foo1(ref($x))