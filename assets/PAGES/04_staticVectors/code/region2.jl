#80-20 Pareto Rule
random_scores(nr_people) = rand(Pareto(log(4, 5)), nr_people)

function generate_yearly_data(year, nr_people)
    scores    = random_scores(nr_people)
    dff       = DataFrame(score = scores)
    dff.id    = eachindex(1:nr_people)
    dff.year .= year
    return dff
end

#DataFrame generated
function generate_data(nr_years, nr_people)
    nr_years = nr_years - 1
    dff      = generate_yearly_data(2000, nr_people)
    
    for year in 2001: nr_years-1+2001
        append!(dff, generate_yearly_data(year, nr_people)) 
    end   

    return select!(dff, [:year, :id, :score])
end


#Variables we'll use
function generate_variables(; nr_years, nr_people)
    dff = generate_data(nr_years, nr_people)
    
    pre_scores      = random_scores(nr_people)
    past_thresholds = combine(groupby(dff,[:year]), :score => mean => :th) |>
                      x -> x.th |> unique

    pre_scores, past_thresholds
end