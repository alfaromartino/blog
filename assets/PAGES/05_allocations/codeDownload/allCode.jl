
using BenchmarkTools, Random #hide
ref(x)         = (Ref(x))[] #hide
repl_output(x) = show(IOContext(stdout, :displaysize =>(10,10), :limit=>true), "text/plain", x) #hide 
 
 x       = rand(10) # testing vector
foo1(x) = x[[1,2]]

@btime foo1(ref($x)) 
 
 x       = rand(10) # testing vector
foo2(x) = x[1:2]

@btime foo2(ref($x)) 
 
 x       = rand(10) # testing vector
foo3(x) = view(x, 1:2)

@btime foo3(ref($x)) 
 
 function example1(x)
    for _ in 1:10_000
        foo1(x)
    end
end

@btime example1(ref($x)) 
 
 function example2(x)
    for _ in 1:10_000
        foo2(x)
    end
end

@btime example2(ref($x)) 
 
 function example3(x)
    for _ in 1:10_000
        foo3(x)
    end
end

@btime example3(ref($x)) 
 
 # macro '@view'
foo(x) = @view(x[1:2]) + @view(x[3:4]) 
 
 x = rand(10) # testing vector

function example1(x)
    output = x[1:2] .+ x[3:4] .* x[5:6]
    
    return output .+ x[7:8] .* x[9:10]
end

@btime example1(ref($x)) 
 
 x = rand(10) # testing vector

@views function example2(x)
    output = x[1:2] .+ x[3:4] .* x[5:6]
    
    return output .+ x[7:8] .* x[9:10]
end

@btime example2(ref($x)) 
 
 x = rand(10) # testing vector
function example(x)
    output = 0.0

    @views for i in 1:100
        intermediate_result = x[1:2] .+ x[3:4] .* x[5:6] ./ i
        output              = sum(intermediate_result)
    end

    return output
end

@btime example(ref($x)) 
 
 using LazyArrays
x = rand(10) # testing vector

function example1(x)
    output = 0.0

    @views for i in 1:100
        intermediate_result = @~ x[1:2] .+ x[3:4] .* x[5:6] ./ i
        output              = sum(intermediate_result)
    end

    return output
end

@btime example1(ref($x)) 
 
 using LazyArrays
x = Tuple(rand(10)) # testing vector, converted to a tuple

function example2(x)
    output = 0.0

    for i in 1:100
        intermediate_result = x[1:2] .+ x[3:4] .* x[5:6] ./ i
        output              = sum(intermediate_result)
    end

    return output
end

@btime example2(ref($x)) 
 
 using LazyArrays, StaticArrays
x = @SVector rand(10) # testing vector, converted to a static vector

function example3(x)
    output = 0.0

    for i in 1:100
        intermediate_result = x[SVector(1,2)] .+ x[SVector(3,4)] .* x[SVector(5,6)] ./ i
        output              = sum(intermediate_result)
    end

    return output
end

@btime example3(ref($x)) 
 
 