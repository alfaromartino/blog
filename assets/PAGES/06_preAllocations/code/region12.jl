function with_tuple(x; output=similar(x)) 

    for i in eachindex(x)
        temp      = (i-1, i+1)
        output[i] = mean(temp)
    end

    return output
end

@btime with_tuple(ref($x));