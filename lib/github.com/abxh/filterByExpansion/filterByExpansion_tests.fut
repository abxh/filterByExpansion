-- interesting nested filter impl
--
-- ==
-- entry: check_same
-- compiled input { empty([0]u32) }
-- output { true }
-- compiled random input { [1]u32 }
-- output { true }
-- compiled random input { [2]u32  }
-- output { true }
-- compiled random input { [42]u32 }
-- output { true }
-- compiled random input { [43]u32 }
-- output { true }
-- compiled random input { [44]u32 }
-- output { true }
-- compiled random input { [100000]u32 }
-- output { true }

import "filterByExpansion"

entry run_filter [n] (xs: [n]u32) : *[]u32 =
  filter (\xs -> xs %% 2 == 0) xs

entry run_filter_by_expansion [n] (xs: [n]u32) : *[]u32 =
  filterByExpansion (\xs -> xs %% 2 == 0) xs

entry check_same [n] (xs: [n]u32)  : bool =
  let lhs = run_filter xs
  let lhs' = lhs |> sized (length lhs)
  let rhs = run_filter_by_expansion xs |> sized (length lhs)
  in map2 (==) lhs' rhs |> reduce (&&) true
