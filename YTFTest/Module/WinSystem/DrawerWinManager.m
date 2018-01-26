/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFramework drawerWin operation file.
 * =============================================================================
 */

#import "DrawerWinManager.h"
#import "AppDelegate.h"
#import "Definition.h"
#import "WindowManager.h"
#import "FrameManager.h"
#import "YTFConfigManager.h"
#import "BaseWebView.h"
#import "InteractiveManager.h"
#import "PathProtocolManager.h"
#import "WindowInfoManager.h"
#import "BaseViewController.h"
#import "Masonry.h"

@interface DrawerWinManager ()

@property (nonatomic, strong) AppDelegate *appDelegate;


@end

@implementation DrawerWinManager

// 单例
+ (instancetype)shareManager
{
    static DrawerWinManager *drawerWinModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        drawerWinModel = [[self alloc] init];
        drawerWinModel.appDelegate = [AppDelegate shareAppDelegate];
       //  创建蒙板
        drawerWinModel.maskingView = [MaskingView shareInstanceMaskingView];
        
    });
    
    return drawerWinModel;
}

/**
 *  生成DrawerWin
 *
 *  @param webView
 */
- (void)openDrawerWinWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfdrawerWinOpen"] = ^() {
    
        [ToolsFunction hideCustomProgress];
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        // 程序首次加载
        // 创建 mianWin
        BaseWebView *baseWebView = nil;
        if ([dicArgs[@"drawerName"] isEqualToString:@"side"])
        {
            // sideWin
            BaseWebView *sideWebView = nil;
            
            NSString *sideWinAbsolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicArgs[@"sidePane"][@"htmlUrl"] excuteWebView:weakwebView];
            // 创建sideWin
            sideWebView = [[BaseWebView alloc] initWithFrame:CGRectMake(SideWinOriginX, AppStatusBarHeight, SideWinWidth, ScreenHeight - AppStatusBarHeight) url:sideWinAbsolutePath isWindow:true];
            sideWebView.isDrawerSide = true;
            sideWebView.winName =  dicArgs[@"sidePane"][@"sideName"];
            sideWebView.delegate = weakself.appDelegate.baseViewController;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.appDelegate.baseViewController.view addSubview:sideWebView];

                // 调整sidewin mainwin 位置 处理map协议 webview 位置问题
