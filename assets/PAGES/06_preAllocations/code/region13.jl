function example1(x; output=similar(x)) 
    for i in eachindex(x)
        temp      = [j / i for j in 1:200]
        output[i] = mean(temp)
    end

    return output
end

@btime example1(ref($x));