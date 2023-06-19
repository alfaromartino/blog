function with_SVector_macro(scores, thresholds) 
    sthresholds = @SVector [thresholds[i] for i in eachindex(past_thresholds)]
    areabove(scores, sthresholds)
end

@btime with_SVector_macro(ref($pre_scores), ref($past_thresholds)) #type stable
#@code_warntype with_SVector_macro(pre_scores, past_thresholds) #hide