Random.seed!(1234)
x = rand(10_000)
    
function intermediate_result(x, output, temp)
    for i in eachindex(x)
        @. temp   = x / x[i]
        output[i] = mean(temp)
    end

    return output
end

function final_result(x)
    output = similar(x)
    temp   = similar(x)
    [intermediate_result(x, output, temp) for i in 1:100]
end

@btime final_result(ref($x));