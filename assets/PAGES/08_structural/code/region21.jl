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