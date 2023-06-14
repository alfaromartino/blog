function simulation1(price)
    for i in 1:10_000
        sum(compute_profit1(price) .+ i/100)
    end
end

@btime simulation1(ref($price_vector));