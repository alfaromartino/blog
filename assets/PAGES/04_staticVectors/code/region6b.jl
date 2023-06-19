Random.seed!(123)    #setting the seed for reproducibility 
x = rand(10)

function barrier_function(x) 
    for _ in 1:100_000
        log.(x) 
    end
end

function example3(x) 
    tuple_x = Tuple(x)
    barrier_function(tuple_x)
end
   
@btime example3(ref($x))  # type-unstable but minimum penalty
#@code_warntype example3(x) #hide