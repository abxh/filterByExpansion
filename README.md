# filterByExpansion

`filter` is usually memory bound. Performing it through flattening-by-expansion approach seems to offer a speedup over the builtin filter.

On a NVIDIA M2000M with the `cuda` backend, a ~4x speedup can be observed at `N=100000000`:
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

On a NVIDIA A100 with the `cuda` backend, a 8.3x speedup can be observed at `N=1000000000`:
```
bench.fut:bench_filter (no tuning file):
[100000]i32 [100000]bool:                 72μs (95% CI: [      72.2,       72.4])
[1000000]i32 [1000000]bool:              107μs (95% CI: [     107.3,      107.5])
[10000000]i32 [10000000]bool:            449μs (95% CI: [     448.0,      449.7])
[100000000]i32 [100000000]bool:         3943μs (95% CI: [    3939.0,     3960.3])
[1000000000]i32 [1000000000]bool:      39543μs (95% CI: [   39526.0,    39560.2])

bench.fut:bench_filter_by_expansion (no tuning file):
[100000]i32 [100000]bool:                176μs (95% CI: [     175.6,      175.9])
[1000000]i32 [1000000]bool:              232μs (95% CI: [     231.8,      233.4])
[10000000]i32 [10000000]bool:            305μs (95% CI: [     304.9,      305.4])
[100000000]i32 [100000000]bool:          588μs (95% CI: [     587.5,      588.1])
[1000000000]i32 [1000000000]bool:       4754μs (95% CI: [    4751.8,     4756.1])
```
