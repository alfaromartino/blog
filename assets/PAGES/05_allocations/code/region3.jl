x       = rand(10) # testing vector
foo2(x) = x[1:2]

@btime foo2(ref($x))