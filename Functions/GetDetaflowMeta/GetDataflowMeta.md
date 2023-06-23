# Step 1
```ioke
//Returns all workspaces/dataflows/tables as a table for easy reference
//Useful in conjunction with the fGetPowerPlatformDataflowData function
let
    Source = 
        PowerPlatform.Dataflows(),
    Workspaces = 
        Source{[Id = "Workspaces"]}[Data],
    GR1 = 
        Table.Group(
            Workspaces,
            {"workspaceName"},
            {
                {
                    "all",
                    each _,
                    type table [
                        workspaceId = text,
                        workspaceName = text,
                        baseUrl = text,
                        Data = any,
                        ItemKind = text,
                        ItemName = text,
                        IsLeaf = logical,
                        Tags = text
                    ]
                }
            }
        ),
    ExpandWorkspaces = 
        Table.ExpandTableColumn(
            GR1, 
            "all", 
            {"Data"}, 
            {"Data"}
        ),
    ExpandWorkspace = 
        Table.ExpandTableColumn(
            ExpandWorkspaces, 
            "Data", 
            {"dataflowName", "Data"}, 
            {"dataflowName", "Data"}
        ),
    ExpandDataflow = 
        Table.ExpandTableColumn(
            ExpandWorkspace, 
            "Data", 
            {"entityName"}, 
            {"entityName"}
        ),
    CT1 = 
        Table.TransformColumnTypes(
            ExpandDataflow, 
            List.Transform(
                Table.ColumnNames(ExpandDataflow), 
                each {_, type text}
            )
        )
in
    CT1

```

# Step 2
```ioke

// Relies on the pDataflowWorkspace parameter existing
// pDataflowWorkspace defines the name (in text) of the workspace
// This avoids the need for GUIDS and makes integration with deployment pipelines simple

(DataflowName as text, TableName as text) =>
    let
        WorkspaceID =
            let
                Source = PowerPlatform.Dataflows(null),
                Workspaces = Source{[Id = "Workspaces"]}[Data],
                WSName = Table.SelectRows(Workspaces, each ([workspaceName] = pDataflowWorkspace)),
                WSID = WSName{0}[workspaceId]
            in
                WSID,
        Source = PowerPlatform.Dataflows(null),
        Workspaces = Source{[Id = "Workspaces"]}[Data],
        Workspace = Workspaces{[workspaceId = WorkspaceID]}[Data],
        Dataflow = Table.SelectRows(Workspace, each ([dataflowName] = DataflowName)),
        DataflowID = Dataflow{0}[dataflowId],
        Data = Workspace{[dataflowId = DataflowID]}[Data],
        Result = Data{[
            entity = TableName,
            version = ""
        ]}[Data]
    in
        Result
```

# Step 3
```ioke
// Use this pattern to allow direct query against the Dataflow
// Direct query can only be set at the 'Source' step
// The Dataflow functions in this repo don't allow for that option

let
    DFName = "DataflowName",
    TableName = "TableName",
    Source = PowerPlatform.Dataflows(null),
    Workspaces = Source{[Id = "Workspaces"]}[Data],
    FilterWorkspace = Table.SelectRows(Workspaces, each [workspaceName] = pDataflowWorkspace),
    DrillDownDataflows = FilterWorkspace{0}[Data],
    FilterDataflowName = DrillDownDataflows{[dataflowName = DFName]}[Data],
    DrillDownEntity = FilterDataflowName{[entity = TableName, version = ""]}[Data]
in
    DrillDownEntity

```
