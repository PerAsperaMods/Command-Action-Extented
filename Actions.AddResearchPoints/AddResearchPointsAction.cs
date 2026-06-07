using PerAspera.Core;
using PerAspera.GameAPI.Commands.ModActions;
using PerAspera.GameAPI.Commands.ModActions.BuiltinActions;
using PerAspera.GameAPI.Events.SDK;
using PerAspera.GameAPI.Wrappers;

namespace PerAspera.Actions.AddResearchPoints;

/// <summary>
/// YAML command: AddResearchPoints &lt;amount&gt;
/// Adds research points to the player faction using FactionWrapper (no reflection in mod code).
/// <example>
/// launchActions:
///   - command: AddResearchPoints
///     arguments: ["500"]
/// </example>
/// </summary>
public sealed class AddResearchPointsAction : IModTextAction
{
    private static readonly LogAspera _log = new LogAspera("AddResearchPoints");

    public string CommandName => "AddResearchPoints";

    /// <summary>
    /// Adds research points to the player faction.
    /// </summary>
    /// <param name="args">args[0] = amount (float, required, positive)</param>
    /// <param name="ctx">Game context — NativePlayerFaction must be non-null</param>
    public bool Execute(string[] args, GameCommandsReadyEvent? ctx)
    {
        if (!ActionContextHelper.TryGetPositiveFloat(args, 0, out float amount, _log, CommandName))
            return false;

        // TryGetFaction gives us the native Faction — wrap it immediately for SDK-style access
        if (!ActionContextHelper.TryGetFaction(ctx, out var nativeFaction, _log, CommandName))
            return false;

        var faction = FactionWrapper.FromNative(nativeFaction);
        bool success = faction?.AddResearchPoints(amount) ?? false;

        if (success)
            _log.Info($"[{CommandName}] +{amount} research points → '{nativeFaction!.name}'");

        return success;
    }
}
