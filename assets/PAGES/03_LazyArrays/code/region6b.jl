function simulation2(price)
    for i in 1:10_000
        sum(compute_profit2(price) .+ i/100)
    end
end

@btime simulation2(ref($price_vector));