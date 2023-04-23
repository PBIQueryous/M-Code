//Generalized form of List.Generate
= List.Generate(
     () => [x = 0, y = 1],          // assigns a value to x and y
      each [x] + [y] < 100,     // apply function as long as < 100
      each [y = [x] + [y],        // y equals x + y of previous step
            x = [y] ],                  // x changes to previous y
      each [x]                        // returns x 
)

//Specific Example

 PyramidGenerate =
 Table.AddColumn(MarkerIndex, "Triangle", each 
     List.Generate(
           () => [x=0, y= {[Data]}{0}], 
           each [x] <= MaxCount, 
           each [ x = [x] + 1, y = Text.Combine( {MarkerIndex[Data]{x}, [y] , MarkerIndex[Data]{x}},"")],
           each [y] 
 )
 )
