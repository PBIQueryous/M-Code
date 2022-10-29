
# ioke

```ioke

= Table.AddColumn(Match_Substrings, "Custom.1", each 
let arg1 = List.ContainsAny( Text.Split(  [Country] , " "), {"Russia", "Mexico"} ), // exact match
arg2 = List.ContainsAny( Text.Split(  [Country] , " "), {"Canada", "Germany"} ), // exact match
arg3 = List.AnyTrue( { [Country] = "United Kingdom" , [Country] = "United States of America"  }), // exact match
arg4 = List.ContainsAny( {[Country]}, {"France", "Country of the World"}),
arg5 = List.AnyTrue( List.Transform( {"United States of America", " World", "anc"}, 
(substring)=> Text.Contains([Country], 
substring, Comparer.OrdinalIgnoreCase)) ),
arg7 = List.AnyTrue( List.Transform( {" World", "anc"}, 
(substring)=>  Text.Contains(([Country]), 
substring, Comparer.OrdinalIgnoreCase))),

calc1 = if arg7 then 1 else if arg2 then 2 else if arg3 then 3 else /* if arg4 then 4 else  */if arg5 then 5 else "9"
in calc1
)
```

# ocaml

```ocaml

= Table.AddColumn(Match_Substrings, "Custom.1", each 
let arg1 = List.ContainsAny( Text.Split(  [Country] , " "), {"Russia", "Mexico"} ), // exact match
arg2 = List.ContainsAny( Text.Split(  [Country] , " "), {"Canada", "Germany"} ), // exact match
arg3 = List.AnyTrue( { [Country] = "United Kingdom" , [Country] = "United States of America"  }), // exact match
arg4 = List.ContainsAny( {[Country]}, {"France", "Country of the World"}),
arg5 = List.AnyTrue( List.Transform( {"United States of America", " World", "anc"}, 
(substring)=> Text.Contains([Country], 
substring, Comparer.OrdinalIgnoreCase)) ),
arg7 = List.AnyTrue( List.Transform( {" World", "anc"}, 
(substring)=>  Text.Contains(([Country]), 
substring, Comparer.OrdinalIgnoreCase))),

calc1 = if arg7 then 1 else if arg2 then 2 else if arg3 then 3 else /* if arg4 then 4 else  */if arg5 then 5 else "9"
in calc1
)
```
# Jade

```jade

= Table.AddColumn(Match_Substrings, "Custom.1", each 
let arg1 = List.ContainsAny( Text.Split(  [Country] , " "), {"Russia", "Mexico"} ), // exact match
arg2 = List.ContainsAny( Text.Split(  [Country] , " "), {"Canada", "Germany"} ), // exact match
arg3 = List.AnyTrue( { [Country] = "United Kingdom" , [Country] = "United States of America"  }), // exact match
arg4 = List.ContainsAny( {[Country]}, {"France", "Country of the World"}),
arg5 = List.AnyTrue( List.Transform( {"United States of America", " World", "anc"}, 
(substring)=> Text.Contains([Country], 
substring, Comparer.OrdinalIgnoreCase)) ),
arg7 = List.AnyTrue( List.Transform( {" World", "anc"}, 
(substring)=>  Text.Contains(([Country]), 
substring, Comparer.OrdinalIgnoreCase))),

calc1 = if arg7 then 1 else if arg2 then 2 else if arg3 then 3 else /* if arg4 then 4 else  */if arg5 then 5 else "9"
in calc1
)
```



# vim

```vim

= Table.AddColumn(Match_Substrings, "Custom.1", each 
let arg1 = List.ContainsAny( Text.Split(  [Country] , " "), {"Russia", "Mexico"} ), // exact match
arg2 = List.ContainsAny( Text.Split(  [Country] , " "), {"Canada", "Germany"} ), // exact match
arg3 = List.AnyTrue( { [Country] = "United Kingdom" , [Country] = "United States of America"  }), // exact match
arg4 = List.ContainsAny( {[Country]}, {"France", "Country of the World"}),
arg5 = List.AnyTrue( List.Transform( {"United States of America", " World", "anc"}, 
(substring)=> Text.Contains([Country], 
substring, Comparer.OrdinalIgnoreCase)) ),
arg7 = List.AnyTrue( List.Transform( {" World", "anc"}, 
(substring)=>  Text.Contains(([Country]), 
substring, Comparer.OrdinalIgnoreCase))),

calc1 = if arg7 then 1 else if arg2 then 2 else if arg3 then 3 else /* if arg4 then 4 else  */if arg5 then 5 else "9"
in calc1
)
```

