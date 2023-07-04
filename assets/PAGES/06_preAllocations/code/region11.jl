function preallocated!(temp, x, i)
    for j in eachindex(x)
        temp[j] = x[j] / x[i]
    end    
end

function compute_output4(x; output=similar(x)) 
    temp = similar(x)

    for i in eachindex(x)
        preallocated!(temp, x, i)
        output[i] = mean(temp)
    end

    return output
end

@btime compute_output4(ref($x));