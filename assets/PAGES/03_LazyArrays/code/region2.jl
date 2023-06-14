Random.seed!(123)        # setting the seed for reproducibility
price_vector             = 2 .* rand(1_000)

quantity(price)          = 10 - 2.1 * price
revenue(quantity, price) = quantity * price
cost(quantity)           = 1.1 * quantity
profit(revenue, cost)    = revenue - cost