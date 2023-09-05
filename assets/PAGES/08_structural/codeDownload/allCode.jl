
using BenchmarkTools
ref(x) = (Ref(x))[] #hide

print_asis(x)    = show(IOContext(stdout, :limit => true, :displaysize =>(9,100)), MIME("text/plain"), x)
print_compact(x) = show(IOContext(stdout, :limit => true, :displaysize =>(9,6), :compact => true), MIME("text/plain"), x) 
 
 using Distributions, Random
Random.seed!(1234)

using NLsolve
using LazyArrays, LoopVectorization 
 
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
 
 ############################################################################
#
#                           FOR LOOPS
#
############################################################################ 
 
 function computation(sᵢ, ΔSₘ, eᵢ, σ)
    êᵢ = similar(sᵢ); p̂ᵢ = similar(sᵢ)

    function solver!(res, sol)
        P̂  = sol[1]
        ŝᵢ  = sol[2:length(sᵢ)+1]

        for i in eachindex(êᵢ)
            êᵢ[i] = (σ - (σ - 1) * sᵢ[i] * ŝᵢ[i]) / (σ - (σ - 1) * sᵢ[i])
            p̂ᵢ[i] = êᵢ[i] * (eᵢ[i] - 1) / (êᵢ[i] * eᵢ[i] - 1)
        end

        sum_shares = [(1 - ŝᵢ[i]) * sᵢ[i] for i in eachindex(sᵢ)]
        res[1]     = sum(sum_shares) - ΔSₘ

        for i in 2:length(sᵢ)+1
            res[i] = ŝᵢ[i-1] - p̂ᵢ[i-1]^(1 - σ) * P̂^(σ - 1)
        end

    end

    function execute()
        sol0     = vcat(0.9, 0.8 .* ones(length(sᵢ)))
        solution = nlsolve(solver!, sol0)

        converged(solution) || error("Failed to converge")
        return solution.zero
    end

    return execute()
end 
 
 @btime computation($sᵢ, $ΔSₘ, $eᵢ, $σ); 
 
 # P̂ = computation(sᵢ, ΔSₘ, eᵢ, σ)[1]
# println("Change in welfare is $(welfare_change(P̂))%") 
 
 function computation(sᵢ, ΔSₘ, eᵢ, σ)
    êᵢ, p̂ᵢ = (similar(sᵢ) for _ in 1:2)

    function solver!(res, sol)
        P̂  = sol[1]
        ŝᵢ  = @view sol[2:length(sᵢ)+1]

        sum_shares = ((1 - ŝᵢ[i]) * sᵢ[i] for i in eachindex(sᵢ))
        res[1]     = sum(sum_shares) - ΔSₘ

        rest  = @view res[2:length(sᵢ)+1]          # to update the results below
            @turbo for i in eachindex(êᵢ)
                êᵢ[i]     =  (σ - (σ - 1) * sᵢ[i] * ŝᵢ[i]) / (σ - (σ - 1) * sᵢ[i])
                p̂ᵢ[i]     =  êᵢ[i] * (eᵢ[i] - 1) / (êᵢ[i] * eᵢ[i] - 1)
                rest[i]  =  ŝᵢ[i] - p̂ᵢ[i]^(1 - σ) * P̂^(σ - 1)
            end
    end

    function execute()
        sol0     = vcat(0.9, 0.8 .* ones(length(sᵢ)))
        solution = nlsolve(solver!, sol0)

        converged(solution) || error("Failed to converge")
        return solution.zero
    end

    return execute()
end 
 
 @btime computation($sᵢ, $ΔSₘ, $eᵢ, $σ); 
 
 # P̂ = computation(sᵢ, ΔSₘ, eᵢ, σ)[1]
# println("Change in welfare is $(welfare_change(P̂))%") 
 
 ############################################################################
#
#                           UPDATING FUNCTION
#
############################################################################




# UPDATING WITH LOOP 
 
 function êᵢ!(êᵢ, ŝᵢ, sᵢ, σ)
    @turbo for i in eachindex(êᵢ)
        numerator   = σ - (σ - 1) * sᵢ[i] * ŝᵢ[i]
        denominator = σ - (σ - 1) * sᵢ[i]
        
        êᵢ[i] = numerator / denominator
    end
end

function p̂ᵢ!(p̂ᵢ, êᵢ, eᵢ)
    @turbo for i in eachindex(êᵢ)
        numerator   = êᵢ[i] * (eᵢ[i] - 1)
        denominator = êᵢ[i] * eᵢ[i] - 1

        p̂ᵢ[i] = numerator / denominator
    end   
end 
 
 function computation(sᵢ, ΔSₘ, eᵢ, σ)
    êᵢ, p̂ᵢ = (similar(sᵢ) for _ in 1:2)

    function solver!(res, sol)
        P̂  = sol[1]
        ŝᵢ = @view sol[2:length(sᵢ)+1]

        sum_shares = ((1 - ŝᵢ[i]) * sᵢ[i] for i in eachindex(sᵢ))
        res[1]     = sum(sum_shares) - ΔSₘ

        êᵢ!(êᵢ, ŝᵢ, sᵢ, σ)
        p̂ᵢ!(p̂ᵢ, êᵢ, eᵢ)

        @turbo for i in 2:length(sᵢ)+1
            res[i] = ŝᵢ[i-1] - p̂ᵢ[i-1]^(1 - σ) * P̂^(σ - 1)
        end
    end

    function execute()
        sol0     = vcat(0.9, 0.8 .* ones(length(sᵢ)))
        solution = nlsolve(solver!, sol0)

        converged(solution) || error("Failed to converge")
        return solution.zero
    end

    return execute()
