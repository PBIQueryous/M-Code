# fnSPCombineFolder
## Combine files within SharePoint folder(s)

```C#
let
  customFunction =  // fnCombineFolder                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: fnCombineFolder
  Acknowledgements & Inspiration: Imke Feldmann
  The BIccountant - https://www.thebiccountant.com/
 ---------------------------------*/

// 1.0: invoke function & define parameter inputs
    let
      invokeFunction = (FullPath as text, optional SPSites as text, optional SPTeamName as text) =>
      
        
// ------------------------------------------------------------------
// 2.0: function transformations
    let
      // Helper function
      fnUriUnescapeString = 
      //Source: https://stackoverflow.com/questions/36242695/how-to-decodeuricomponent-ex-2f3f263d
        (data as text) as text => 
        let
          ToList = List.Buffer(Text.ToList(data)),
          Accumulate = List.Accumulate(
              ToList, 
              [Bytes = {}], 
              (state, current) => 
                let
                  HexString = state[HexString]?,
                  NextHexString = HexString & current,
                  NextState = 
                    if HexString <> null then 
                      if Text.Length(NextHexString) = 2 then 
                        [
                          Bytes
                            = state[Bytes]
                              & Binary.ToList(Binary.FromText(NextHexString, BinaryEncoding.Hex))
                        ]
                      else 
                        [HexString = NextHexString, Bytes = state[Bytes]]
                    else if current = "%" then 
                      [HexString = "", Bytes = state[Bytes]]
                    else 
                      [Bytes = state[Bytes] & {Character.ToNumber(current)}]
                in
                  NextState
            ),
          FromBinary = Text.FromBinary(Binary.FromList(Accumulate[Bytes]))
        in
          FromBinary,
      //-- Parse FullPATH start //
          /* extract Full URL Path to dynamically obtain SharePoint root path
          can be overwritten with manual input in function Parameters */
          getSPName = Text.BeforeDelimiter( FullPath , "/", 3 ) & "/",
          useSPName = if SPSites = null then getSPName else SPSites & "/sites/",
          getString = Text.BetweenDelimiters(FullPath, "/sites/", "/"), 
          useString = if SPTeamName = null then getString else SPTeamName,
          // Parse FullPATH end --//
          //-- Apply Text Extraction
          StaticRoot = SharePoint.Contents(useSPName & useString, [ApiVersion = 15]),
      ExtractRoot = fnUriUnescapeString(Text.BeforeDelimiter(FullPath, "/", 4)),
      NonRootFolders = fnUriUnescapeString(Text.AfterDelimiter(FullPath, ExtractRoot)),
      SubfoldersList = List.Buffer(List.Select(Text.Split(NonRootFolders, "/"), each _ <> null and _ <> "")),
      GetRootContent = StaticRoot,
      NavigateIn = Table.Buffer(List.Accumulate(
          SubfoldersList, 
          GetRootContent, 
          (state, current) => state{[Name = current]}[Content]
        )),
      ListGenerate = List.Generate(
          () => [
            SelectFurtherExpansion = Table.RemoveColumns(
                Table.SelectRows(
                    Table.AddColumn(
                        NavigateIn, 
                        "ExpandFurther.1", 
                        each Type.Is(Value.Type([Content]), type table)
                      ), 
                    each ([ExpandFurther.1] = true)
                  ), 
                {"Extension"}
              ), 
            Result = Table.ExpandTableColumn(
                SelectFurtherExpansion, 
                "Content", 
                {"Content", "Name", "Extension"}, 
                {"Content", "Name.1", "Extension"}
              ), 
            Counter = 1, 
            NextIteration = true
          ], 
          each [NextIteration], 
          each [
            SelectFurtherExpansion = Table.SelectRows(
                Table.AddColumn(
                    [Result], 
                    "ExpandFurther." & Text.From([Counter] + 1), 
                    each Type.Is(Value.Type([Content]), type table)
                  ), 
                (x) => (Record.Field(x, "ExpandFurther." & Text.From([Counter] + 1)) = true)
              ), 
            RemoveExtension = Table.RemoveColumns(SelectFurtherExpansion, {"Extension"}), 
            Result = Table.ExpandTableColumn(
                RemoveExtension, 
                "Content", 
                {"Content", "Name", "Extension"}, 
                {"Content", "Name." & Text.From([Counter] + 1), "Extension"}
              ), 
            Counter = [Counter] + 1, 
            NextIteration = try Table.RowCount([Result]) > 0 otherwise false
          ], 
          each [Result]
        ),
      Combine = Table.Combine(ListGenerate),
      FilesInRoot = Table.SelectRows(NavigateIn, each Type.Is(Value.Type([Content]), type binary)),
      FullResults = FilesInRoot & Combine,
      filterRows = Table.SelectRows(
          FullResults, 
          each ([Extension] <> "" and [Extension] <> null)
        ),
      AddNameFields = Table.AddColumn(
          filterRows, 
          "NameFields", 
          each List.Select(
              Record.FieldValues(
                  Record.SelectFields(
                      _, 
                      List.Select(Record.FieldNames(_), (x) => Text.Contains(x, "Name"))
                    )
                ), 
              (y) => y <> null
            )
        ),
      AddFileName = Table.AddColumn(AddNameFields, "FileName", each List.Last([NameFields])),
      AddSubFolder = Table.AddColumn(
          AddFileName, 
          "SubFolder", 
          each Text.Combine(List.RemoveLastN([NameFields], 1), "/")
        ),
      removeColumns = Table.RemoveColumns(AddSubFolder, {"NameFields"})
    in
      removeColumns
    , 

// ------------------------------------------------------------------     
// 3.0: change parameter metadata here
      fnType = type function (
        // 3.0.1: first parameter
        dataInput as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " SharePoint folder path URL ", 
              Documentation.FieldDescription = " Full SharePoint folder path URL #(lf) e.g., https://tvca1.sharepoint.com/sites/PowerBIUserGroup-DeveloperResources/Shared%20Documents/Developer%20Resources",
              Documentation.SampleValues = {"URL from SP details pane"}
            ]
        )
       
        // 3.0.2: second parameter
        ,
         optional SPSites as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " SharePoint Base URL ", 
              Documentation.FieldDescription = " SharePoint Base URL string #(lf) e.g., https://tvca1.sharepoint.com ", 
              Documentation.SampleValues    = {"https://tvca1.sharepoint.com"}
            ]
        )
         // 3.0.3: third parameter
        ,
        optional SPTeamName as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " SharePoint Team Name ", 
              Documentation.FieldDescription = " Team Name as it appears in SharePoint #(lf) e.g., PowerBIUserGroup-DeveloperResources ", 
              Documentation.SampleValues    = {"TVCAShareDrive"}
            ]
        ) 
   // 3.1: parameter return type   
    ) as list,
// ------------------------------------------------------------------
// 4.0: edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnCombineFolder ", 
          Documentation.Description = " Extract file(s) or folder(s) from SharePoint ", 
          Documentation.LongDescription = " Extract file(s) or folder(s) from SharePoint ", 
          Documentation.Category = " ETL Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imke Feldmann - The BIccountant (https://www.thebiccountant.com/about/) ", 
          Documentation.Examples = 
          {
            [
            Description = "  Extract file(s) or folder(s) from SharePoint   ",
            Code    = " fnGetSharePointFile( FullPath, SPSites, SPTeamName ) ", 
            Result  = 
"
 1. Input SharePoint URL (from Details pane)
 2. Input base SharePoint Sites URL
 3. Input SharePoint Team Name

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
       
      ]
       ,
       
// ------------------------------------------------------------------
// 5.0: Choose between Parameter Documentation or Function Documentation
      functionDocumentation =      // -- function metadata
      Value.ReplaceType(invokeFunction, Value.ReplaceMetadata( Value.Type(invokeFunction), documentation)),
      
      parameterDocumentation =    // -- parameter metadata
      Value.ReplaceType(invokeFunction, fnType),
      
      replaceMeta =               // -- both metas
        Value.ReplaceType(
          Value.ReplaceType( invokeFunction, fnType ),
          Value.ReplaceMetadata( Value.Type(invokeFunction), documentation)
        ) 
    in
// ------------------------------------------------------------------
// select one of the above steps and paste below
      parameterDocumentation      /* <-- Choose final documentation type */
      
in
  customFunction
```
