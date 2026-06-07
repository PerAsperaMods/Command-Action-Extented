# Command Action Extended — Per Aspera Custom YAML Commands

A community repository of custom YAML commands (text actions) for **Per Aspera** mods.
Each action is a standalone BepInEx plugin that registers a new command usable in YAML `launchActions`.

---

## What's in here

| Project | YAML command | What it does |
|---------|-------------|--------------|
| `Actions.AddResearchPoints` | `AddResearchPoints <amount>` | Adds research points to the player faction |
| `Actions.AddResource` | `AddResource <key> <amount>` | Adds a resource to the stockpile |
| `_Template` | `YourCommandName` | Skeleton — copy this to create your own |

---

## YAML usage example

```yaml
# In your mod's event/quest/building YAML:
launchActions:
  - command: AddResearchPoints
    arguments: ["500"]

  - command: AddResource
    arguments:
      - "resource_water"
      - "1000"
```

---

## Setup

### Prerequisites

- .NET 8 SDK
- Per Aspera installed via Steam
- BepInEx 6 IL2CPP installed (launch the game once to generate interop DLLs)
- **Per Aspera SDK** installed as a BepInEx plugin — SDK DLLs are auto-detected from `BepInEx\plugins\SDK\`

### 1. Copy the path config

```powershell
Copy-Item gamelibs.props.example gamelibs.props
```

Edit `gamelibs.props` — only one required value:

```xml
<Project>
  <PropertyGroup>
    <PerAsperaGamePath>D:\SteamLibrary\steamapps\common\Per Aspera</PerAsperaGamePath>
  </PropertyGroup>
</Project>
```

> `gamelibs.props` is git-ignored — it stays local.
>
> **Building the SDK from source?** Add `<SdkDllPath>...</SdkDllPath>` to override the default auto-detect path.

### 2. Build

```powershell
dotnet build CommandActions.slnx -c Release
```

### 3. Deploy

The build will automatically copy the plugin DLL to:
```
<PerAsperaGamePath>\BepInEx\plugins\<AssemblyName>\
```

---

## Design principles

**No reflection.** Every action in this repo wraps native game objects immediately using SDK wrappers:

```csharp
// ✅ Correct — wrap native, then use SDK methods
var faction = FactionWrapper.FromNative(ctx?.NativePlayerFaction);
faction?.AddResearchPoints(amount);

// ❌ Wrong — native types + reflection
faction!.GetCurrentlyResearchedTechnology()?.AddResearchPoints(amount);
```

This makes actions:
- More stable across game updates
- Easier to read and contribute to
- Consistent with the Per Aspera SDK design

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for step-by-step instructions to add a new action.

Issues and PRs are welcome.
