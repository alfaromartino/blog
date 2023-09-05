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