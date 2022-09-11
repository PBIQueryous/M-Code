# fnGetSPFolder
## get files from single SP Folder

```C#
let
    Source = let
  func = 
    // fnGetSharepointFile
    let
      Source = (FullPath as text, optional SPSites as text, optional SPTeamName as text) => 
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
                                  & Binary.ToList(
                                    Binary.FromText(NextHexString, BinaryEncoding.Hex)
                                  )
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
          FileName = fnUriUnescapeString(
              Text.AfterDelimiter(FullPath, "/", {0, RelativePosition.FromEnd})
            ),
          NonRootFolders = fnUriUnescapeString(
              Text.BeforeDelimiter(
                  Text.AfterDelimiter(FullPath, ExtractRoot), 
                  "/", 
                  {0, RelativePosition.FromEnd}
                )
            ),
          SubfoldersList = List.Buffer(List.Select(Text.Split(NonRootFolders, "/"), each _ <> null and _ <> "")),
          NavigateIn = List.Accumulate(
              SubfoldersList, 
              StaticRoot, 
              (state, current) => state{[Name = current]}[Content]
            ),
          #"Filtered Rows" = Table.SelectRows(NavigateIn, each ([Name] = FileName))[Content]{0}
        in
          #"Filtered Rows"
    in
      Source,
  documentation = [
    Documentation.Name = " Sharepoint.GetFile ", 
    Documentation.Description = " Convenient way to get SP file by entering full URL. ", 
    Documentation.LongDescription
      = " Convenient way to get SP file by entering full URL. !! Root path to SP file has to be hardcoded in the function code itself !! ", 
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
