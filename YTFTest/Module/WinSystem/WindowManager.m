/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFramework window operation file.
 * =============================================================================
 */

#import "WindowManager.h"
#import "BaseWebView.h"
#import "AppDelegate.h"
#import "Definition.h"
#import "FrameManager.h"
#import "FrameGroupManager.h"
#import "DrawerWinManager.h"
#import "InteractiveManager.h"
#import "NetworkManager.h"
#import "PathProtocolManager.h"
#import "YTFConfigManager.h"
#import "ToolsFunction.h"
#import "WindowInfoManager.h"
#import "BaseViewController.h"
#import "YTFAnimationManager.h"
#import "BridgeCenter.h"
// #import "YTFMovieMainClass.h"
#import <objc/message.h>
#import "Masonry.h"


typedef void(^isEditblock)(BaseWebView *baseWebObject, NSString *isEditString); // 长按弹出键盘的回调

@interface WindowManager ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic,copy) isEditblock isEditBlock; // 长按弹出键盘的回调
@property (nonatomic,copy) id proprits;


@end

@implementation WindowManager

+ (instancetype)shareManager
{
    static WindowManager *winModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        winModel = [[self alloc] init];
        winModel.appDelegate = [AppDelegate shareAppDelegate];
    });
    
    return winModel;
}

/**
 *  打开win
 *
 *  @param webView
 */
- (void)openWinWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);

    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfwinOpen"] = ^() {

        [ToolsFunction hideCustomProgress];
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];

        [WindowInfoManager shareManager].windowName = dicArgs[@"winName"];
        
        if (dicArgs[@"htmlParam"])
        {        
            [WindowInfoManager shareManager].htmlParam = [[ToolsFunction dictionaryToJsonString:dicArgs[@"htmlParam"]] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        BOOL isWinExist = false;
        BaseWebView *winWebView = nil;
        
        for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews)
        {
            if ([baseWebView isMemberOfClass:[BaseWebView class]] && [baseWebView.winName isEqualToString:dicArgs[@"winName"]])
            {
                isWinExist = true;
                winWebView = baseWebView;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.appDelegate.baseViewController.view bringSubviewToFront:winWebView];
                });
                
                break;
            }
        }

        if (!isWinExist)
        {
            NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicArgs[@"htmlUrl"] excuteWebView:weakwebView];
            
            // 创建 newWin
            winWebView = [[BaseWebView alloc] initWithFrame:CGRectMake(0, AppStatusBarHeight, ScreenWidth, ScreenHeight - AppStatusBarHeight) url:absoluteString isWindow:true];
            
            winWebView.winName = dicArgs[@"winName"];
            winWebView.delegate = weakself.appDelegate.baseViewController;
            dispatch_async(dispatch_get_main_queue(), ^{

                NSDictionary *dicAnimation = dicArgs[@"animation"];
                if (dicArgs[@"animation"] == nil)
                {
                    dicAnimation = @{@"type" : @"push",
                                     @"subType" : @"from_right",
                                     @"duration" : @"300"};
                }
                [[YTFAnimationManager sharedInstance] transitionAnimationWithDictionary:dicAnimation view:[AppDelegate shareAppDelegate].baseViewController.view];

                [weakself.appDelegate.baseViewController.view addSubview:winWebView];

                [winWebView mas_makeConstraints:^(MASConstraintMaker *make) {
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

         
                // 配置页面属性
                [weakself attrConfig:winWebView JSparam:dicArgs];
                    // 不是一级菜单  由用户来定义是否添加侧滑closeWin 手势
                    if (dicArgs[@"slipCloseWin"] != nil) {
                         winWebView.isSlipCloseWin = [dicArgs[@"slipCloseWin"] boolValue];// js端配置这个win是否需要支持滑动关闭窗口
                    }else{
                    // 自己没有配置 则系统默认添加滑动关闭窗口的操作
                         winWebView.isSlipCloseWin =YES;
                    }
                    
                
            });
        }
    };
}

/**
 *  关闭win
 *
 *  @param webView
 */
