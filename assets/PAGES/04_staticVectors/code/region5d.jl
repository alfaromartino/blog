function areabove(scores, thresholds) 
    tuple_thresholds = NTuple{20,eltype(thresholds)}(thresholds)
    isabove.(scores, Ref(tuple_thresholds))
end

@btime areabove(ref($pre_scores), ref($past_thresholds)) #type stable
#@code_warntype areabove(pre_scores, past_thresholds) #hide