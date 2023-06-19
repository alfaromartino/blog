function areabove(scores, thresholds)
    tuple_thresholds = Tuple(thresholds)
    isabove.(scores, Ref(tuple_thresholds))
end

@btime areabove(ref($pre_scores), ref($past_thresholds)) #type unstable
#@code_warntype areabove(pre_scores, past_thresholds) #hide