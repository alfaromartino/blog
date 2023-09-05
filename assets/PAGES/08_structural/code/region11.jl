# parameters
const σ::Float64 = 3

# shock and outcome sought 
ΔSₘ               = 0.10
welfare_change(P̂) = round( (1/P̂ - 1) * 100, digits=2)

# (mock) data
nr_firms = 500
Sₘ       = 0.05
sᵢ        = rand(Pareto(log(4, 5)), nr_firms) |> 
           x -> (x ./ sum(x) .* (1 - Sₘ))

elasticity(share, σ) = σ + share - share*σ
eᵢ                   = elasticity.(sᵢ, Ref(σ))