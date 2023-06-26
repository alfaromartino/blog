x       = rand(10) # testing vector
foo1(x) = x[[1,2]]

@btime foo1(ref($x))