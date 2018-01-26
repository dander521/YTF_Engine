/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    LaunchView manager.
 * =============================================================================
 */

#import "LaunchManager.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "BaseWebView.h"

@interface LaunchManager ()

@property(nonatomic, strong) UIView *launchView; // 启动view

@end

@implementation LaunchManager

// 单例
+ (instancetype)shareManager
{
    static LaunchManager *launchManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        launchManager = [[self alloc] init];
    });
    
    return launchManager;
}

/**
 *  移除导航页
 *
 *  @param webView
 */
- (void)removeLaunchWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfLaunchRemove"] = ^() {
        
        [weakself removeLaunchImageView];
    };
}

// 显示自定义启动页
- (UIView *)showLaunchImageView
{
    _launchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    imageView.image = [UIImage imageNamed:@"background"];
    [_launchView addSubview:imageView];
    
    return _launchView;
}

// 隐藏自定义启动页
- (void)removeLaunchImageView
{
    [_launchView removeFromSuperview];
    _launchView = nil;
}

@end
