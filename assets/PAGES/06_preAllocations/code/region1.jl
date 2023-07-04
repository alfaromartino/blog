using BenchmarkTools, Random, Statistics
ref(x) = (Ref(x))[] #hide

Random.seed!(1234)
x = rand(100)