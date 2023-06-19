using BenchmarkTools #hide
using DataFrames, Distributions, Random # for creating data
using StaticArrays                      # for implementing the approaches
ref(x) = (Ref(x))[] #hide
repl_output(x) = show(IOContext(stdout, :displaysize =>(10,10), :limit=>true), "text/plain", x) #hide 
 
 ##############################################################################
#                       DATA GENERATION
############################################################################## 
 
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
 
 ##############################################################################
#                       EXAMPLE 1
############################################################################## 
 
 Random.seed!(123)    #setting the seed for reproducibility 
pre_scores, past_thresholds = generate_variables(nr_years = 20, nr_people = 10_000)

isabove(score, thresholds)  = any(score .> thresholds)
areabove(score, thresholds) = isabove.(score, Ref(thresholds)) 
 
 repl_output(pre_scores) 
 
 repl_output(past_thresholds) 
 
 @btime areabove(ref($pre_scores), ref($past_thresholds)) 
 
 @btime areabove(ref($pre_scores), ref(Tuple($past_thresholds))) 
 
 tuple_thresholds = Tuple(past_thresholds)

@btime areabove(ref($pre_scores), ref($tuple_thresholds)) #type stable
#@code_warntype areabove(pre_scores, tuple_thresholds) #hide 
 
 function areabove(scores, thresholds)
    tuple_thresholds = Tuple(thresholds)
    isabove.(scores, Ref(tuple_thresholds))
end

@btime areabove(ref($pre_scores), ref($past_thresholds)) #type unstable
#@code_warntype areabove(pre_scores, past_thresholds) #hide 
 
 function areabove(scores, thresholds) 
    tuple_thresholds = NTuple{length(thresholds), eltype(thresholds)}(thresholds)
    isabove.(scores, Ref(tuple_thresholds))
end

@btime areabove(ref($pre_scores), ref($past_thresholds)) #type unstable
#@code_warntype areabove(pre_scores, past_thresholds) #hide 
 
 function areabove(scores, thresholds) 
    tuple_thresholds = NTuple{20,eltype(thresholds)}(thresholds)
    isabove.(scores, Ref(tuple_thresholds))
end

@btime areabove(ref($pre_scores), ref($past_thresholds)) #type stable
#@code_warntype areabove(pre_scores, past_thresholds) #hide 
 
 function areabove(scores, thresholds, ::Val{N}) where {N}
    tuple_thresholds = NTuple{N,eltype(thresholds)}(thresholds)
    isabove.(scores, Ref(tuple_thresholds))
end

@btime areabove(ref($pre_scores), ref($past_thresholds), Val(length(ref($past_thresholds)))) #type stable
#@code_warntype areabove(pre_scores, past_thresholds, Val(length(past_thresholds))) #hide 
 
 Random.seed!(123)    #setting the seed for reproducibility 
x = rand(10)

function example1(x) 
    tuple_x = Tuple(x)

    for _ in 1:100_000
        log.(tuple_x) 
    end
end

@btime example1(ref($x))    # type-unstable
#@code_warntype example1(x) #hide 
 
 Random.seed!(123)    #setting the seed for reproducibility 
x = rand(10)

function example2(x, ::Val{N}) where {N}
    tuple_x = NTuple{N,eltype(x)}(x)   

    for _ in 1:100_000
        log.(tuple_x) 
    end
end

@btime example2(ref($x), Val(length(ref($x))))  # type-stable
#@code_warntype example2(x, Val(length(x))) #hide 
 
 Random.seed!(123)    #setting the seed for reproducibility 
x = rand(10)

function barrier_function(x) 
    for _ in 1:100_000
        log.(x) 
    end
end

function example3(x) 
    tuple_x = Tuple(x)
    barrier_function(tuple_x)
end
   
@btime example3(ref($x))  # type-unstable but minimum penalty
#@code_warntype example3(x) #hide 
 
 Random.seed!(123)    #setting the seed for reproducibility 
pre_scores, past_thresholds = generate_variables(nr_years = 20, nr_people = 10_000)

isabove(score, thresholds)  = any(score .> thresholds)
areabove(score, thresholds) = isabove.(score, Ref(thresholds)) 
 
 function with_SVector_barrier(scores, thresholds)
    sthresholds = SVector(thresholds...)
    areabove(pre_scores, sthresholds)
end

@btime with_SVector_barrier(ref($pre_scores), ref($past_thresholds)) #type unstable
#@code_warntype with_SVector_barrier(pre_scores, past_thresholds) #hide 
 
 function with_SVector_val(scores, thresholds, ::Val{N}) where {N}
    sthresholds = SVector{N, eltype(thresholds)}(thresholds)
    areabove(scores, sthresholds)
end

@btime with_SVector_val(ref($pre_scores), ref($past_thresholds), Val(length(ref($past_thresholds)))) #type stable
#@code_warntype with_SVector_val(pre_scores, past_thresholds,  Val(length(past_thresholds))) #hide 
 
 function with_SVector_macro(scores, thresholds) 
    sthresholds = @SVector [thresholds[i] for i in eachindex(past_thresholds)]
    areabove(scores, sthresholds)
end

@btime with_SVector_macro(ref($pre_scores), ref($past_thresholds)) #type stable
#@code_warntype with_SVector_macro(pre_scores, past_thresholds) #hide 
 
 