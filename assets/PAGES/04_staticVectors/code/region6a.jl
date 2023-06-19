Random.seed!(123)    #setting the seed for reproducibility 
x = rand(10)

function example1(x) 
    tuple_x = Tuple(x)

    for _ in 1:100_000
        log.(tuple_x) 
    end
end

@btime example1(ref($x))    # type-unstable
#@code_warntype example1(x) #hide