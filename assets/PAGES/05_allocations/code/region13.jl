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