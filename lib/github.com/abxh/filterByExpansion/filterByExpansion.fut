import "../../diku-dk/segmented/segmented"

local
-- | Helper function to find the position of the k'th set bit in an u8
#[inline]
def select_u8 (b: u8) (k: i32) : i32 =
  let f b = b & (b - 1)
  let s0 = b
  let s1 = f s0
  let s2 = f s1
  let s3 = f s2
  let s4 = f s3
  let s5 = f s4
  let s6 = f s5
  let s7 = f s6
  let w =
    match k
    case 0 -> s0
    case 1 -> s1
    case 2 -> s2
    case 3 -> s3
    case 4 -> s4
    case 5 -> s5
    case 6 -> s6
    case 7 -> s7
    case _ -> 0u8
  in u8.ctz w

local
-- | Helper function to find the position of the k'th set bit in an u16
#[inline]
def select_u16 (b: u16) (k: i32) : i32 =
  let lower = u8.u16 b
  let upper = b >> 8 |> u8.u16
  let low_count = u8.popc lower
  in if k < low_count
     then select_u8 lower k
     else select_u8 upper (k - low_count) + 8

local
-- | Helper function to find the position of the k'th set bit in an u32
#[inline]
def select_u32 (b: u32) (k: i32) : i32 =
  let lower = u16.u32 b
  let upper = b >> 16 |> u16.u32
  let low_count = u16.popc lower
  in if k < low_count
     then select_u16 lower k
     else select_u16 upper (k - low_count) + 16

local
-- | Helper function to find the position of the k'th set bit in an u64
#[inline]
def select_u64 (b: u64) (k: i32) : i32 =
  let lower = u32.u64 b
  let upper = b >> 32 |> u32.u64
  let low_count = u32.popc lower
  in if k < low_count
     then select_u32 lower k
     else select_u32 upper (k - low_count) + 32

-- the interesting filter impl:
def filterByExpansion [n] 'a (pred: a -> bool) (as: [n]a) : *[]a =
  let num_bits = i64.i32 u64.num_bits
  let m = (n + num_bits - 1) / num_bits
  let f k =
    loop mask = 0
    for j < num_bits do
      let i = k * num_bits + j
      let b = if i < n then pred as[i] else false
      in u64.set_bit (i32.i64 i) mask (i32.bool b)
  let masks = tabulate m f
  let offs = tabulate m (* num_bits)
  let szs = map (u64.popc >-> i64.i32) masks
  let (idxs, iotas) = repl_segm_iota szs
  in map2 (\i j -> as[offs[i] + i64.i32 (select_u64 masks[i] (i32.i64 j))]) idxs iotas
