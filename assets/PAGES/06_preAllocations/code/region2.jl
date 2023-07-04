function example1(x)
    output = similar(x)    
    
    for i in eachindex(x)
        temp      = x[1] / x[i]
        output[i] = mean(temp)
    end

    return output
end

@btime example1(ref($x));