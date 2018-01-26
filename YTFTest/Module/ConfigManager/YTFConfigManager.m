/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Config manager.
 * =============================================================================
 */

#import "YTFConfigManager.h"
#import "Definition.h"
#import "RC4DecryModule.h"

@implementation YTFConfigManager

#pragma mark SingleTon

// 配置管理类
+ (instancetype)shareConfigManager
{
    static YTFConfigManager *configManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configManager = [[self alloc] init];
        [configManager parseConfigFile];
    });
    
    return configManager;
}

- (void)setLoaderParam:(NSDictionary *)dicLoader
{
    NSDictionary *dicPreference = dicLoader[Config_Preference];
    self.extendDictionary = dicPreference[Config_Extend];

    
    // basic
    self.appId = dicLoader[Config_AppId];
    self.indexSrc = dicLoader[Config_IndexSrc];
    
    // preference
    self.appBackgroundColor = dicPreference[Config_AppBG];
    self.windowBackgroundColor = dicPreference[Config_WindowBG];
    self.frameBackgroundColor = dicPreference[Config_FrameBG];
    self.windowBounce = dicPreference[Config_WindowBounce];
    self.frameBounce = dicPreference[Config_FrameBounce];
    self.horizonScrollBar = dicPreference[Config_HScrollBar];
    self.veticalScrollBar = dicPreference[Config_VScrollBar];
    self.autoLaunch = dicPreference[Config_AutoLaunch];
    self.statusBarAppearance = dicPreference[Config_StatusBarAppearance];
    self.fullScreen = dicPreference[Config_FullScreen];
    self.softKeyboardMode = dicPreference[Config_SoftKeyboardMode];
    self.webScale = dicPreference[Config_WebViewScale];
    self.isDebugMode = [dicPreference[Config_Debug] boolValue];
    self.frameGroupBackgroundColor = dicPreference[Config_FrameGroupBG];
    self.leftZone = dicPreference[Config_leftZone];
    self.leftEdge = dicPreference[Config_leftEdge];
}

// 解析config文件
- (void)parseConfigFile
{
    
#ifdef DecryMode

    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"assets/widget/config.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:configFilePath];
    
    if (data == nil)
    {
        return;
    }
    
    NSData *decryData = [RC4DecryModule dataDecry_RC4WithByteArray:(Byte *)[data bytes] key:DecryKey fileData:data];
    NSDictionary *dicJson = [NSJSONSerialization JSONObjectWithData:decryData options:NSJSONReadingMutableContainers error:nil];
#else
    
    NSDictionary *dicJson = [ToolsFunction JsonFileToDictionaryWithFileRelativePath:@"assets/widget/config.json"];
#endif
    
    NSDictionary *dicPreference = dicJson[Config_Preference];
    self.extendDictionary = dicPreference[Config_Extend];
    
    // basic
    self.appId = dicJson[Config_AppId];
    self.indexSrc = dicJson[Config_IndexSrc];
    
    // preference
    self.appBackgroundColor = dicPreference[Config_AppBG];
    self.windowBackgroundColor = dicPreference[Config_WindowBG];
    self.frameBackgroundColor = dicPreference[Config_FrameBG];
    self.windowBounce = dicPreference[Config_WindowBounce];
    self.frameBounce = dicPreference[Config_FrameBounce];
    self.horizonScrollBar = dicPreference[Config_HScrollBar];
    self.veticalScrollBar = dicPreference[Config_VScrollBar];
    self.autoLaunch = dicPreference[Config_AutoLaunch];
    self.statusBarAppearance = dicPreference[Config_StatusBarAppearance];
    self.fullScreen = dicPreference[Config_FullScreen];
    self.softKeyboardMode = dicPreference[Config_SoftKeyboardMode];
    self.webScale = dicPreference[Config_WebViewScale];
    self.isDebugMode = [dicPreference[Config_Debug] boolValue];
    self.frameGroupBackgroundColor = dicPreference[Config_FrameGroupBG];
    self.leftZone = dicPreference[Config_leftZone];
    self.leftEdge = dicPreference[Config_leftEdge];
    
}


#pragma mark - Basic Config

// 获取 appid
- (NSString *)configAppId
{
    return self.appId;
}

// 获取 启动页路径
- (NSString *)configIndexSrc
{
    return self.indexSrc;
}


#pragma mark - Preference

// 设置 app背景颜色
- (NSString *)configAppBackgroundColorWithJSParam:(NSString *)appBG
{
    return (appBG == nil && self.appBackgroundColor == nil) ? Default_AppBG : (appBG == nil ? self.appBackgroundColor : appBG);
}

// 设置 window背景颜色
- (NSString *)configWindowBackgroundColorWithJSParam:(NSString *)winBG
{
    return (winBG == nil && self.windowBackgroundColor == nil) ? Default_WindowBG : (winBG == nil ? self.windowBackgroundColor : winBG);
}

// 设置 frame背景颜色
- (NSString *)configFrameBackgroundColorWithJSParam:(NSString *)frameBG
{
    return (frameBG == nil && self.frameBackgroundColor == nil) ? Default_FrameBG : (frameBG == nil ? self.frameBackgroundColor : frameBG);
}

// 设置 frameGroup背景颜色
- (NSString *)configFrameGroupBackgroundColorWithJSParam:(NSString *)frameGroupBG{


    return (frameGroupBG == nil && self.frameGroupBackgroundColor == nil) ? Default_FrameGroupBG : (frameGroupBG == nil ? self.frameGroupBackgroundColor : frameGroupBG);
}

