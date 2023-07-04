function example2(x; output=similar(x))     
    for i in eachindex(x)
        temp      = x ./ x[i]
        output[i] = mean(temp)
    end

    return output
end

@btime example2(ref($x));