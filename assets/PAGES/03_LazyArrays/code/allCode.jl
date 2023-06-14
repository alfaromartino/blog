using DataFrames, Distributions, Random, BenchmarkTools
using LazyArrays
ref(x) = (Ref(x))[] #hide 
 
 ##############################################################################
#                       DATA GENERATION
############################################################################## 
 
 Random.seed!(123)        # setting the seed for reproducibility
price_vector             = 2 .* rand(1_000)

quantity(price)          = 10 - 2.1 * price
revenue(quantity, price) = quantity * price
cost(quantity)           = 1.1 * quantity
profit(revenue, cost)    = revenue - cost 
 
 function compute_profit1(price)
    compute_quantity = quantity.(price)
    compute_revenue  = revenue.(compute_quantity, price)
    compute_cost     = cost.(compute_quantity)
    
    profit.(compute_revenue, compute_cost)     
end

@btime compute_profit1(ref($price_vector)); 
 
 function compute_profit2(price)
    compute_quantity = @~ quantity.(price)
    compute_revenue  = @~ revenue.(compute_quantity, price)
    compute_cost     = @~ cost.(compute_quantity)
    
    profit.(compute_revenue, compute_cost)
end

@btime compute_profit2(ref($price_vector)); 
 
 compute_profit1(price_vector) == compute_profit2(price_vector) 
 
 ##############################################################################
#                       EXAMPLE WITH F0R-LOOP (NOT INCLUDED IN THE POST)
############################################################################## 
 
 function simulation1(price)
    for i in 1:10_000
        sum(compute_profit1(price) .+ i/100)
    end
end

@btime simulation1(ref($price_vector)); 
 
 function simulation2(price)
    for i in 1:10_000
        sum(compute_profit2(price) .+ i/100)
    end
end

@btime simulation2(ref($price_vector)); 
 
 ############################################################################
#
#                           DATA GENERATION
#
############################################################################ 
 
 Random.seed!(123)   #setting the seed for reproducibility

nr_countries = 50
nr_years     = 20
nr_firms     = 10_000 
 
 #80-20 Pareto Rule within country-year
prices_random(nr_firms, nr_countries) = [rand(Pareto(log(4, 5)), nr_firms) for _ in 1:nr_countries] 

function generate_yearly_data(year, nr_firms, nr_countries)
    revenue = prices_random(nr_firms, nr_countries)
    dff     = DataFrame(country=1:nr_countries, price = revenue)
    dff     = flatten(dff,2)

    dff.firm  = repeat(1:nr_firms, outer = nr_countries)
    dff.year  .= year
    return dff
end


function generate_data(nr_years, nr_firms, nr_countries)    
    dff = generate_yearly_data(2000, nr_firms, nr_countries)
    for year in 2001:nr_years-1+2001
        append!(dff, generate_yearly_data(year, nr_firms, nr_countries)) 
    end   

    return select!(dff, [:year, :country, :firm, :price])
end

dff = generate_data(nr_years, nr_firms, nr_countries) #it generates the DataFrame 
 
 println(dff[1:5,:]) #hide 
 
 dfg = groupby(dff,[:country,:year])

function average_profit1(price)
    compute_quantity = quantity.(price)
    compute_revenue  = revenue.(compute_quantity, price)
    compute_cost     = cost.(compute_quantity)    
    compute_profit   = profit.(compute_revenue, compute_cost)

    mean(compute_profit)
end

@btime transform(ref(dfg), ref(:price) => average_profit1 => :profit) 
 
 dfg = groupby(dff,[:country,:year])

function average_profit2(price)
    compute_quantity = @~ quantity.(price)
    compute_revenue  = @~ revenue.(compute_quantity, price)
    compute_cost     = @~ cost.(compute_quantity)
    compute_profit   = @~ profit.(compute_revenue, compute_cost)

    mean(compute_profit)
end

@btime transform(ref(dfg), ref(:price) => average_profit2 => :profit) 
 
 # ASIDE CALCULATION 
 
 x        = [2,3,4]
eager(x) = sum(x .* x .* log.(x))

@btime eager(ref($x)) 
 
 x       = [2,3,4]
lazy(x) = sum(@~(x .* x .* log.(x)))

@btime lazy(ref($x)) 
 
 