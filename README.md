# filterByExpansion

`filter` usually becomes memory bound for large number of elements. Performing it through flattening-by-expansion approach 
seems to offer a speedup over the builtin filter.

## Explanation

Note how `filter` can be performed using `expand` so there exists a kind of equivalence:
```futhark
filter pred as = expand (\xs -> i64.bool (pred xs)) (\x _ -> x) as
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

On a NVIDIA M2000M with the `cuda` backend, a ~4x speedup can be observed at `10M` elements (at futhark version 27.1):
```
bench.fut:bench_filter (no tuning file):
[100000]i32 [100000]bool:              181μs (95% CI: [     179.4,      183.4])
[1000000]i32 [1000000]bool:            862μs (95% CI: [     851.4,      874.5])
[10000000]i32 [10000000]bool:         7176μs (95% CI: [    7127.9,     7228.7])
[100000000]i32 [100000000]bool:      67408μs (95% CI: [   67350.4,    67466.7])

bench.fut:bench_filter_by_expansion (no tuning file):
[100000]i32 [100000]bool:              284μs (95% CI: [     278.4,      290.3])
[1000000]i32 [1000000]bool:            454μs (95% CI: [     446.6,      463.3])
[10000000]i32 [10000000]bool:         2038μs (95% CI: [    2017.4,     2062.7])
[100000000]i32 [100000000]bool:      16919μs (95% CI: [   16847.5,    16998.1])
```

On a NVIDIA A100 with the `cuda` backend, a 5.5x speedup can be observed at `100M` elements (at futhark version 27.1 -- UPDATED):
```
filterByExpansion/bench.fut:bench_filter (no tuning file):
[100000]i32 [100000]bool:                 70μs (95% CI: [      70.2,       70.4])
[1000000]i32 [1000000]bool:              103μs (95% CI: [     102.6,      102.8])
[10000000]i32 [10000000]bool:            329μs (95% CI: [     328.8,      329.3])
[100000000]i32 [100000000]bool:         2665μs (95% CI: [    2662.9,     2667.0])
[1000000000]i32 [1000000000]bool:      26030μs (95% CI: [   26016.2,    26041.4])

filterByExpansion/bench.fut:bench_filter_by_expansion (no tuning file):
[100000]i32 [100000]bool:                143μs (95% CI: [     143.1,      143.5])
[1000000]i32 [1000000]bool:              147μs (95% CI: [     147.3,      147.6])
[10000000]i32 [10000000]bool:            267μs (95% CI: [     266.3,      267.4])
[100000000]i32 [100000000]bool:          602μs (95% CI: [     602.3,      602.7])
[1000000000]i32 [1000000000]bool:       4722μs (95% CI: [    4718.2,     4724.8])
```
On a `AMD EPYC 7352 24-Core Processor` with the `multicore` backend, a 1.6x speedup can be observed at `10M` elements,
and a 1.1x speedup at `100M` elements (at futhark version 27.1):
```
filterByExpansion/bench.fut:bench_filter (no tuning file):
[100000]i32 [100000]bool:               1348μs (95% CI: [    1324.6,     1376.3])
[1000000]i32 [1000000]bool:             4266μs (95% CI: [    4212.2,     4333.1])
[10000000]i32 [10000000]bool:          17319μs (95% CI: [   14311.9,    25529.0])
[100000000]i32 [100000000]bool:       101105μs (95% CI: [   96136.3,   106276.9])
[1000000000]i32 [1000000000]bool:    1662636μs (95% CI: [  930973.2,  3533303.2])

filterByExpansion/bench.fut:bench_filter_by_expansion (no tuning file):
[100000]i32 [100000]bool:               1120μs (95% CI: [    1111.2,     1132.5])
[1000000]i32 [1000000]bool:             5686μs (95% CI: [    5663.7,     5728.7])
[10000000]i32 [10000000]bool:          27705μs (95% CI: [   27230.3,    28521.2])
[100000000]i32 [100000000]bool:       162392μs (95% CI: [  160257.7,   166232.6])
[1000000000]i32 [1000000000]bool:    1489191μs (95% CI: [ 1414837.8,  1589766.6])
```
