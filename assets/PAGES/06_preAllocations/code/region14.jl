function preallocated!(temp, i)
    for j in 1:200
        temp[j] = j / i 
    end
end

function example2(x; output=similar(x)) 
temp = Vector{Float64}(undef,200)

    for i in eachindex(x)
        preallocated!(temp,i)
        output[i] = mean(temp)
    end

    return output
end

@btime example2(ref($x));