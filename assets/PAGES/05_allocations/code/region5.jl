function example1(x)
    for _ in 1:10_000
        foo1(x)
    end
end

@btime example1(ref($x))