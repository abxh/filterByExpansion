-- interesting nested filter impl
--
-- ==
-- entry: bench_filter bench_filter_by_expansion
-- compiled random input { [100000]i32     [100000]bool }
-- compiled random input { [1000000]i32    [1000000]bool }
-- compiled random input { [10000000]i32   [10000000]bool }
-- compiled random input { [100000000]i32  [100000000]bool }

import "./lib/github.com/abxh/filterByExpansion/filterByExpansion"

entry bench_filter [n] (xs: [n]i32) (bs: [n]bool) : *[]i32 =
  zip xs bs
  |> filter (\(_, b) -> b)
  |> map (.0)

entry bench_filter_by_expansion [n] (xs: [n]i32) (bs: [n]bool) : *[]i32 =
  zip xs bs
  |> filterByExpansion (\(_, b) -> b)
  |> map (.0)
