/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Path protocol manager.
 * =============================================================================
 */

#import "PathProtocolManager.h"
#import "Definition.h"
#import "BaseWebView.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

#define RootRelativePath        @"/"

#define CurrentRelativePath     @"./"

#define ParentRelativePath      @"../"

#define HttpProtocolPath        @"http"

#define AssetsProtocolPath      @"assets/"

#define MapProtocolPath         @"map"

#define WidgetProtocolPath      @"widget:///"

#define CacheProtocolPath       @"cache:///"

#define FSProtocolPath          @"fs:///"

#define DownloadProtocolPath    @"download:///"

@implementation PathProtocolManager

// 单例
+ (instancetype)shareManager
{
    static PathProtocolManager *pathProtocolManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pathProtocolManager = [[self alloc] init];
    });
    
    return pathProtocolManager;
}

/**
 *  获取路径
 *
 *  @param pathString       路径参数
 *  @param excuteWebView    执行环境
 *
 *  @return 转换的可用路径
 */
- (NSString *)getWebViewUrlWithString:(NSString *)pathString excuteWebView:(BaseWebView *)excuteWebView
{
    NSString *resultPath = nil;
    // 包含相对路径 /、./、../ html/win.html
    if ([pathString hasPrefix:RootRelativePath] || [pathString hasPrefix:CurrentRelativePath] || [pathString hasPrefix:ParentRelativePath])
    {
        NSURL *pathAbsoluteUrl = [NSURL URLWithString:pathString relativeToURL:((BaseWebView *)excuteWebView).webViewUrl];
        resultPath = pathAbsoluteUrl.absoluteString;
    } else if ([pathString hasPrefix:HttpProtocolPath])
    {
        // http:
        resultPath = pathString;
    } else if ([pathString hasPrefix:MapProtocolPath])
    {
        // map://
        resultPath = [FilePathCustomMap stringByAppendingPathComponent:[pathString substringFromIndex:11]];
        [AppDelegate shareAppDelegate].baseViewController.indexWebView.webViewUrl = [NSURL URLWithString:resultPath];
    } else if ([pathString hasPrefix:WidgetProtocolPath])
    {
        // widget://
        resultPath = [PathProtocolManager getWebViewUrlWithWidgetProtocolPath:pathString];
    } else if ([pathString hasPrefix:AssetsProtocolPath])
    {
        // assets
        resultPath = [FilePathCustomAssets stringByAppendingPathComponent:[pathString substringFromIndex:7]];
    } else if ((![pathString containsString:RootRelativePath] && ![pathString containsString:@":"]) ||
               ([pathString containsString:RootRelativePath] && [pathString containsString:@"."]))
    {
        // newWin.html
        // html/newWin.html
        pathString = [NSString stringWithFormat:@"%@%@", CurrentRelativePath, pathString];
        resultPath = [[PathProtocolManager shareManager] getWebViewUrlWithString:pathString excuteWebView:excuteWebView];
    }
    
    if ([resultPath hasPrefix:@"///"])
    {
        resultPath = [resultPath substringFromIndex:2];
    }

    return resultPath;
}

/**
 *  widget://协议
 *
 *  @param widgetProtocolPath widget相对路径
 *
 *  @return widget绝对路径
 */
+ (NSString *)getWebViewUrlWithWidgetProtocolPath:(NSString *)widgetProtocolPath
{
#ifdef Loader
    if (LoaderJudget) {
        NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEHost];
        NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEWebPort];
        NSString *appId = [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId];
        NSString *result = [NSString stringWithFormat:@"http://%@:%@/%@", host, port, appId];
        return [result stringByAppendingPathComponent:[widgetProtocolPath substringFromIndex:9]];
    }else{
    
        return [FilePathAppResourcesWidget stringByAppendingPathComponent:[widgetProtocolPath substringFromIndex:9]];
   }
    
#else
    return [FilePathAppResourcesWidget stringByAppendingPathComponent:[widgetProtocolPath substringFromIndex:9]];
#endif
}

/**
 *  cache://协议
 *
 *  @param cacheprotocolPath cache相对路径
 *
 *  @return cache绝对路径
 */
+ (NSString *)getWebViewUrlWithCacheProtocolPath:(NSString *)cacheprotocolPath
{
    return [FilePathCustomCache stringByAppendingPathComponent:[cacheprotocolPath substringFromIndex:8]];
}

/**
 *  fs://协议
 *
 *  @param fsProtocolPath fs相对路径
 *
 *  @return fs绝对路径
 */
+ (NSString *)getWebViewUrlWithFSProtocolPath:(NSString *)fsProtocolPath
{
    return [FilePathCustomFS stringByAppendingPathComponent:[fsProtocolPath substringFromIndex:5]];
}

/**
 *  download://协议
 *
 *  @param downloadProtocolPath download相对路径
 *
 *  @return download绝对路径
 */
+ (NSString *)getWebViewUrlWithDownloadProtocolPath:(NSString *)downloadProtocolPath
{
    return [FilePathCustomDownload stringByAppendingPathComponent:[downloadProtocolPath substringFromIndex:11]];
}

@end
