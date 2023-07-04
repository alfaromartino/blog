Random.seed!(1234)
x = rand(10_000)

intermediate_result(x) = mean.(x ./ x[i] for i in eachindex(x))
final_result(x)        = [intermediate_result(x) for _ in 1:100]

@btime final_result(ref($x))