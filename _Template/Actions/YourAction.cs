using PerAspera.Core;
using PerAspera.GameAPI.Commands.ModActions;
using PerAspera.GameAPI.Commands.ModActions.BuiltinActions;
using PerAspera.GameAPI.Events.SDK;
using PerAspera.GameAPI.Wrappers;

// ─────────────────────────────────────────────────────────────────
//  STEP 3 — Rename namespace + class + CommandName
// ─────────────────────────────────────────────────────────────────
namespace PerAspera.Actions.YourActionName;

/// <summary>
/// YAML command: YourCommandName [args...]
/// Describe what this command does here.
/// <example>
/// launchActions:
///   - command: YourCommandName
///     arguments: ["arg1", "42"]
/// </example>
/// </summary>
public sealed class YourAction : IModTextAction
{
    // STEP 4 — Rename to match your action (shown in log output)
    private static readonly LogAspera _log = new LogAspera("YourActionName");

    // STEP 5 — This is the name used in YAML (launchActions: command: ...)
    public string CommandName => "YourCommandName";

    public bool Execute(string[] args, GameCommandsReadyEvent? ctx)
    {
        // ─── Parse arguments ──────────────────────────────────────────────
        //
        // ActionContextHelper methods (all require _log and CommandName):
        //   TryGetPositiveFloat(args, index, out float val, _log, CommandName)
        //   TryGetFloat        (args, index, out float val, _log, CommandName)
        //   TryGetInt          (args, index, out int   val, _log, CommandName)
        //   TryGetString       (args, index, out string val, _log, CommandName)
        //   GetString          (args, index)  — returns null if missing, no log
        //
        if (!ActionContextHelper.TryGetPositiveFloat(args, 0, out float myValue, _log, CommandName))
            return false;

        // ─── Get the player faction ───────────────────────────────────────
        //
        // TryGetFaction returns the native Faction object — wrap it immediately.
        // ✅ All code below this point is reflection-free.
        if (!ActionContextHelper.TryGetFaction(ctx, out var nativeFaction, _log, CommandName))
            return false;

        var faction = FactionWrapper.FromNative(nativeFaction);

        // ─── Your logic here ─────────────────────────────────────────────
        //
        // Use FactionWrapper methods:
        //   faction.AddResearchPoints(amount)
        //   faction.AddResource(key, amount)
        //   faction.GetResourceStock(key)
        //   faction.HasTechnology(key)
        //
        // Other wrappers via GameApi.wrapper.*:
        //   var planet   = GameApi.wrapper.planet;   // PlanetWrapper
        //   var baseGame = GameApi.wrapper.basegame;  // BaseGameWrapper

        _log.Info($"[{CommandName}] executed with value={myValue} on '{nativeFaction!.name}'");
        return true;
    }
}
