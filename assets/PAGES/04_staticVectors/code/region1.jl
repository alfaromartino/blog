using BenchmarkTools #hide
using DataFrames, Distributions, Random # for creating data
using StaticArrays                      # for implementing the approaches
ref(x) = (Ref(x))[] #hide
repl_output(x) = show(IOContext(stdout, :displaysize =>(10,10), :limit=>true), "text/plain", x) #hide