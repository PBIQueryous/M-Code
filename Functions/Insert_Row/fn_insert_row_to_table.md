# Insert Row to Table
## Inserts row to table and dynamically applies all columns
### (better suited to dimension tables)

```ioke

let
  customFunction =
// 1.0: invoke function & define parameter inputs
  
    let
     // 1.1: edit function metadata here
      documentation = [
        // Function Documentation
        Documentation.Name = " fn_insert_row_to_table ", 
        Documentation.Description = " Inserts a row to a table (preferable for dimension tables) ", 
        Documentation.LongDescription = "    
                <p><b>  fn_insert_row_to_table  </b></p>

                <li>------------------------------------------------------</li>
                
                <li><b>  Creator: </b> Imran Haq  </li>
                <li><b>  Web: </b> https://github.com/PBIQueryous/  </li>
                

                <li>------------------------------------------------------</li>

                <p><b>  Function Description:  </b></p>
                <p>  This function inserts a custom / configurable row into a DIMENSION TABLE any number of columns. The only prequisite is that the ID/KEY column is at the beginning  </p>
                <p><b>  Parameters:  </b></p>
                <ul>
                    <li><b>  input_table:  </b>  Table / Previous Step. <code>  </code> </li>
                    <li><b>  id_column:  </b>  ID or KEY column value. <code> -99 </code> </li>
                    <li><b>  filler_word:  </b>  Word or text string to input into remaining columns. <code> Other </code> </li>
                    <li><b>  row_position:  </b>  ID or KEY column value. <code> {Top / Bottom / 0 / 3} </code> </li>
                    
                </ul>
                <p><b>  Example Formula:  </b></p>

                <li><b>  fx:  </b> <code> = fn_insert_row_to_table( change_datatypes, -99, ""Other"", null ) </code> </li>
            ", 
        Documentation.Category = " Function Category ", 
        Documentation.Source = "  PBI Queryous  ", 
        Documentation.Version = " 1.0: Latest update comment", 
        Documentation.Author = " Imran Haq ", 
        Documentation.Examples = {
          [
            Description = "  Function description   ", 
            Code = " = fn_insert_row_to_table( change_datatypes, -99, ""Other"", null ) ", 
            Result = 
"
  1. declare previous step
  2. input desired ID or KEY value for inserted row (if null defaults to 'XX')
  3. input a word or text string for instered row (eg: 'Other')
  4. select position: either 'Top', 'Bottom' or specific row number, or null

"
          ]
        /* ,
            [
            Description = "  description   ",
            Code    = " code ", 
            Result  = " result #(cr,lf) new line
                      #(cr,lf) new line #(cr,lf) 2 "
            ] */
        }
      ], 
      invokeFunction = (
      input_table as table, 
      id_column as nullable any, 
      filler_word as nullable text, 
      optional row_position as nullable any
  )   as table =>
        // ------------------------------------------------------------------
        // 1.2: function transformations
let
      // handle null paramaters

      // if id_column is empty return "XX" else chosen id_column
      id_column = if id_column = null then "XX" else id_column, 
      
      // if filler word is null then return "" empty cell else chosen filler word
      filler = if filler_word = null then "" else filler_word, 
      
      // row_index is null then return last row row_position else chosen row row_position (zero index)
      last_row = (Table.RowCount(input_table)),
      insert_row_position = if row_position = "Top" then 0 else if row_position = "Bottom" then last_row else if Value.Is( row_position , Number.Type ) then row_position else last_row,
      row_index = if insert_row_position = null then last_row else insert_row_position,
      
      
      // Count the number of columns in the input table
      column_count = Table.ColumnCount(input_table), 
      
      // Combine id_column input word for id_column column and filler word for remaining columns
      Values = List.Combine({{id_column}, List.Repeat({filler}, column_count - 1)}), 
      
      // Get the column names dynamically
      Columns = Table.ColumnNames(input_table), 
      
      // Create the new row dynamically
      NewRow = Record.FromList(Values, Columns), 
      
      // Insert the new row at the specified row_position
      UpdatedTable = Table.InsertRows(input_table, row_index, {NewRow})
    in
      UpdatedTable
        , 
      // ------------------------------------------------------------------     

      // 2.0: change parameter metadata here
      fnType = type function (
        // 2.1: Table Parameter
        input_table as (
          type table
            meta [
              Documentation.FieldCaption     = " Table: #(lf) Previous Step Table ", 
              Documentation.FieldDescription = " Table: #(cr,lf) Source ", 
              Documentation.SampleValues     = {"Table"}
            ]
        ), 
        // 2.2: Calendar End Year parameter
        id_column as (
          type number
            meta [
              Documentation.FieldCaption     = " id_column: #(lf) (Text or Number) ", 
              Documentation.FieldDescription = " id_column: #(cr,lf) (Text or Number) ", 
              Documentation.SampleValues     = {999}
            ]
        ), 
        // 3.0.3: Fiscal Start Month parameter
        filler_word as (
          type any
            meta [
              Documentation.FieldCaption     = " Filler Word: #(lf) (eg: 'Other') ", 
              Documentation.FieldDescription = " Filler Word: #(lf) (eg: 'Other') ", 
              Documentation.SampleValues     = {"'Other'"}
            ]
        ),
        // 3.0.4: RowPosition
        optional row_position as (
          type text
            meta [
              Documentation.FieldCaption     = " Select Row Position: #(lf) (Top or Bottom) ", 
              Documentation.FieldDescription = " Select Row Position: #(lf) (Top or Bottom) ", 
              Documentation.AllowedValues     = {"Top", "Bottom"}
            ]
        )
      // 3.1: parameter return type   
      ) as list, 
      // ------------------------------------------------------------------
     
      // ------------------------------------------------------------------
      // 5.0: Choose between Parameter Documentation or Function Documentation
      functionDocumentation =  // -- function metadata                       
      Value.ReplaceType(
        invokeFunction, 
        Value.ReplaceMetadata(Value.Type(invokeFunction), documentation)
      ), 
      parameterDocumentation =  // -- parameter metadata                        
      Value.ReplaceType(functionDocumentation, fnType)
    in
      // ------------------------------------------------------------------
      // select one of the above steps and paste below
      // parameterDocumentation   /* <-- Choose final documentation type */
      functionDocumentation       /* <-- Choose final documentation type */                                         
in
  customFunction

```
