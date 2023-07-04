function intermediate_result(x; output=similar(x))
    temp = similar(x)

    for i in eachindex(x)
        @. temp   = x / x[i]
        output[i] = mean(temp)
    end

    return output
end

final_result(x) = [intermediate_result(x) for _ in 1:100]

@btime final_result(ref($x));