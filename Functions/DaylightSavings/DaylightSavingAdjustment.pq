Table.AddColumn(
  div_pricing_discount, 
  "website_order_time_adj", 
  each 
    if [website_order_time]
      > DateTime.From(p_firstSundayBST) and [website_order_time]
      < DateTime.From(p_lastSundayBST)
    then
      #duration(0, 1, 0, 0) + [website_order_time]
    else
      [website_order_time], 
  type datetime
)