//                [weakself.appDelegate.baseViewController.view insertSubview:weakwebView belowSubview:sideWebView];
                
                [sideWebView mas_makeConstraints:^(MASConstraintMaker *make) {
                    if ([[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
                    {
                        make.top.equalTo(weakself.appDelegate.baseViewController.view).with.offset(AppStatusBarHeight);
                    } else {
                        make.top.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                    }
                    make.bottom.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
//                    make.left.equalTo(weakself.appDelegate.baseViewController.view).with.offset(SideWinOriginX);
                    make.right.equalTo(weakself.appDelegate.baseViewController.view).with.offset(-ScreenWidth);
                    make.width.mas_equalTo(SideWinWidth);
                }];
            });

            if (![[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
            {
                weakwebView.frame = CGRectMake(SideWinOriginX, 0, SideWinWidth, ScreenHeight);
            } else {
                weakwebView.frame = CGRectMake(SideWinOriginX, AppStatusBarHeight, SideWinWidth, ScreenHeight - AppStatusBarHeight);
            }
            
            NSString *absolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicArgs[@"mainPane"][@"htmlUrl"] excuteWebView:weakwebView];
            // 创建 mianWin
            baseWebView = [[BaseWebView alloc] initWithFrame:CGRectMake(0, AppStatusBarHeight, ScreenWidth, ScreenHeight - AppStatusBarHeight) url:absolutePath isWindow:true];
            baseWebView.winName = dicArgs[@"mainPane"][@"mainName"];
            baseWebView.delegate = weakself.appDelegate.baseViewController;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.appDelegate.baseViewController.view addSubview:baseWebView];
                // 调整sidewin mainwin 位置 处理map协议 webview 位置问题
//                [weakself.appDelegate.baseViewController.view insertSubview:weakwebView belowSubview:baseWebView];
                
                [baseWebView mas_makeConstraints:^(MASConstraintMaker *make) {
                    if ([[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
                    {
                        make.top.equalTo(weakself.appDelegate.baseViewController.view).with.offset(AppStatusBarHeight);
                    } else {
                        make.top.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                    }
                    make.bottom.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                    make.left.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                    make.right.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                }];
            });
            
            [BaseWebView configDrawerBaseWebView:@[sideWebView, baseWebView] drawerName:dicArgs[@"drawerName"]];
    
         
        } else {
            
            if (dicArgs[@"mainPane"][@"htmlParam"])
            {
                [WindowInfoManager shareManager].htmlParam = [[ToolsFunction dictionaryToJsonString:dicArgs[@"mainPane"][@"htmlParam"]] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            }
            
            // sideWin
            BaseWebView *sideWebView = nil;

            NSString *sideWinAbsolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicArgs[@"sidePane"][@"htmlUrl"] excuteWebView:weakwebView];
            // 创建sideWin
            sideWebView = [[BaseWebView alloc] initWithFrame:CGRectMake(SideWinOriginX, AppStatusBarHeight, SideWinWidth, ScreenHeight - AppStatusBarHeight) url:sideWinAbsolutePath isWindow:true];
            sideWebView.isDrawerSide = true;
            sideWebView.winName =  dicArgs[@"sidePane"][@"sideName"];
            sideWebView.delegate = weakself.appDelegate.baseViewController;
           
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.appDelegate.baseViewController.view addSubview:sideWebView];
                
                [sideWebView mas_makeConstraints:^(MASConstraintMaker *make) {
                    if ([[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
                    {
                        make.top.equalTo(weakself.appDelegate.baseViewController.view).with.offset(AppStatusBarHeight);
                    } else {
                        make.top.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                    }
                    make.bottom.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
//                    make.left.equalTo(weakself.appDelegate.baseViewController.view).with.offset(SideWinOriginX);
                    make.right.equalTo(weakself.appDelegate.baseViewController.view).with.offset(-ScreenWidth);
                    make.width.mas_equalTo(SideWinWidth);
                }];
            });
            
            // mainWin
            NSString *mainWinAbsolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicArgs[@"mainPane"][@"htmlUrl"] excuteWebView:weakwebView];
            baseWebView = [[BaseWebView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - AppStatusBarHeight) url:mainWinAbsolutePath isWindow:true];
            baseWebView.winName = dicArgs[@"mainPane"][@"mainName"];
            baseWebView.scrollView.bounces = false;
            baseWebView.delegate = weakself.appDelegate.baseViewController;
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.appDelegate.baseViewController.view addSubview:baseWebView];
                
                [baseWebView mas_makeConstraints:^(MASConstraintMaker *make) {
                    if ([[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
                    {
                        make.top.equalTo(weakself.appDelegate.baseViewController.view).with.offset(AppStatusBarHeight);
                    } else {
                        make.top.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                    }
                    make.bottom.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                    make.left.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                    make.right.equalTo(weakself.appDelegate.baseViewController.view).with.offset(0);
                }];
            });
            
            [UIView animateWithDuration:WebViewAnimationTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                CGRect tempFrame = baseWebView.frame;
                tempFrame.origin.y = ![[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"] ? 0 : AppStatusBarHeight;
                baseWebView.frame = tempFrame;
            } completion:^(BOOL finished) {
                
            }];
            
            [BaseWebView configDrawerBaseWebView:@[sideWebView, baseWebView] drawerName:dicArgs[@"drawerName"]];
            
                  }
        //配置侧滑属性
        baseWebView.leftEdge  = dicArgs[@"sideDrawerStyle"][@"leftEdge"];
        baseWebView.leftZone  = dicArgs[@"sideDrawerStyle"][@"leftZone"];
        baseWebView.leftScale = dicArgs[@"sideDrawerStyle"][@"leftScale"];
        
        // 配置页面属性
        [weakself attrConfig:weakwebView JSparam:dicArgs];
    };
}

/**
 *  移除DrawerWin
 *
 *  @param webView
 */
