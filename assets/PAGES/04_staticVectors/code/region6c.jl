Random.seed!(123)    #setting the seed for reproducibility 
x = rand(10)

function example2(x, ::Val{N}) where {N}
    tuple_x = NTuple{N,eltype(x)}(x)   

    for _ in 1:100_000
        log.(tuple_x) 
    end
end

@btime example2(ref($x), Val(length(ref($x))))  # type-stable
#@code_warntype example2(x, Val(length(x))) #hide