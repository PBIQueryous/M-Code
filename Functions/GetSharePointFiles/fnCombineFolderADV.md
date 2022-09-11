# fnSPCombineFolder
## Combine files within SharePoint folder(s)

```C#
let
    Source = let
  func = 
  // fnGetAllFilesInSharepointFolder
    (FullPath as text, optional SPSites as text, optional SPTeamName as text) =>
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
          useSPName = if SPSites = null then getSPName else SPSites,
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
      #"Filtered Rows" = Table.SelectRows(
          FullResults, 
          each ([Extension] <> "" and [Extension] <> null)
        ),
      AddNameFields = Table.AddColumn(
          #"Filtered Rows", 
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
      #"Removed Columns" = Table.RemoveColumns(AddSubFolder, {"NameFields"})
    in
      #"Removed Columns",
  documentation = [
    Documentation.Name = " Sharepoint.GetAllFilesInFolder ", 
    Documentation.Description
      = " Imports all files from a SharePoint folder, inclusive subfolders. ", 
    Documentation.LongDescription
      = " Imports all files from a SharePoint folder, inclusive subfolders. !! Root path to SP file has to be hardcoded in the function code itself !! ", 
    Documentation.Category = " Accessing Data Functions ", 
    Documentation.Source = "  www.TheBIccountant.com, see:  https://wp.me/p6lgsG-2kR .  ", 
    Documentation.Version = " 1.2: 30-Mar-2021-ImprovedSpeed ", 
    Documentation.Author = " Imke Feldmann ", 
    Documentation.Examples = {[Description = "  ", Code = "  ", Result = "  "]}
  ]
in
  Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))
in
    Source
```