- (void)closeDrawerWinWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfdrawerWinClose"] = ^() {
        [ToolsFunction hideCustomProgress];
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        
        if (dicArgs[@"drawerName"])
        {
            for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews)
            {
                if (baseWebView.isDrawerWin && [baseWebView.drawerWinName isEqualToString:dicArgs[@"drawerName"]])
                {
                    [UIView animateWithDuration:WebViewAnimationTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        CGRect tempFrame = baseWebView.frame;
                        tempFrame.origin.y = ScreenHeight;
                        baseWebView.frame = tempFrame;
                    } completion:^(BOOL finished) {
                        [baseWebView removeFromSuperview];
                    }];
                }
            }
        } else {
            // 移除mainwin sidewin
            NSString *drawerName = weakwebView.drawerWinName;
            
            for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews)
            {
                if (baseWebView.isDrawerWin && [baseWebView.drawerWinName isEqualToString:drawerName])
                {
                    [UIView animateWithDuration:WebViewAnimationTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        CGRect tempFrame = baseWebView.frame;
                        tempFrame.origin.y = ScreenHeight;
                        baseWebView.frame = tempFrame;
                    } completion:^(BOOL finished) {
                        [baseWebView removeFromSuperview];
                    }];
                }
            }
        }
    };
}

/**
 *  打开DrawerWin
 *
 *  @param webView
 */
- (void)openDrawerWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfDrawerOpen"] = ^() {
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        
        if (dicArgs[@"sideName"])
        {
            
            BaseWebView *sideWebView = nil;
            BaseWebView *mainWebView = nil;
            for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews) {
                
               mainWebView = [weakself.appDelegate.baseViewController.view.subviews lastObject];
                if ([baseWebView.drawerWinName isEqualToString:mainWebView.drawerWinName] && baseWebView!=mainWebView) {
                    sideWebView = baseWebView;
                }
       }
                    //  打开状态
                    if (mainWebView.isDrawerOpen)
                    {
                        [UIView animateWithDuration:WebViewAnimationTime delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                            //因为手势操作类的实现是用了transform  多以这里最好也用这个回复位置
                            mainWebView.transform = CGAffineTransformIdentity;
                            mainWebView.isDrawerOpen = NO;
                            
                            sideWebView.transform = CGAffineTransformIdentity;
                            sideWebView.isDrawerOpen = NO;
                            
                            //移除蒙板
                            self.maskingView.hidden = YES;
                            
                        } completion:^(BOOL finished) {
                            
                        }];
                    } else {
                        // JS执行方法
                     [[InteractiveManager shareManager] JSExcuteJS:weakself.appDelegate.baseViewController.indexWebView];
                        // 关闭状态
                        [UIView animateWithDuration:WebViewAnimationTime delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                            mainWebView.transform = CGAffineTransformMakeTranslation(SideWinWidth, 0);
                            mainWebView.isDrawerOpen = YES;
                            
                            sideWebView.transform = CGAffineTransformMakeTranslation(SideWinWidth, 0);
                            sideWebView.isDrawerOpen = YES;
                            
                            // 创建蒙板
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [MaskingView showMaskView:self.maskingView baseWebView:mainWebView sideweb:sideWebView];
                            });

                        } completion:^(BOOL finished) {
                            
                        }];
                    }
        }
    };
}

/**
 *  关闭DrawerWin
 *
 *  @param webView
 */
- (void)closeDrawerWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfDrawerClose"] = ^() {

        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        
        if (dicArgs[@"drawerName"])
        {
            for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews)
            {
                if (baseWebView.isDrawerOpen && baseWebView.isDrawerWin && [baseWebView.drawerWinName isEqualToString:dicArgs[@"sideName"]])
                {
                    [UIView animateWithDuration:WebViewAnimationTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                       baseWebView.transform = CGAffineTransformIdentity;

                    } completion:^(BOOL finished) {
                        baseWebView.isDrawerOpen = NO;
                        [MaskingView shareInstanceMaskingView].hidden = YES;
                    }];
                }
            }
        } else {
            // FIXME: dicArgs[@"sideName"] == nil
        }
    };
}

/**
 *  锁定DrawerWin
 *
 *  @param webView
 */
- (void)lockDrawerWinWithWebView:(BaseWebView *)webView
{

}

/**
 *  解锁DrawerWin
 *
 *  @param webView
 */
- (void)unlockDrawerWinWithWebView:(BaseWebView *)webView
{
    
}

/**
 *  新建的webView 属性配置
 *
 *  @param frameWebView 当前frameWebView
 *  @param dicArgs      js 传递的数据
 */
- (void)attrConfig:(UIWebView *)winWebView JSparam:(NSDictionary *)dicArgs
{
    //isReload  页面已经打开时，是否重新加载页面
    if (dicArgs[@"isReload"] && [[YTFConfigManager shareConfigManager] configisReloadWithJSParam:dicArgs[@"isReload"]])
    {
        [winWebView reload];
    }
}
@end
