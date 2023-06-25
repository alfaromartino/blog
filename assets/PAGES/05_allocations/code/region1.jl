using BenchmarkTools, Random #hide
ref(x)         = (Ref(x))[] #hide
repl_output(x) = show(IOContext(stdout, :displaysize =>(10,10), :limit=>true), "text/plain", x) #hide