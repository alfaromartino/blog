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