- (void)closeWinWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfwinClose"] = ^() {

        [ToolsFunction hideCustomProgress];
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        
        if (weakwebView.frameGroupName)
        {
            [[FrameGroupManager shareManager].frameGroupScrollViewDictionary removeObjectForKey:((BaseWebView *)weakwebView).frameGroupName];
            
            [[FrameGroupManager shareManager].frameGroupNamesArray removeLastObject];
            [[FrameGroupManager shareManager].frameGroupConfigsArray removeLastObject];
            [[FrameGroupManager shareManager].frameGroupCbIdsArray removeLastObject];
            [[FrameGroupManager shareManager].htmlParamDictionary removeAllObjects];
            [[FrameGroupManager shareManager].closeWinFrameArray removeAllObjects];
            [[FrameGroupManager shareManager].originXFrameArray removeAllObjects];
        }
        
        NSDictionary *dicAnimation = dicArgs[@"animation"];
        if (dicArgs[@"animation"] == nil)
        {
            dicAnimation = @{@"type" : @"push",
                             @"subType" : @"from_left",
                             @"duration" : @"300"};
        }
        [[YTFAnimationManager sharedInstance] transitionAnimationWithDictionary:dicAnimation view:[AppDelegate shareAppDelegate].baseViewController.view];
        
        if (dicArgs[@"winName"])
        {
            for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews)
            {
                if ([baseWebView isMemberOfClass:[BaseWebView class]] && [baseWebView.winName isEqualToString:dicArgs[@"winName"]])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ToolsFunction deallocModule:weakwebView];// 移除webView上所有的模块对象
                        [baseWebView removeFromSuperview];
                    });
                }
            }
        } else {
            // 操作win
            if (weakwebView.frameName != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[weakself getWinWebViewWithWebView:weakwebView] removeFromSuperview];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ToolsFunction deallocModule:weakwebView];// 移除webView上所有的模块对象
           
                    [weakwebView removeFromSuperview];
                });
            }
        }
    };    
}

/**
 *  关闭到win
 *
 *  @param webView
 */
- (void)closeToWinWithWebView:(BaseWebView *)webView
{
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfCloseToWin"] = ^() {

    };
}

- (void)appCloseWithWebView:(BaseWebView *)webView
{
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfAppClose"] = ^(NSDictionary *paramDictionary)
    {
        exit(0);
    };
}

#pragma mark - Custom Method
/**
 修改上一个win的X坐标
 */
- (void)managerSubWinFrameOriginX:(BaseWebView *)weakwebView isOpenWin:(BOOL)isOpen{
    // 打开 win
    if (isOpen) {
    if (weakwebView.frameName) {
        // 打开新win 由frameGroup上的frame执行
        if ([(weakwebView.superview) isMemberOfClass:[UIScrollView class]]) {
            ((BaseWebView *)(weakwebView.superview.superview)).frame =  CGRectMake(  -ScreenWidth,
                                                                                   ((BaseWebView *)(weakwebView.superview.superview)).frame.origin.y,
                                                                                   ((BaseWebView *)(weakwebView.superview.superview)).frame.size.width,
                                                                                   ((BaseWebView *)(weakwebView.superview.superview)).frame.size.height);
        // 由一般frame执行
        }else if ([(weakwebView.superview) isMemberOfClass:[BaseWebView class]]){
            
            ((BaseWebView *)(weakwebView.superview)).frame =  CGRectMake( -ScreenWidth,
                                                                         ((BaseWebView *)(weakwebView.superview)).frame.origin.y,
                                                                         ((BaseWebView *)(weakwebView.superview)).frame.size.width,
                                                                         ((BaseWebView *)(weakwebView.superview)).frame.size.height);
        }
        // 由一般 win 执行
       }else if(weakwebView.winName){
          weakwebView.frame =  CGRectMake(-ScreenWidth, weakwebView.frame.origin.y, weakwebView.frame.size.width, weakwebView.frame.    size.height);
       }
    }

    // 关闭 win、
    else if(!isOpen){
    
        if (weakwebView.frameName) {
            // 打开新win 由frameGroup上的frame执行
            if ([(weakwebView.superview) isMemberOfClass:[UIScrollView class]]) {
                [ToolsFunction getSubBaseWebView:(BaseWebView *)(weakwebView.superview.superview)].frame =  CGRectMake( 0,
                                                                                                                       ((BaseWebView *)(weakwebView.superview.superview)).frame.origin.y,
                                                                                                                       ((BaseWebView *)(weakwebView.superview.superview)).frame.size.width,
                                                                                                                       ((BaseWebView *)(weakwebView.superview.superview)).frame.size.height);
                // 由一般frame执行
            }else if ([(weakwebView.superview) isMemberOfClass:[BaseWebView class]]){
                
                [ToolsFunction getSubBaseWebView:((BaseWebView *)(weakwebView.superview))].frame =  CGRectMake(0,
                                                                                                               ((BaseWebView *)(weakwebView.superview)).frame.origin.y,
                                                                                                               ((BaseWebView *)(weakwebView.superview)).frame.size.width,
                                                                                                               ((BaseWebView *)(weakwebView.superview)).frame.size.height);
            }
            // 由一般 win 执行
        }else if(weakwebView.winName){
             [ToolsFunction getSubBaseWebView:weakwebView].frame =  CGRectMake(0, weakwebView.frame.origin.y, weakwebView.frame.size.width, weakwebView.frame.size.height);
        }
    }
}

