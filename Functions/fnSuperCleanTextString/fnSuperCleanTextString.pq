let
    CleanAndTransformText = (inputText as text, toProperCase as logical) as text =>
    let
        // Step 1: Remove underscores and replace with spaces
        noUnderscores = Text.Replace(inputText, "_", " "),

        // Step 2: Replace double spaces recursively
        ReplaceDoubleSpaces = (text as text) as text =>
        let
            replacedText = Text.Replace(text, "  ", " "),
            result = if Text.Contains(replacedText, "  ") then @ReplaceDoubleSpaces(replacedText) else replacedText
        in
            result,

        noDoubleSpaces = ReplaceDoubleSpaces(noUnderscores),

        // Step 3: Trim the text
        trimmedText = Text.Trim(noDoubleSpaces),

        // Step 4: Handle CamelCase by inserting spaces before capital letters (except at the start or after hyphens)
        HandleCamelCase = (text as text) as text =>
        let
            // Split text into characters
            charList = Text.ToList(text),
            // Initialize an empty list for the new characters
            newList = List.Transform({0..List.Count(charList)-1}, each
                if _ = 0 then
                    charList{_}
                else if charList{_} = "-" then
                    charList{_}
                else if Text.Upper(charList{_}) = charList{_} and Text.Upper(charList{_ - 1}) <> "-" and Text.Upper(charList{_}) <> Text.Lower(charList{_}) then
                    " " & charList{_}
                else
                    charList{_}),
            insertSpaces = Text.Combine(newList, "")
        in
            insertSpaces,

        camelCaseHandledText = HandleCamelCase(trimmedText),

        // Step 5: Transform to Proper Case
        ToProperCase = (text as text) as text =>
        let
            properCasedText = Text.Proper(text)
        in
            properCasedText,

        // Step 6: Transform to Sentence Case
        ToSentenceCase = (text as text) as text =>
        let
            lowerText = Text.Lower(text),
            sentenceCasedText = if Text.Length(lowerText) > 0 then
                                    Text.Upper(Text.Start(lowerText, 1)) & Text.End(lowerText, Text.Length(lowerText) - 1)
                                else
                                    lowerText
        in
            sentenceCasedText,

        // Step 7: Apply the appropriate transformation based on the toProperCase parameter
        transformedText = if toProperCase then
                             ToProperCase(camelCaseHandledText)
                          else
                             ToSentenceCase(camelCaseHandledText)
    in
        transformedText
in
    CleanAndTransformText
