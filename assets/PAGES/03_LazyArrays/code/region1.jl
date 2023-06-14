using DataFrames, Distributions, Random, BenchmarkTools
using LazyArrays
ref(x) = (Ref(x))[] #hide