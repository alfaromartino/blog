function compute_output3(x; output=similar(x)) 
    temp = similar(x)

    for i in eachindex(x)
        @. temp   = x / x[i]
        output[i] = mean(temp)
    end

    return output
end

@btime compute_output3(ref($x));