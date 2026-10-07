-- interesting nested filter impl
--
-- ==
-- entry: bench_filter bench_filter_by_expansion
-- compiled random input { [100000]u32     }
-- compiled random input { [1000000]u32    }
-- compiled random input { [10000000]u32   }
-- compiled random input { [100000000]u32  }
-- compiled random input { [1000000000]u32 }

-- ==
-- entry: bench_filter_tuple bench_filter_by_expansion_tuple
-- compiled random input { [100000]u32     [100000]bool    }
-- compiled random input { [1000000]u32    [1000000]bool   }
-- compiled random input { [10000000]u32   [10000000]bool  }
-- compiled random input { [100000000]u32  [100000000]bool }

import "./lib/github.com/abxh/filterByExpansion/filterByExpansion"

entry bench_filter [n] (xs: [n]u32) : *[]u32 =
  filter (\xs -> xs %% 2 == 0) xs

entry bench_filter_by_expansion [n] (xs: [n]u32) : *[]u32 =
  filterByExpansion (\xs -> xs %% 2 == 0) xs

entry bench_filter_tuple [n] (xs: [n]u32) (bs: [n]bool) : *[]u32 =
  let x1 = zip xs bs
  let x2 = filter (\(_, b) -> b) x1
  let x3 = map (.0) x2
  in x3

entry bench_filter_by_expansion_tuple [n] (xs: [n]u32) (bs: [n]bool) : *[]u32 =
  let x1 = zip xs bs
  let x2 = filterByExpansion (\(_, b) -> b) x1
  let x3 = map (.0) x2
  in x3
