function areabove(scores, thresholds, ::Val{N}) where {N}
    tuple_thresholds = NTuple{N,eltype(thresholds)}(thresholds)
    isabove.(scores, Ref(tuple_thresholds))
end

@btime areabove(ref($pre_scores), ref($past_thresholds), Val(length(ref($past_thresholds)))) #type stable
#@code_warntype areabove(pre_scores, past_thresholds, Val(length(past_thresholds))) #hide