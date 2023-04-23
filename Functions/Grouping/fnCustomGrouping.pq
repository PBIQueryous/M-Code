let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("bZQ5ckQhDETv8uMJQBIgHcGBE6dTc/9reP4ULbtVBCQP0NJans/r++untdZd5Hpc95l2vR7/uG2uOvhi4UKY++bdG11o2xcF99vG/Z7tqG4+Gd/x3F/6Mo5U59G+nd3a2OYLXhuLMvftVhvLYLE/KH8YZ7dDYJ+DH3oMZ4xtJfj5bBCt8AV1GoezUMZglRccGDte0IHtO4o12IxnsditQ+XozFErKbI5/HLVPZvqnSFdxE7YOKDo+wM/D3Q5Zxt2ViEgZ8G+g/TiFL1Az6O1M0YrjGBu5+eolJTnkLKr00VHB/LgRodfKxxZrcn8nJUc5zPkOFch84xR7s5J5RLhsoacY/mslk/bK3PsKB6T0ABn87krePrD0E2ssAmWwmKebjtLPNBnrNmAZlI4RFNWZ8A+qzAgmhjHmdsi+MNEJ2hnrjltzDOvwQlPlGWx44Vx61oKvJByUWj95cAfPLu58Iy1cxKOeSkxeYrKYuTmKRHlJqHdIC3n0d4ivX4B", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Records = _t, Priority = _t, Minutes = _t]),
  ChType = Table.TransformColumnTypes(Source,{{"Priority", Int64.Type}, {"Minutes", Int64.Type}}),
  Partitions = Table.Partition(ChType, "Priority", 2, each if _ < 3 then 0 else 1),
  nRows = Number.Round(Table.RowCount(Partitions{0}) * 0.05, 0),
    t1 = Table.RemoveColumns(
    Table.AddColumn(
      Table.AddRankColumn(
        Partitions{0},
        "i",
        {"Minutes", Order.Descending},
        [RankKind = RankKind.Ordinal]
      ), "Exclude", each [i] <= nRows, type logical
    ), {"i"}
  ),
  t2 = Table.AddColumn(Partitions{1}, "Exclude", each true, type logical),
  t = t1 & t2
in
  t
