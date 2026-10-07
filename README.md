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

On a NVIDIA A100 with the `cuda` backend, a 1.36x speedup (EDIT: with the new `bench.fut`) can be observed at `100M` elements
(at futhark version 27.1):
```
bench.fut:bench_filter (no tuning file):
[100000]u32:                              56μs (95% CI: [      55.9,       56.1])
[1000000]u32:                             91μs (95% CI: [      90.4,       91.1])
[10000000]u32:                           248μs (95% CI: [     247.3,      247.9])
[100000000]u32:                         1767μs (95% CI: [    1766.4,     1768.3])
[1000000000]u32:                       17188μs (95% CI: [   17179.2,    17197.5])

bench.fut:bench_filter_by_expansion (no tuning file):
[100000]u32:                             128μs (95% CI: [     127.5,      127.8])
[1000000]u32:                            155μs (95% CI: [     155.2,      155.8])
[10000000]u32:                           286μs (95% CI: [     285.4,      287.9])
[100000000]u32:                         1350μs (95% CI: [    1349.5,     1351.3])
[1000000000]u32:                       12653μs (95% CI: [   12620.7,    12681.2])

bench.fut:bench_filter_tuple (no tuning file):
[100000]u32 [100000]bool:                 44μs (95% CI: [      43.9,       44.0])
[1000000]u32 [1000000]bool:               81μs (95% CI: [      81.2,       81.5])
[10000000]u32 [10000000]bool:            328μs (95% CI: [     328.1,      328.8])
[100000000]u32 [100000000]bool:         2662μs (95% CI: [    2660.8,     2663.3])
[1000000000]u32 [1000000000]bool:      26014μs (95% CI: [   25997.0,    26024.3])

bench.fut:bench_filter_by_expansion_tuple (no tuning file):
[100000]u32 [100000]bool:                122μs (95% CI: [     122.3,      122.6])
[1000000]u32 [1000000]bool:              150μs (95% CI: [     149.7,      150.1])
[10000000]u32 [10000000]bool:            252μs (95% CI: [     252.1,      252.8])
[100000000]u32 [100000000]bool:          582μs (95% CI: [     581.5,      582.1])
[1000000000]u32 [1000000000]bool:       4704μs (95% CI: [    4701.8,     4706.2])
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