// 设置 沉浸式效果
- (NSString *)configStatusBarAppearanceWithJSParam:(NSString *)statusBarAppearance
{
    return (statusBarAppearance == nil && self.statusBarAppearance == nil) ? Default_StatusBarAppearance : (statusBarAppearance == nil ? self.statusBarAppearance : statusBarAppearance);
}

// 设置 键盘弹出方式
- (NSString *)configSoftKeyboardModeWithJSParam:(NSString *)softKeyboardMode
{
    return (softKeyboardMode == nil && self.softKeyboardMode == nil) ? Default_SoftKeyboardMode : (softKeyboardMode == nil ? self.softKeyboardMode : softKeyboardMode);
}


// 设置 window页面是否弹动
- (BOOL)configWindowBounceWithJSParam:(NSNumber *)winBounce
{
    return (winBounce == nil && self.windowBounce == nil) ? [Default_WindowBounce boolValue] : (winBounce == nil ? [self.windowBounce boolValue] : [winBounce boolValue]);
}

// 设置 frame页面是否弹动
- (BOOL)configFrameBounceWithJSParam:(NSNumber *)frameBounce
{
    return (frameBounce == nil && self.frameBounce == nil) ? [Default_FrameBounce boolValue] : (frameBounce == nil ? [self.frameBounce boolValue] : [frameBounce boolValue]);
}

// 设置 WebView页面是否可以缩放
- (BOOL)configWebViewScaleWithJSParam:(NSNumber *)webScale{

    return (webScale == nil && self.frameBounce == nil) ? [Default_WebViewScale boolValue] : (webScale == nil ? [self.frameBounce boolValue] : [webScale boolValue]);

}

// 设置 水平滚动条
- (BOOL)configHorizonScrollBarWithJSParam:(NSNumber *)hScrollBar
{
    return (hScrollBar == nil && self.horizonScrollBar == nil) ? [Default_HScrollBar boolValue] : (hScrollBar == nil ? [self.horizonScrollBar boolValue] : [hScrollBar boolValue]);
}

// 设置 垂直滚动条
- (BOOL)configVeticalScrollBarWithJSParam:(NSNumber *)vScrollBar
{
    return (vScrollBar == nil && self.veticalScrollBar == nil) ? [Default_VScrollBar boolValue] : (vScrollBar == nil ? [self.veticalScrollBar boolValue] : [vScrollBar boolValue]);
}

// 设置 启动页是否自动隐藏
- (BOOL)configAutoLaunchWithJSParam:(NSNumber *)autoLaunch
{
    return (autoLaunch == nil && self.autoLaunch == nil) ? [Default_AutoLaunch boolValue] : (autoLaunch == nil ? [self.autoLaunch boolValue] : [autoLaunch boolValue]);
}

// 设置 全屏运行
- (BOOL)configFullScreenWithJSParam:(NSNumber *)fullScreen
{
    return (fullScreen == nil && self.fullScreen == nil) ? [Default_FullScreen boolValue] : (fullScreen == nil ? [self.fullScreen boolValue] : [fullScreen boolValue]);
}

// 设置 是否重新加载页面
- (BOOL)configisReloadWithJSParam:(NSNumber *)isReload{

    return (isReload == nil ) ? [Default_isReload boolValue] : [isReload boolValue];
}

// 设置 是否允许长按页面时弹出选择菜单
- (NSString *)configisEditWithJSParam:(NSNumber *)isEdit{

    return (isEdit == nil || [isEdit boolValue] == NO) ? Default_isEditConfuse : Default_isEditAllow;
}

// 设置 frame 组是否能够左右滚动
- (BOOL)configisScrollWithJSParam:(NSNumber *)isScroll{
    
    return (isScroll == nil ) ? [Default_isScroll boolValue] : [isScroll boolValue];
}

// 设置 frame 组是否可以循环滑动，滑动到最后返回第一个frame
- (BOOL)configisLoopWithJSParam:(NSNumber *)isLoop{
    
    return (isLoop == nil ) ? [Default_isLoop boolValue] : [isLoop boolValue];
}

// 设置 是否支持多选，默认不支持多选
- (NSInteger)configisCheckboxWithJSParam:(NSNumber *)isCheckbox{

   
   return (isCheckbox == nil || [isCheckbox boolValue] == NO ) ? Default_isCheckbox  : Default_isCheckboxMutable;
}

// 设置 是否支持裁剪，默认不支持。
- (BOOL)configPictureIsEdit:(BOOL)picIsEdit{
    
    return (picIsEdit == NO) ? [Default_isPicEditConfuse boolValue ]: [Default_isPicEdit boolValue];
}

// 设置 侧滑的有效范围。
- (NSNumber *)configLeftZone:(NSNumber *)leftZone{
    
    return ([leftZone floatValue] == 0 && self.leftZone == nil) ? Default_leftZone: (leftZone == nil ? self.leftZone : leftZone);

}

// 设置 侧滑的有效范围。
- (NSNumber *)configLeftEdge:(NSNumber *)leftEdge{
    
    return ([leftEdge intValue] == 0 && self.leftEdge == nil) ? Config_leftEdge: (leftEdge == nil ? self.leftEdge : leftEdge);
    
}



@end
