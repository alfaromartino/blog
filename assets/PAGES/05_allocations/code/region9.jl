x = rand(10) # testing vector

function example1(x)
    output = x[1:2] .+ x[3:4] .* x[5:6]
    
    return output .+ x[7:8] .* x[9:10]
end

@btime example1(ref($x))