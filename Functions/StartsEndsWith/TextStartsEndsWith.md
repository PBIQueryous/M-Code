```c#
= Text.StartsWith( "I got the Power", "I got") // Returns true
= Text.StartsWith( "I got the Power", "i got") // Returns false
= Text.StartsWith( "I got the Power", "i got", 
               Comparer.Ordinal)               // Returns false
= Text.StartsWith( "I got the Power", "i got", 
               Comparer.OrdinalIgnoreCase)     // Returns true

= Text.EndsWith( "Biking to home", "home") // Returns true
= Text.EndsWith( "Biking to home", "HOME") // Returns false
= Text.EndsWith( "Biking to home", "HOME", 
               Comparer.Ordinal)           // Returns false
= Text.EndsWith( "Biking to home", "HOME", 
               Comparer.OrdinalIgnoreCase) // Returns false
```
