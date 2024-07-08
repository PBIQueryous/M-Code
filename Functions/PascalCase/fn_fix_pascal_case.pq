// Shared by Sergey Lossev
(Source) =>
let
    to_list = Text.ToList(Source),
    accum_chars = List.Accumulate(to_list, "", (sum, x) => sum & (if x = Text.Upper(x) then " " & x else x)),
    split = Text.Split(Text.Trim(accum_chars), " "),
    accum_words = List.Accumulate(split, "", (sum, x) => sum & (if Text.Length(x) = 1 then x else " " & x & " ")),
    replace = Text.Trim(Text.Replace(accum_words, "  ", " "))
in
    replace
