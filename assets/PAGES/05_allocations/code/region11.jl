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