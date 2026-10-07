# filterByExpansion

`filter` usually becomes memory bound for large number of elements. Performing it through flattening-by-expansion approach 
seems to offer a speedup over the builtin filter.

## Explanation

Note how `filter` can be performed using `expand` so there exists a kind of equivalence:
```futhark
let filter pred as = expand (\x -> i64.bool (pred x)) (\x _ -> x) as
```

The idea is to perform fast filtering of 64-sized chunks using bitwise clz/popc on a 64-bitset based on the predicate.
And filter the 64-sized chunks using `expand`:
```futhark
-- | Helper function to find the position of the k'th set bit in an u64
def select_u64 (b: u64) (k: i32) : i32 = ??? -- uses clz/popc

expand (\(_, mask) -> i64.i32 <| u64.popc mask)
       (\(o, mask) k -> as[o + i64.i32 (select_u64 mask (i32.i64 k))])
       arr_szs
```

TODO: rest of the explanation.

## Benchmarks

On a NVIDIA M2000M with the `cuda` backend, a ~2.6x speedup can be observed at `10M` elements (at futhark version 27.1):
```
bench.fut:bench_filter (no tuning file):
[100000]u32:           135μs (95% CI: [     133.8,      136.6])
[1000000]u32:          644μs (95% CI: [     636.4,      652.3])
[10000000]u32:        5331μs (95% CI: [    5301.6,     5362.2])
[100000000]u32:      50210μs (95% CI: [   50132.8,    50283.0])

bench.fut:bench_filter_by_expansion (no tuning file):
[100000]u32:           281μs (95% CI: [     276.1,      287.1])
[1000000]u32:          500μs (95% CI: [     492.4,      508.9])
[10000000]u32:        2377μs (95% CI: [    2347.0,     2408.6])
[100000000]u32:      19292μs (95% CI: [   19210.4,    19372.9])
```

On a NVIDIA A100 with the `cuda` backend, a 1.03x speedup (EDIT: with the new `bench.fut`) can be observed at `100M` elements
(at futhark version 27.1):
```
`bench.fut:bench_filter (no tuning file):
[100000]u32:             56μs (95% CI: [      55.9,       56.1])
[1000000]u32:            79μs (95% CI: [      78.8,       79.3])
[10000000]u32:          224μs (95% CI: [     224.2,      224.8])
[100000000]u32:        1767μs (95% CI: [    1765.9,     1767.8])
[1000000000]u32:      17193μs (95% CI: [   17181.6,    17203.8])

bench.fut:bench_filter_by_expansion (no tuning file):
[100000]u32:            125μs (95% CI: [     124.7,      124.9])
[1000000]u32:           152μs (95% CI: [     152.0,      152.4])
[10000000]u32:          293μs (95% CI: [     292.7,      293.3])
[100000000]u32:        1583μs (95% CI: [    1579.7,     1585.8])
[1000000000]u32:      16552μs (95% CI: [   16455.4,    16636.9])
```

Interestingly, using tuples as elements and filter after booleans, one can achieve a 5.5x speedup at same `100M` size between
 the implementations.

```
entry bench_filter [n] (xs: [n]i32) (bs: [n]bool) : *[]i32 =
  zip xs bs
  |> filter (\(_, b) -> b)
  |> map (.0)

entry bench_filter_by_expansion [n] (xs: [n]i32) (bs: [n]bool) : *[]i32 =
  zip xs bs
  |> filterByExpansion (\(_, b) -> b)
  |> map (.0)
```
