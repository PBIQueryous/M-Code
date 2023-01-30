# Transform Headers Functions

### Basic
```ioke

Table.TransformColumnNames(
  table as table,
  nameGenerator as function,
  optional options as nullable record
)

```

---

### Replace Characters
```ioke

= Table.TransformColumnNames( Source,  each Text.Replace( _, "_", " " ) )
// Replaces all underscores with a space
 
= Table.TransformColumnNames( Source,  each Text.Replace( _, ".", " " ) )
// Replaces all full stops with a space

```

---


### Replace Characters
```ioke

= Table.TransformColumnNames( Source,  each "Prefix." & _ )
// Adds the text "Prefix." in front of each column name
 
= Table.TransformColumnNames( Source,  each _ & ".Suffix" )
// Adds the text ".Suffix" after each column name

```


---

### Changing Capatilisation
```ioke

= Table.TransformColumnNames( Source,  each Text.Lower( _ ) )
// Transforms column names to lowercase
 
= Table.TransformColumnNames( Source,  each Text.Upper( _ ) )
// Transforms column names to uppercase
 
= Table.TransformColumnNames( Source,  each Text.Proper( _ ) )
// Capitalizes each word in the column names

```
---

### Clean or Trim Strings
```ioke

= Table.TransformColumnNames( Source,  each Text.Trim( _ ) )
// Removes leading and trailing whitespaces in column names
 
= Table.TransformColumnNames( Source,  each Text.Clean( _ ) )
// Removes non printable characters in column names

```

---

### Conditional Transforms
```ioke

Table.TransformColumnNames( Source,
                            each if Text.Contains(_, "date" ) then "Bingo." & _ else _ )
// Adds a prefix to each column name that contains the text "date" 

```

---

### Split lower/upper case
```ioke

Table.SplitColumn(
  #"Split Column by Character Transition",
  "Product Color",
  Splitter.SplitTextByCharacterTransition({"a" .. "z"}, {"A" .. "Z"}),
  {"Product Color.1", "Product Color.2"}
)
 
// From here you only need to copy the following part: 
 = Splitter.SplitTextByCharacterTransition({"a" .. "z"}, {"A" .. "Z"})
 
 
 Table.TransformColumnNames(
    Source,
    each Text.Combine(
         Splitter.SplitTextByCharacterTransition({"a" .. "z"}, {"A" .. "Z"})(_)
        , " ")
)
```

---

### rename transition table
```ioke

= Table.RenameColumns( table as table,      // the table to rename columns on
                       renames as list,     // pairs of old and new colum names as list
                       optional missingField )
                       
= Table.RenameColumns( Source,
                       List.Zip( { Rename[OldName], Rename[NewName] } ),
                       MissingField.Ignore )
  
= Table.RenameColumns( Source,
                       Table.ToRows( Rename[[OldName],[NewName]] ),
                       MissingField.Ignore )
```


