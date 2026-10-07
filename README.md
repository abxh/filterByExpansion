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
`bench.fut:bench_filter (no tuning file):
[100000]u32:           148μs (95% CI: [     145.3,      150.7])
[1000000]u32:          653μs (95% CI: [     645.8,      661.6])
[10000000]u32:        5230μs (95% CI: [    5206.7,     5259.6])
[100000000]u32:      50157μs (95% CI: [   50074.8,    50305.9])

bench.fut:bench_filter_by_expansion (no tuning file):
[100000]u32:           305μs (95% CI: [     299.8,      311.3])
[1000000]u32:          537μs (95% CI: [     527.3,      546.9])
[10000000]u32:        2334μs (95% CI: [    2309.1,     2363.0])
[100000000]u32:      19243μs (95% CI: [   19166.0,    19351.8])
```

On a NVIDIA A100 with the `cuda` backend, a 1.36x speedup (EDIT: with the new `bench.fut`) can be observed at `100M` elements
(at futhark version 27.1):
```
bench.fut:bench_filter (no tuning file):
[100000]u32:                              57μs (95% CI: [      56.5,       57.0])
[1000000]u32:                             81μs (95% CI: [      80.4,       80.7])
[10000000]u32:                           230μs (95% CI: [     229.7,      230.3])
[100000000]u32:                         1765μs (95% CI: [    1763.5,     1765.9])
[1000000000]u32:                       17186μs (95% CI: [   17173.3,    17194.7])

bench.fut:bench_filter_by_expansion (no tuning file):
[100000]u32:                             137μs (95% CI: [     136.9,      137.7])
[1000000]u32:                            138μs (95% CI: [     137.4,      138.0])
[10000000]u32:                           284μs (95% CI: [     283.0,      286.1])
[100000000]u32:                         1300μs (95% CI: [    1298.6,     1301.0])
[1000000000]u32:                       12319μs (95% CI: [   12286.2,    12350.8])

bench.fut:bench_filter_tuple (no tuning file):
[100000]u32 [100000]bool:                 49μs (95% CI: [      49.0,       49.2])
[1000000]u32 [1000000]bool:              104μs (95% CI: [     104.1,      104.9])
[10000000]u32 [10000000]bool:            328μs (95% CI: [     328.1,      328.8])
[100000000]u32 [100000000]bool:         2665μs (95% CI: [    2662.7,     2666.4])
[1000000000]u32 [1000000000]bool:      26021μs (95% CI: [   26010.5,    26033.6])

bench.fut:bench_filter_by_expansion_tuple (no tuning file):
[100000]u32 [100000]bool:                132μs (95% CI: [     132.2,      132.7])
[1000000]u32 [1000000]bool:              137μs (95% CI: [     136.8,      137.2])
[10000000]u32 [10000000]bool:            251μs (95% CI: [     250.7,      251.8])
[100000000]u32 [100000000]bool:          555μs (95% CI: [     554.3,      555.0])
[1000000000]u32 [1000000000]bool:       4398μs (95% CI: [    4389.1,     4441.0])
```
