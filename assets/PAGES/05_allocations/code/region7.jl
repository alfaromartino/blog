function example3(x)
    for _ in 1:10_000
        foo3(x)
    end
end

@btime example3(ref($x))