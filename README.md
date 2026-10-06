# filterByExpansion

`filter` usually becomes memory bound for large number of elements. Performing it through flattening-by-expansion approach with
fast bitwise clz/popc seems to offer a speedup over the builtin filter.

On a NVIDIA M2000M with the `cuda` backend, a ~4x speedup can be observed at `N=100000000` (at futhark version 27.1):
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

On a NVIDIA A100 with the `cuda` backend, a 5.5x speedup can be observed at `N=1000000000` (at futhark version 27.1 -- UPDATED):
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
