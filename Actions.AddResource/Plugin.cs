using BepInEx;
using BepInEx.Unity.IL2CPP;
using PerAspera.GameAPI.Commands.ModActions;

namespace PerAspera.Actions.AddResource;

[BepInPlugin(MyPluginInfo.PLUGIN_GUID, MyPluginInfo.PLUGIN_NAME, MyPluginInfo.PLUGIN_VERSION)]
[BepInDependency("com.peraspera.modsdk", BepInDependency.DependencyFlags.HardDependency)]
public sealed class AddResourcePlugin : BasePlugin
{
    public override void Load()
    {
        ModTextActionRegistry.Register(new AddResourceAction());
        Log.LogInfo($"{MyPluginInfo.PLUGIN_NAME} v{MyPluginInfo.PLUGIN_VERSION} loaded.");
    }
}
