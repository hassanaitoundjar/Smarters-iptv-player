//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <azul_envato_checker/azul_envato_checker_plugin_c_api.h>
#include <screen_brightness_util_windows/screen_brightness_util_windows_plugin_c_api.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AzulEnvatoCheckerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AzulEnvatoCheckerPluginCApi"));
  ScreenBrightnessUtilWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenBrightnessUtilWindowsPluginCApi"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
