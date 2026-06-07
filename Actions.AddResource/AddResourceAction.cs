using PerAspera.Core;
using PerAspera.GameAPI.Commands.ModActions;
using PerAspera.GameAPI.Commands.ModActions.BuiltinActions;
using PerAspera.GameAPI.Events.SDK;
using PerAspera.GameAPI.Wrappers;

namespace PerAspera.Actions.AddResource;

/// <summary>
/// YAML command: AddResource &lt;resourceKey&gt; &lt;amount&gt;
/// Adds a resource to the player faction's stockpile using FactionWrapper (no reflection in mod code).
/// <example>
/// launchActions:
///   - command: AddResource
///     arguments:
///       - "resource_water"
///       - "1000"
/// </example>
/// </summary>
public sealed class AddResourceAction : IModTextAction
{
    private static readonly LogAspera _log = new LogAspera("AddResource");

    public string CommandName => "AddResource";

    /// <summary>
    /// Adds a named resource to the player faction's stockpile.
    /// </summary>
    /// <param name="args">args[0] = resource key (string), args[1] = amount (float, required, positive)</param>
    /// <param name="ctx">Game context — NativePlayerFaction must be non-null</param>
    public bool Execute(string[] args, GameCommandsReadyEvent? ctx)
    {
        var resourceKey = ActionContextHelper.GetString(args, 0);
        if (resourceKey is null)
        {
            _log.Warning($"[{CommandName}] missing resource key argument at index 0");
            return false;
        }

        if (!ActionContextHelper.TryGetPositiveFloat(args, 1, out float amount, _log, CommandName))
            return false;

        // TryGetFaction gives us the native Faction — wrap it immediately for SDK-style access
        if (!ActionContextHelper.TryGetFaction(ctx, out var nativeFaction, _log, CommandName))
            return false;

        var faction = FactionWrapper.FromNative(nativeFaction);
        bool success = faction?.AddResource(resourceKey, amount) ?? false;

        if (success)
            _log.Info($"[{CommandName}] +{amount} × {resourceKey} → '{nativeFaction!.name}'");

        return success;
    }
}
