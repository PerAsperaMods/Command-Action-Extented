using BepInEx;
using BepInEx.Unity.IL2CPP;
using PerAspera.GameAPI.Commands.ModActions;

// ─────────────────────────────────────────────────────────────────
//  STEP 1 — Rename this namespace to match your project folder
// ─────────────────────────────────────────────────────────────────
namespace PerAspera.Actions.YourActionName;

[BepInPlugin(MyPluginInfo.PLUGIN_GUID, MyPluginInfo.PLUGIN_NAME, MyPluginInfo.PLUGIN_VERSION)]
[BepInDependency("com.peraspera.modsdk", BepInDependency.DependencyFlags.HardDependency)]
public sealed class YourActionNamePlugin : BasePlugin
{
    public override void Load()
    {
        // STEP 2 — Replace YourAction with your action class name
        ModTextActionRegistry.Register(new YourAction());
        Log.LogInfo($"{MyPluginInfo.PLUGIN_NAME} v{MyPluginInfo.PLUGIN_VERSION} loaded.");
    }
}
