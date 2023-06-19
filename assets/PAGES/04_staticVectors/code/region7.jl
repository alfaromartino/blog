function with_SVector_val(scores, thresholds, ::Val{N}) where {N}
    sthresholds = SVector{N, eltype(thresholds)}(thresholds)
    areabove(scores, sthresholds)
end

@btime with_SVector_val(ref($pre_scores), ref($past_thresholds), Val(length(ref($past_thresholds)))) #type stable
#@code_warntype with_SVector_val(pre_scores, past_thresholds,  Val(length(past_thresholds))) #hide