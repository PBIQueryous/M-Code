```c#
= Text.Contains( "Red roses", "Red" ) // Returns true
= Text.Contains( "Red roses", "red" ) // Returns false
= Text.Contains( "Red roses", "red",
         Comparer.Ordinal )           // Returns false
= Text.Contains( "Red roses", "red",
         Comparer.OrdinalIgnoreCase ) // Returns true
```
