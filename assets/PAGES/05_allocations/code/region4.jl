x       = rand(10) # testing vector
foo3(x) = view(x, 1:2)

@btime foo3(ref($x))