function example2(x)
    for _ in 1:10_000
        foo2(x)
    end
end

@btime example2(ref($x))