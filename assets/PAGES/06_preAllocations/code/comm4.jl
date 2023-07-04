####################################################
#	ALTERNATIVES
####################################################

##########################################################################################################  ###code region10 (((
using LazyArrays

function with_LazyArrays(x; output=similar(x)) 

    for i in eachindex(x)
        temp      = @~ x ./ x[i]
        output[i] = mean(temp)
    end

    return output
end

@btime with_LazyArrays(ref($x));