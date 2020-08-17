#import "YinshiPlugin.h"
#if __has_include(<yinshi_plugin/yinshi_plugin-Swift.h>)
#import <yinshi_plugin/yinshi_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "yinshi_plugin-Swift.h"
#endif

@implementation YinshiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftYinshiPlugin registerWithRegistrar:registrar];
}
@end
