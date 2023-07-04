function compute_output1(x;  output = similar(x))   
    for i in eachindex(x)
        @. temp   = x / x[i]
        output[i] = mean(temp)
    end

    return output
end

@btime compute_output1(ref($x));