using BepInEx;
using BepInEx.Unity.IL2CPP;
using PerAspera.GameAPI.Commands.ModActions;

namespace PerAspera.Actions.AddResearchPoints;

[BepInPlugin(MyPluginInfo.PLUGIN_GUID, MyPluginInfo.PLUGIN_NAME, MyPluginInfo.PLUGIN_VERSION)]
[BepInDependency("com.peraspera.modsdk", BepInDependency.DependencyFlags.HardDependency)]
public sealed class AddResearchPointsPlugin : BasePlugin
{
    public override void Load()
    {
        ModTextActionRegistry.Register(new AddResearchPointsAction());
        Log.LogInfo($"{MyPluginInfo.PLUGIN_NAME} v{MyPluginInfo.PLUGIN_VERSION} loaded.");
    }
}
