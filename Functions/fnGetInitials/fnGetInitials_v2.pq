
Table.AddColumn(
  Custom, 
  "Prov1", 
  each 
    let
      x = "", 
      xx = each Text.Start(_, 1), 
      y = Text.Replace(
        Text.Replace(Text.Replace([ProviderName], 
        " and ", ""), 
        " of ", ""), 
        "The ", 
        ""
      ), 
      z = Text.Combine(List.Transform(Text.Split(y, " "), xx), ""), 
      zz = Text.Start(Text.Replace([ProviderName], " ", ""), 4)
    in
      zz & "-" & z
)
