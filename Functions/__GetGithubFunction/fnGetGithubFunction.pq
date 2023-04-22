let
    invokeFunction = ( rawContentURL as text ) =>

let
    // "https://raw.githubusercontent.com/PBIQueryous/M-Code/main/Functions/LastRefresh/fnLastRefresh.pq"
    pathURL = rawContentURL,
    extractMCode = Text.FromBinary( Web.Contents( pathURL )),
    runMCode = Expression.Evaluate( extractMCode, #shared )
in
    runMCode
in
    invokeFunction
