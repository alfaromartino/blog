dfg = groupby(dff,[:country,:year])

function average_profit1(price)
    compute_quantity = quantity.(price)
    compute_revenue  = revenue.(compute_quantity, price)
    compute_cost     = cost.(compute_quantity)    
    compute_profit   = profit.(compute_revenue, compute_cost)

    mean(compute_profit)
end

@btime transform(ref(dfg), ref(:price) => average_profit1 => :profit)