end 
 
 @btime computation($sᵢ, $ΔSₘ, $eᵢ, $σ); 
 
 # P̂ = computation(sᵢ, ΔSₘ, eᵢ, σ)[1]
# println("Change in welfare is $(welfare_change(P̂))%")


############################################################################
#
#                           VECTORIZED
#
############################################################################ 
 
 function computation(sᵢ, ΔSₘ, eᵢ, σ)
    function solver!(res, sol)
        P̂  = sol[1]
        ŝᵢ  = sol[2:length(sᵢ)+1]

        êᵢ = @. (σ - (σ - 1) * sᵢ * ŝᵢ) / (σ - (σ - 1) * sᵢ)
        p̂ᵢ = @. êᵢ * (eᵢ - 1) / (êᵢ * eᵢ - 1)


        res[1]             = sum((1 .- ŝᵢ) .* sᵢ) - ΔSₘ
        res[2:length(sᵢ)+1] = @. ŝᵢ - p̂ᵢ^(1 - σ) * P̂^(σ - 1)
    end

    function execute()
        sol0     = vcat(0.9, 0.8 .* ones(length(sᵢ)))
        solution = nlsolve(solver!, sol0)

        converged(solution) || error("Failed to converge")
        return solution.zero
    end

    return execute()
end 
 
 @btime computation($sᵢ, $ΔSₘ, $eᵢ, $σ); 
 
 # P̂ = computation(sᵢ, ΔSₘ, eᵢ, σ)[1]
# println("Change in welfare is $(welfare_change(P̂))%") 
 
 function computation(sᵢ, ΔSₘ, eᵢ, σ)
    êᵢ, p̂ᵢ      = (similar(sᵢ) for _ in 1:2)
    idx_shares = 2:length(sᵢ)+1

    function solver!(res, sol)
        P̂      = sol[1]
        ŝᵢ      = @view sol[idx_shares]
        
        res[1] = sum(@~ (1 .- ŝᵢ) .* sᵢ) - ΔSₘ
        
        @turbo @. êᵢ = (σ - (σ - 1) * sᵢ * ŝᵢ) / (σ - (σ - 1) * sᵢ)
        @turbo @. p̂ᵢ = êᵢ * (eᵢ - 1) / (êᵢ * eᵢ - 1)
                          
        @turbo res[idx_shares] .= @. ŝᵢ - p̂ᵢ^(1 - σ) * P̂^(σ - 1)
    end

    function execute()
        sol0     = vcat(0.9, 0.8 .* ones(length(sᵢ)))
        solution = nlsolve(solver!, sol0)

        converged(solution) || error("Failed to converge")
        return solution.zero
    end

    return execute()
end 
 
 @btime computation($sᵢ, $ΔSₘ, $eᵢ, $σ);

##########################################################################################################  ###code region30 (((
# P̂ = computation(sᵢ, ΔSₘ, eᵢ, σ)[1]
# println("Change in welfare is $(welfare_change(P̂))%")



############################################################################
#
#                           UPDATING VECTORIZED
#
############################################################################ 
 
 êᵢ!(êᵢ, ŝᵢ, sᵢ, σ) = @turbo @. êᵢ = (σ - (σ - 1) * sᵢ * ŝᵢ) / (σ - (σ - 1) * sᵢ)
p̂ᵢ!(p̂ᵢ, êᵢ, eᵢ)    = @turbo @. p̂ᵢ = êᵢ * (eᵢ - 1) / (êᵢ * eᵢ - 1) 
 
 function computation(sᵢ, ΔSₘ, eᵢ, σ)
    êᵢ, p̂ᵢ      = (similar(sᵢ) for _ in 1:2)
    idx_shares = 2:length(sᵢ)+1

    @views function solver!(res, sol)
        P̂  = sol[1]
        ŝᵢ  = sol[idx_shares]
        
        êᵢ!(êᵢ, ŝᵢ, sᵢ, σ)
        p̂ᵢ!(p̂ᵢ, êᵢ, eᵢ)        

                  res[1]          = sum(@~ (1 .- ŝᵢ) .* sᵢ) - ΔSₘ
        @turbo @. res[idx_shares] = ŝᵢ - p̂ᵢ^(1 - σ) * P̂^(σ - 1)
    end

    function execute()
        sol0     = vcat(0.9, 0.8 .* ones(length(sᵢ)))
        solution = nlsolve(solver!, sol0)

        converged(solution) || error("Failed to converge")
        return solution.zero
    end

    return execute()
end 
 
 @btime computation($sᵢ, $ΔSₘ, $eᵢ, $σ); 
 
 # P̂ = computation(sᵢ, ΔSₘ, eᵢ, σ)[1]
# println("Change in welfare is $(welfare_change(P̂))%") 
 
 