// 获取操作frame关闭的win
- (BaseWebView *)getWinWebViewWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    BaseWebView *resultWebView = nil;
    // 操作frame
    for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews)
    {
        if ([baseWebView isMemberOfClass:[BaseWebView class]] && [baseWebView.subviews containsObject:webView])
        {
            resultWebView = baseWebView;
        }
    }
    
    return resultWebView;
}

/**
 *  新建的webView 属性配置
 *
 *  @param frameWebView 当前frameWebView
 *  @param dicArgs      js 传递的数据
 */
- (void)attrConfig:(BaseWebView *)winWebView JSparam:(NSDictionary *)dicArgs
{
    RCWeakSelf(self);
    RCWeakSelf(winWebView);

    if (dicArgs[@"isBounces"])
    {
        winWebView.scrollView.bounces = [[YTFConfigManager shareConfigManager] configFrameBounceWithJSParam:dicArgs[@"isBounces"]];
    }
    
    // backgroud 配置
    if (dicArgs[@"background"])
    {
        winWebView.backgroundColor = [ToolsFunction hexStringToColor:[[YTFConfigManager shareConfigManager] configWindowBackgroundColorWithJSParam:dicArgs[@"background"]]];
    }

    // delayTime 延迟加载
    if (dicArgs[@"delayTime"])
    {
        [NSTimer scheduledTimerWithTimeInterval:[dicArgs[@"delayTime"] doubleValue] target:weakself selector:@selector(delayMethod:) userInfo:@{@"newWinWebView":weakwinWebView} repeats:NO];
    }
    
    // isReload  页面已经打开时，是否重新加载页面
    if (dicArgs[@"isReload"] && [[YTFConfigManager shareConfigManager] configisReloadWithJSParam:dicArgs[@"isReload"]]) {
        [winWebView reload];
    }
    // isEdit 是否允许长按页面时弹出选择菜单
    if (dicArgs[@"isEdit"])
    {
        winWebView.isEdit = [dicArgs[@"isEdit"] boolValue];
    }
    // softInputMode
    if (dicArgs[@"softInputMode"])
    {
        [YTFConfigManager shareConfigManager].softKeyboardMode = dicArgs[@"softInputMode"];
    }
}

/**
 *  延迟加载新 Win
 *
 *  @param timer winWebView对象
 */
-(void)delayMethod:(NSTimer*)timer
{
    //RCWeakSelf(self);
    NSDictionary * asc = timer.userInfo;
    [self.appDelegate.baseViewController.view addSubview:asc[@"newWinWebView"]];
}

@end

