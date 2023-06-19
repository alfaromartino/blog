function with_SVector_barrier(scores, thresholds)
    sthresholds = SVector(thresholds...)
    areabove(pre_scores, sthresholds)
end

@btime with_SVector_barrier(ref($pre_scores), ref($past_thresholds)) #type unstable
#@code_warntype with_SVector_barrier(pre_scores, past_thresholds) #hide