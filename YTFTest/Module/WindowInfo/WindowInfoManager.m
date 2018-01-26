/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Window infomation manager.
 * =============================================================================
 */

#import "WindowInfoManager.h"
#import "Definition.h"

@implementation WindowInfoManager

+ (instancetype)shareManager
{
    static WindowInfoManager *windowInfoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        windowInfoManager = [[self alloc] init];
    });
    
    return windowInfoManager;
}

/**
 *  注入js的设备信息
 *
 *  @return
 */
+ (NSArray *)windowInfoArray
{
    NSMutableArray *arrayWindow = [NSMutableArray new];
    
    [arrayWindow addObject:@{WindowWidth : [WindowInfoManager getWindowWidth]}];
    [arrayWindow addObject:@{WindowHeight : [WindowInfoManager getWindowHeight]}];
    [arrayWindow addObject:@{WindowName : [WindowInfoManager getWindowName]}];
    // 页面内 进行参数赋值 避免JS跳转空白页面
    if ([WindowInfoManager getHtmlParam])
    {
        [arrayWindow addObject:@{HtmlParam : [WindowInfoManager getHtmlParam]}];
    }
    if ([WindowInfoManager appId]) {
        [arrayWindow addObject:@{AppId : [WindowInfoManager appId]}];
    }
    [arrayWindow addObject:@{AppName : [WindowInfoManager appName]}];
    [arrayWindow addObject:@{AppVersion : [WindowInfoManager appVersion]}];
    [arrayWindow addObject:@{FrameHeight : [WindowInfoManager getFrameHeight]}];
    [arrayWindow addObject:@{FrameWidth : [WindowInfoManager getFrameWidth]}];
    [arrayWindow addObject:@{FrameName : [WindowInfoManager getFrameName]}];
    
    return arrayWindow;
}

/**
 *  app id
 */
+ (NSString *)appId
{
    return [[YTFConfigManager shareConfigManager] configAppId];
}

/**
 *  app 名字
 */
+ (NSString *)appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
}

/**
 *  app 版本
 */
+ (NSString *)appVersion
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

/**
 *  窗口高度
 *
 *  @return
 */
+ (NSString *)getWindowHeight
{
    NSString *windowH = nil;
    if ([[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"]) {
        windowH = [NSString stringWithFormat:@"%f", (ScreenHeight - AppStatusBarHeight)];
    } else {
        windowH = [NSString stringWithFormat:@"%f", ScreenHeight ];
    }
    
    return [WindowInfoManager shareManager].windowHeight == nil ? windowH : [WindowInfoManager shareManager].windowHeight;
}

/**
 *  窗口宽度
 *
 *  @return
 */
+ (NSString *)getWindowWidth
{
    return [WindowInfoManager shareManager].windowWidth == nil ? [NSString stringWithFormat:@"%f", ScreenWidth] : [WindowInfoManager shareManager].windowWidth;
}

/**
 *  窗口名字
 *
 *  @return
 */
+ (NSString *)getWindowName
{
    return [WindowInfoManager shareManager].windowName == nil ? @"windowName" : [WindowInfoManager shareManager].windowName;
}

/**
 *  窗口参数
 *
 *  @return
 */
+ (NSString *)getHtmlParam
{
    return [WindowInfoManager shareManager].htmlParam == nil ? nil : [ToolsFunction transformStringToJSJsonWithJsonString:[WindowInfoManager shareManager].htmlParam];
}

/**
 *  子窗口高度
 *
 *  @return
 */
+ (NSString *)getFrameHeight
{
    // FIXME: 处理
    return [WindowInfoManager shareManager].frameHeight == nil ? [NSString stringWithFormat:@"%f", (ScreenHeight - AppStatusBarHeight - AppFrameWebViewTop)] : [WindowInfoManager shareManager].frameHeight;
}

/**
 *  子窗口宽度
 *
 *  @return
 */
+ (NSString *)getFrameWidth
{
    return [WindowInfoManager shareManager].frameWidth == nil ? [NSString stringWithFormat:@"%f", ScreenWidth] : [WindowInfoManager shareManager].frameWidth;
}

/**
 *  子窗口名字
 *
 *  @return
 */
+ (NSString *)getFrameName
{
    return [WindowInfoManager shareManager].frameName == nil ? @"FrameName" : [WindowInfoManager shareManager].frameName;
}

- (void)testDeallocMeth:(id)classMed{

 //   NSLog(@"...............classMed====%@.....",classMed);

}


@end
