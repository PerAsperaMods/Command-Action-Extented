# Contributing — Adding a New YAML Command

This guide walks you through adding a custom YAML text action to this repository.

---

## Step-by-step

### 1. Copy the template

```powershell
Copy-Item -Recurse _Template Actions.YourActionName
```

### 2. Rename the project file

```powershell
Rename-Item Actions.YourActionName\_Template.csproj Actions.YourActionName.csproj
```

### 3. Update the .csproj properties

Open `Actions.YourActionName\Actions.YourActionName.csproj` and set:

```xml
<AssemblyName>PerAspera.Action.YourActionName</AssemblyName>
<RootNamespace>PerAspera.Actions.YourActionName</RootNamespace>
<BepInExPluginGuid>com.peraspera.actions.youractionname</BepInExPluginGuid>
<BepInExPluginName>Action — Your Action Name</BepInExPluginName>
<BepInExPluginVersion>1.0.0</BepInExPluginVersion>
```

### 4. Rename and update Plugin.cs

- Change `namespace` → `PerAspera.Actions.YourActionName`
- Change class name → `YourActionNamePlugin`
- Change `new YourAction()` → `new YourRealAction()`

### 5. Rename and update Actions\YourAction.cs

- Change `namespace` → `PerAspera.Actions.YourActionName`
- Change class name → `YourRealAction`
- Set `CommandName` to the YAML key users will type
- Implement `Execute(string[] args, GameCommandsReadyEvent? ctx)`

### 6. Add to the solution

```powershell
dotnet sln add Actions.YourActionName/Actions.YourActionName.csproj
```

### 7. Build and test

```powershell
dotnet build CommandActions.slnx -c Release
```

Then launch Per Aspera and verify your command appears in the BepInEx log:
```
[Info] Action — Your Action Name v1.0.0 loaded.
```

---

## The IModTextAction contract

```csharp
public interface IModTextAction
{
    string CommandName { get; }
    bool Execute(string[] args, GameCommandsReadyEvent? ctx);
}
```

| Member | Notes |
|--------|-------|
| `CommandName` | Exact string used in YAML `command:` field. Case-sensitive. |
| `Execute` | Return `true` on success, `false` on failure. BepInEx will log failures. |
| `args` | Arguments from YAML `arguments:` list (all strings). |
| `ctx` | Game context at execution time. Can be `null` outside a game session. |

---

## ActionContextHelper reference

```csharp
// Argument parsing (log + return false on failure)
ActionContextHelper.TryGetString(args, 0, out string val, CommandName);
ActionContextHelper.TryGetFloat (args, 0, out float  val, CommandName);
ActionContextHelper.TryGetInt   (args, 0, out int    val, CommandName);

// Standard log messages
ActionContextHelper.LogSuccess      (CommandName, "detail");
ActionContextHelper.LogMissingContext(CommandName, "FieldName");
```

---

## Available wrappers

```csharp
// From context
var faction  = FactionWrapper.FromNative(ctx?.NativePlayerFaction);

// From singleton
var baseGame = BaseGameWrapper.GetCurrent();
var planet   = PlanetWrapper.GetCurrent();
var universe = UniverseWrapper.GetCurrent();

// From GameApi
var baseGame = GameApi.wrapper.basegame;
var planet   = GameApi.wrapper.planet;
```

See the [Per Aspera SDK docs](https://github.com/your-org/ModPeraspera/wiki) for full wrapper API reference.

---

## Rules for PRs

1. **No reflection** — use SDK wrappers only (`FactionWrapper`, `PlanetWrapper`, etc.)
2. **No bare `Type`** — always `System.Type` for static type declarations
3. **One action per project** — keeps plugins independent and deployable separately
4. **XML doc on `Execute`** — `<summary>` + `<example>` required
5. Update the table in `README.md` with your new command

---

## Need help?

Open an issue or look at `Actions.AddResearchPoints` and `Actions.AddResource` for complete working examples.
