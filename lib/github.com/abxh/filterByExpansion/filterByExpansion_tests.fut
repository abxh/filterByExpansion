-- interesting nested filter impl
--
-- ==
-- entry: check_same
-- compiled random input { [1]i32 [1]bool }
-- output { true }
-- compiled input { empty([0]i32) empty([0]bool) }
-- output { true }
-- compiled random input { [42]i32 [42]bool }
-- output { true }
-- compiled random input { [100000]i32 [100000]bool }
-- output { true }

import "filterByExpansion"

entry run_filter [n] (xs: [n]i32) (bs: [n]bool) : *[]i32 =
  zip xs bs
  |> filter (\(_, b) -> b)
  |> map (.0)

entry run_filter_by_expansion [n] (xs: [n]i32) (bs: [n]bool) : *[]i32 =
  zip xs bs
  |> filterByExpansion (\(_, b) -> b)
  |> map (.0)

entry check_same (xs: []i32) (mask: []bool) : bool =
  let lhs = run_filter xs mask
  let lhs' = lhs |> sized (length lhs)
  let rhs = run_filter_by_expansion xs mask |> sized (length lhs)
  in map2 (==) lhs' rhs |> reduce (&&) true
