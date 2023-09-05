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