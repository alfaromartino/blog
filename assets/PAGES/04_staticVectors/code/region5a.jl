tuple_thresholds = Tuple(past_thresholds)

@btime areabove(ref($pre_scores), ref($tuple_thresholds)) #type stable
#@code_warntype areabove(pre_scores, tuple_thresholds) #hide