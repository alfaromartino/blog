Random.seed!(123)    #setting the seed for reproducibility 
pre_scores, past_thresholds = generate_variables(nr_years = 20, nr_people = 10_000)

isabove(score, thresholds)  = any(score .> thresholds)
areabove(score, thresholds) = isabove.(score, Ref(thresholds))