(OriginalString as text) =>
let
    DirtyString = OriginalString,
    CharactersToKeep =
        let 
            CapitalAlphabets = { "A" .. "Z" },
            CursiveAlphabets = { "a" .. "z" },
            Numbers = { 0 .. 9 }, 
            NumbersAsText = List.Transform ( Numbers, each Number.ToText (_) ),
            RemainingCharacters = { " ", ".", "," }
        in 
            CapitalAlphabets & CursiveAlphabets & CursiveAlphabets & RemainingCharacters,
    Result = Text.Select ( DirtyString, CharactersToKeep )
in
    Result
