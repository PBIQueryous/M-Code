# fnGetOneDriveFiles
## get file from personal OneDrive

```C#
= (URLpath) =>
  let
    // get embed code from OneDrive details
    fixURL = Text.Replace(
      Text.BetweenDelimiters(Text.BetweenDelimiters(URLpath, " ", " ", 0, 0), """", """", 0, 0), 
      "embed?", // replace old text
      "download?" // with new text
    )
      & "&app=Excel" // add suffix
  in
    Web.Contents(fixURL)
```
