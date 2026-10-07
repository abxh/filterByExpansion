-- interesting nested filter impl
--
-- ==
-- entry: bench_filter bench_filter_by_expansion
-- compiled random input { [100000]u32    }
-- compiled random input { [1000000]u32   }
-- compiled random input { [10000000]u32  }
-- compiled random input { [100000000]u32 }

import "./lib/github.com/abxh/filterByExpansion/filterByExpansion"

entry bench_filter [n] (xs: [n]u32) : *[]u32 =
  filter (\xs -> xs %% 2 == 0) xs

entry bench_filter_by_expansion [n] (xs: [n]u32) : []u32 =
  filterByExpansion (\xs -> xs %% 2 == 0) xs
