
using BenchmarkTools, Random, Statistics
ref(x) = (Ref(x))[] #hide

Random.seed!(1234)
x = rand(100) 
 
 ####################################################
#	SINGLE ELEMENTS DO NOT ALLOCATE
#################################################### 
 
 function example1(x)
    output = similar(x)    
    
    for i in eachindex(x)
        temp      = x[1] / x[i]
        output[i] = mean(temp)
    end

    return output
end

@btime example1(ref($x)); 
 
 function example2(x; output=similar(x))     
    for i in eachindex(x)
        temp      = x ./ x[i]
        output[i] = mean(temp)
    end

    return output
end

@btime example2(ref($x)); 
 
 ####################################################
#	PRE ALLOCATING TEMP
#################################################### 
 
 function compute_output1(x; output=similar(x)) 
    temp = similar(x)

    for i in eachindex(x)
        temp      = x ./ x[i]
        output[i] = mean(temp)
    end

    return output
end

@btime compute_output1(ref($x)); 
 
 function compute_output2(x; output=similar(x)) 
    temp = similar(x)

    for i in eachindex(x)
        temp      .= x ./ x[i]
        output[i]  = mean(temp)
    end

    return output
end

@btime compute_output2(ref($x)); 
 
 function compute_output3(x; output=similar(x)) 
    temp = similar(x)

    for i in eachindex(x)
        @. temp   = x / x[i]
        output[i] = mean(temp)
    end

    return output
end

@btime compute_output3(ref($x)); 
 
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
 
 ####################################################
#	RELEVANCE
#################################################### 
 
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
 
 function intermediate_result(x, output, temp)
    for i in eachindex(x)
        @. temp   = x / x[i]
        output[i] = mean(temp)
    end

    return output
end

function final_result(x)
    output = similar(x)
    temp   = similar(x)
    [intermediate_result(x, output, temp) for i in 1:100]
end

@btime final_result(ref($x)); 
 
 intermediate_result(x) = mean.(x ./ x[i] for i in eachindex(x))
final_result(x)        = [intermediate_result(x) for _ in 1:100]

@btime final_result(ref($x)) 
 
 Random.seed!(1234)
x = rand(10_000) 
 
 Random.seed!(1234)
x = rand(10_000)

intermediate_result(x) = mean.(x ./ x[i] for i in eachindex(x))
final_result(x)        = [intermediate_result(x) for _ in 1:100]

@btime final_result(ref($x)) 
 
 Random.seed!(1234)
x = rand(10_000)
    
function intermediate_result(x, output, temp)
    for i in eachindex(x)
        @. temp   = x / x[i]
        output[i] = mean(temp)
    end

    return output
end

function final_result(x)
    output = similar(x)
    temp   = similar(x)
    [intermediate_result(x, output, temp) for i in 1:100]
end

@btime final_result(ref($x)); 
 
 