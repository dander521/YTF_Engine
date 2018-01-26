/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Javascript excute native, javascript excute javascript.
 * =============================================================================
 */

#import "InteractiveManager.h"
#import "AppDelegate.h"
#import "Definition.h"
#import "FrameManager.h"
#import "DrawerWinManager.h"
#import "NetworkManager.h"
#import "BaseViewController.h"

@interface InteractiveManager ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation InteractiveManager

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 单例
+ (instancetype)shareManager
{
    static InteractiveManager *interactiveModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interactiveModel = [[self alloc] init];
        interactiveModel.appDelegate = [AppDelegate shareAppDelegate];
    });
    
    return interactiveModel;
}

#pragma mark - JS Interactive Native

/**
 *  JS调原生
 *
 *  @param webView
 */
- (void)JSExcuteNative:(BaseWebView *)webView
{
      [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfExcNative"] = ^(){

        NSDictionary * dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        NSString *className = dicArgs[@"className"];
        NSString *methodName = dicArgs[@"functionStr"];
        // 控制器类对象 字符串转类！
        Class targetViewControllerClass = NSClassFromString(className);
        // 创建控制器
        id targetViewController = [[targetViewControllerClass alloc] init];
        // 字符串转方法！
        // FIXME: 利用IMP和函数指针方法配合解决
        SuppressPerformSelectorLeakWarning(
          [targetViewController performSelector:NSSelectorFromString(methodName)];
        );
    };
}

#pragma mark - JS Interactive JS

/**
 *  JS调JS
 *
 *  @param webView
 */
- (void)JSExcuteJS:(BaseWebView *)webView
{
    RCWeakSelf(self);
//    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfExcJs"] = ^(){

        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        
        NSString *frameScript = dicArgs[@"script"];
        
        BaseWebView *winWebView = nil;
        
        // win
        if (dicArgs[@"winName"] && !dicArgs[@"frameGroupName"] && !dicArgs[@"frameName"])
        {
            for (BaseWebView *winWeb in weakself.appDelegate.baseViewController.view.subviews)
            {
                if ([winWeb.winName isEqualToString:dicArgs[@"winName"]])
                {
                    // win 执行script语句
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [winWeb stringByEvaluatingJavaScriptFromString:frameScript];
                    });
                    break;
                }
            }
        }
        // frame
        else if (dicArgs[@"winName"] && dicArgs[@"frameName"])
        {
            for (BaseWebView *winWeb in weakself.appDelegate.baseViewController.view.subviews)
            {
                winWebView = winWeb;
                if ([winWeb isMemberOfClass:[BaseWebView class]] && [dicArgs[@"winName"] isEqualToString:winWeb.winName])
                {
                    for (BaseWebView *frameWebView in winWeb.subviews)
                    {
                        if ([frameWebView isMemberOfClass:[BaseWebView class]] && [dicArgs[@"frameName"] isEqualToString:frameWebView.frameName])
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [frameWebView stringByEvaluatingJavaScriptFromString:frameScript];
                            });
                            break;
                        }
                    }
                }
            }
        }
        // framegroup
        else if (dicArgs[@"winName"] && dicArgs[@"frameGroupName"])
        {
            for (BaseWebView *winWeb in weakself.appDelegate.baseViewController.view.subviews)
            {
                winWebView = winWeb;
                if ([winWeb isMemberOfClass:[BaseWebView class]] && [dicArgs[@"winName"] isEqualToString:winWeb.winName])
                {
                    for (id scView in winWeb.subviews)
                    {
                        if ([scView isMemberOfClass:[UIScrollView class]])
                        {
                            for (BaseWebView *frameWebView in ((UIScrollView *)scView).subviews)
                            {
                                if ([frameWebView isMemberOfClass:[BaseWebView class]] && [dicArgs[@"index"] integerValue] == frameWebView.groupFrameIndex)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (frameWebView.isLoad == true)
                                        {
                                            [frameWebView stringByEvaluatingJavaScriptFromString:frameScript];
                                        }
                                    });
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        // 当前页面 win
        else if (dicArgs[@"winName"] == nil)
        {
            winWebView = weakself.appDelegate.baseViewController.view.subviews.lastObject;
            
            // frame
            if (dicArgs[@"frameName"])
            {
                for (BaseWebView *frameWebView in winWebView.subviews)
                {
                    if ([frameWebView isMemberOfClass:[BaseWebView class]] && [dicArgs[@"frameName"] isEqualToString:frameWebView.frameName])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [frameWebView stringByEvaluatingJavaScriptFromString:frameScript];
                        });
                        break;
                    }
                }
            }
            // framegroup
            else if (dicArgs[@"frameGroupName"])
            {
                for (id scView in winWebView.subviews)
                {
                    if ([scView isMemberOfClass:[UIScrollView class]])
                    {
                        for (BaseWebView *frameWebView in ((UIScrollView *)scView).subviews)
                        {
                            if ([frameWebView isMemberOfClass:[BaseWebView class]] && [dicArgs[@"index"] integerValue] == frameWebView.groupFrameIndex)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (frameWebView.isLoad)
                                    {
                                        [frameWebView stringByEvaluatingJavaScriptFromString:frameScript];
                                    }
                                });
                                break;
                            }
                        }
                    }
                }
            }
        }
        
        // 侧滑选择后 关闭侧滑
        if ([winWebView isMemberOfClass:[BaseWebView class]] && winWebView.isDrawerWin && winWebView.isDrawerOpen)
        {
            for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews)
            {
                if (baseWebView.isDrawerOpen && baseWebView.isDrawerWin && [baseWebView.drawerWinName isEqualToString:winWebView.drawerWinName])
                {
                    [UIView animateWithDuration:WebViewAnimationTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        
                        baseWebView.transform = CGAffineTransformIdentity;
                        
                        } completion:^(BOOL finished) {
                            
                            baseWebView.isDrawerOpen = NO;

                            [DrawerWinManager shareManager].maskingView.hidden = YES;
                    }];
                }
            }
        }
    };
}

@end
