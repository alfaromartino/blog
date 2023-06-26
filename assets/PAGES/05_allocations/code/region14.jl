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