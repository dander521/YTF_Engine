
/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>  presented by : Evyn_Lee
 *  @created        2015-10-10
 *  @description    YTFramework frame operation file.
 * =============================================================================
 */

#import "FrameManager.h"
#import "AppDelegate.h"
#import "Definition.h"
#import "BaseWebView.h"
#import "WindowManager.h"
#import "InteractiveManager.h"
#import "NetworkManager.h"
#import "BaseWebView.h"
#import "PathProtocolManager.h"
#import "YTFConfigManager.h"
#import "WindowInfoManager.h"
#import "BaseViewController.h"
#import <objc/message.h>
#import "Masonry.h"

@interface FrameManager ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@end

@implementation FrameManager
// 单例
+ (instancetype)shareManager
{
    static FrameManager *frameModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        frameModel = [[self alloc] init];
        frameModel.appDelegate = [AppDelegate shareAppDelegate];
    });
    return frameModel;
}
/**
 *  打开frame
 *
 *  @param webView
 */
- (void)openFrameWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfframeOpen"] = ^() {
        [ToolsFunction hideCustomProgress];
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        
        [WindowInfoManager shareManager].frameName = dicArgs[@"frameName"];
        [WindowInfoManager shareManager].frameWidth = dicArgs[@"xywh"][@"w"];
        [WindowInfoManager shareManager].frameHeight = dicArgs[@"xywh"][@"h"];
        
        BOOL isFrameExist = false;
        BaseWebView *frameWebView = nil;
        
        for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews.lastObject.subviews)
        {
            if ([baseWebView isMemberOfClass:[BaseWebView class]] && [baseWebView.frameName isEqualToString:dicArgs[@"frameName"]])
            {
                isFrameExist = true;
                frameWebView = baseWebView;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.appDelegate.baseViewController.view.subviews.lastObject bringSubviewToFront:frameWebView];
                });
                break;
            }
        }
        if (!isFrameExist)
        {
            NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicArgs[@"htmlUrl"] excuteWebView:weakwebView];
            
            if (weakwebView.frameGroupName)
            {
                frameWebView = [[BaseWebView alloc] initWithFrame:[weakwebView.paramObject configWebViewFrameWithDictionary:dicArgs[@"xywh"]] url:absoluteString isWindow:false];
            } else {
                frameWebView = [[BaseWebView alloc] initWithFrame:[weakwebView.paramObject configWebViewFrameWithDictionary:dicArgs[@"xywh"]]
                                                              url:absoluteString
                                                         isWindow:false];
            }
            frameWebView.frameName = dicArgs[@"frameName"];
            frameWebView.delegate = weakself.appDelegate.baseViewController;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 远程页面 添加progress
                if ([dicArgs[@"htmlUrl"] hasPrefix:@"http"])
                {
                    frameWebView.isRemoteWeb = true;
                    [ToolsFunction showCustomProgress];
                }
                
                [weakwebView addSubview:frameWebView];
                
                CGFloat offsetX = dicArgs[@"xywh"][@"x"] == nil ? 0 : [dicArgs[@"xywh"][@"x"] floatValue];
                CGFloat offsetY = dicArgs[@"xywh"][@"y"] == nil ? 0 : [dicArgs[@"xywh"][@"y"] floatValue];
                
                CGFloat offsetW = 0;
                CGFloat offsetH = 0;

                if (dicArgs[@"xywh"][@"w"] && [dicArgs[@"xywh"][@"w"] isKindOfClass:[NSString class]] && [dicArgs[@"xywh"][@"w"] isEqualToString:@"auto"])
                {
                    offsetW = ScreenWidth - offsetX;
                } else {
                    offsetW = [dicArgs[@"xywh"][@"w"] floatValue];
                }
                
                if (dicArgs[@"xywh"][@"h"] && [dicArgs[@"xywh"][@"h"] isKindOfClass:[NSString class]] && [dicArgs[@"xywh"][@"h"] isEqualToString:@"auto"])
                {
                    offsetH = ScreenHeight - offsetY;
                } else {
                    offsetH = [dicArgs[@"xywh"][@"h"] floatValue];
                }
                
                CGFloat marginLeft = dicArgs[@"xywh"][@"marginLeft"] == nil ? 0 : [dicArgs[@"xywh"][@"marginLeft"] floatValue];
                CGFloat marginTop = dicArgs[@"xywh"][@"marginTop"] == nil ? 0 : [dicArgs[@"xywh"][@"marginTop"] floatValue];
                CGFloat marginBottom = dicArgs[@"xywh"][@"marginBottom"] == nil ? 0 : [dicArgs[@"xywh"][@"marginBottom"] floatValue];
                CGFloat marginRight = dicArgs[@"xywh"][@"marginRight"] == nil ? 0 : [dicArgs[@"xywh"][@"marginRight"] floatValue];
                
                [frameWebView mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.top.equalTo(weakwebView).with.offset(marginTop + offsetY);
                    make.left.equalTo(weakwebView).with.offset(marginLeft + offsetX);
                    
                    if (offsetW != 0)
                    {
                        make.right.equalTo(weakwebView).with.offset(-(ScreenWidth - marginLeft - marginRight - offsetX - offsetW));
                    } else {
                        make.right.equalTo(weakwebView).with.offset(-marginRight);
                    }
                    
                    if (offsetH != 0)
                    {
                        if ([[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
                        {
                            make.bottom.equalTo(weakwebView).with.offset(-(ScreenHeight - marginTop - marginBottom - offsetY - offsetH - AppStatusBarHeight));
                        } else {
                            make.bottom.equalTo(weakwebView).with.offset(-(ScreenHeight - marginTop - marginBottom - offsetY - offsetH));
                        }
                    } else {
                        make.bottom.equalTo(weakwebView).with.offset(-marginBottom);
                    }
                }];
                
                // 配置页面属性
                [weakself attrConfig:frameWebView JSparam:dicArgs];

                    // 判断父 是否为drawerWin
                    if (!((BaseWebView *)frameWebView.superview).isDrawerWin && ((BaseWebView *)frameWebView.superview).isSlipCloseWin == YES) {
                        frameWebView.isSlipCloseWin = YES;
                    }
            });
        }
    };
}

/**
 *  关闭frame
 *
 *  @param webView
 */
- (void)closeFrameWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfframeClose"] = ^() {
        [ToolsFunction hideCustomProgress];
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        if (!dicArgs[@"frameName"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self deallocModule:weakwebView window:weakself];// 移除webView上所有的模块对象
                [weakwebView removeFromSuperview];
            });
        } else {
            for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews.lastObject.subviews)
            {
                if ([baseWebView isMemberOfClass:[BaseWebView class]] && [baseWebView.frameName isEqualToString:dicArgs[@"frameName"]])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [baseWebView removeFromSuperview];
                    });
                }
            }
        }
    };
}

/**
 *  激活frame
 *
 *  @param webView
 */
- (void)activeFrameWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
//    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfframeActive"] = ^() {
        
        /*
         {
         from = newFrameAct1;
         }
         */
        
        // FIXME: 处理 to 字段 对应逻辑
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews.lastObject.subviews)
        {
            if ([baseWebView isMemberOfClass:[BaseWebView class]] && [baseWebView.frameName isEqualToString:dicArgs[@"from"]])
            {
                CGRect tempFrame = baseWebView.frame;
                tempFrame.origin.y = ScreenHeight;
                baseWebView.frame = tempFrame;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.appDelegate.baseViewController.view.subviews.lastObject bringSubviewToFront:baseWebView];
                });
                
                [UIView animateWithDuration:WebViewAnimationTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    CGRect tempFrame = baseWebView.frame;
                    tempFrame.origin.y = AppFrameWebViewTop;
                    baseWebView.frame = tempFrame;
                } completion:^(BOOL finished) {
                    
                }];
                
                break;
            }
        }
    };
}

/**
 *  隐藏frame
 *
 *  @param webView
 */
- (void)disActiveFrameWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
//    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfframeDisactive"] = ^()
    {
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews.lastObject.subviews)
        {
            if ([baseWebView isMemberOfClass:[BaseWebView class]] && [baseWebView.frameName isEqualToString:dicArgs[@"from"]])
            {
                [UIView animateWithDuration:WebViewAnimationTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    CGRect tempFrame = baseWebView.frame;
                    tempFrame.origin.x = ScreenWidth;
                    baseWebView.frame = tempFrame;
                } completion:^(BOOL finished) {
                    [weakself.appDelegate.baseViewController.view.subviews.lastObject sendSubviewToBack:baseWebView];
                }];
                
                break;
            }
        }
    };
}

/**
 *  设置frame属性
 *
 *  @param webView
 */
- (void)setFrameAttributeWithWebView:(UIWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfFrameSetAttr"] = ^() {
        
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        if (dicArgs[@"frameName"] == nil){
        
            [weakself attrConfig:(BaseWebView *)[[weakself.appDelegate.baseViewController.view.subviews lastObject].subviews lastObject] JSparam:dicArgs];
        }
        
        for (BaseWebView *targetFrameWebView in weakself.appDelegate.baseViewController.view.subviews.lastObject.subviews)
        {
            if ([targetFrameWebView isMemberOfClass:[BaseWebView class]] && [targetFrameWebView.frameName isEqualToString:dicArgs[@"frameName"]]) {
                //通过名字拿到指定的FrameWebView对象再进行属性修改
                [weakself attrConfig:targetFrameWebView JSparam:dicArgs];
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Frame  配置
            [weakself setFrame:(BaseWebView *)weakwebView dicArgs:dicArgs];
        });
    };
}

#pragma mark - Custom Method


/**
 移除webView上所有的模块对象
 
 @param weakwebView 要关闭的  win
 @param weakself    weakself
 */
- (void)deallocModule:(BaseWebView*)weakwebView window:(FrameManager *)weakself{
    
        //找到子的 Frame ：注意这里win的子视图还有可能是frameGroup的情况
       for (int moduleIndex = 0; moduleIndex < weakwebView.moduleName_InWebView_Array.count; moduleIndex ++){
                id moduleObject =  weakwebView.moduleName_InWebView_Array[moduleIndex];
                //获取指定对象的属性列表
                NSMutableArray * moduleProperitsArr = [ToolsFunction getAllProperties: moduleObject];
                
                for (int properitsIndex = 0; properitsIndex < moduleProperitsArr.count; properitsIndex ++){
                    
                    const char * filePathChar = [moduleProperitsArr[properitsIndex] UTF8String];
                    Ivar ivar = class_getInstanceVariable([moduleObject class], filePathChar);
                    // 将属性逐个赋空 释放
                    object_setIvar(moduleObject, ivar, nil);
                }
            }
}


/**
 *  新建的webView 属性配置
 *
 *  @param frameWebView 当前frameWebView
 *  @param dicArgs      js 传递的数据
 */
- (void)attrConfig:(BaseWebView *)frameWebView JSparam:(NSDictionary *)dicArgs{

    RCWeakSelf(self);
    RCWeakSelf(frameWebView);
    // 配置页面弹动
    if (dicArgs[@"isBounces"])
    {
        frameWebView.scrollView.bounces = [[YTFConfigManager shareConfigManager] configFrameBounceWithJSParam:dicArgs[@"isBounces"]];
    }

    // backgroud 配置
    if (dicArgs[@"background"])
    {
        frameWebView.backgroundColor = [ToolsFunction hexStringToColor:[[YTFConfigManager shareConfigManager] configFrameBackgroundColorWithJSParam:dicArgs[@"background"]]];
    }
    
    // isEdit 配置
    if (dicArgs[@"isEdit"]){
       weakframeWebView.isEdit = [dicArgs[@"isEdit"] boolValue];//禁止长按编辑
    }
    
    // isHScrollBar 是否显示水平滚动条  配置
    if (dicArgs[@"isHScrollBar"])
    {
        [weakself hideisHScrollBar:frameWebView boolValue:[[YTFConfigManager shareConfigManager] configHorizonScrollBarWithJSParam:dicArgs[@"isHScrollBar"]]];
    }
    
    // isVScrollBar 是否显示垂直滚动条  配置
    if (dicArgs[@"isVScrollBar"])
    {
        [weakself hideisVScrollBar:frameWebView boolValue:[[YTFConfigManager shareConfigManager] configVeticalScrollBarWithJSParam:dicArgs[@"isVScrollBar"]]];
    }
    
    // isScale 页面是否缩放 配置
    if (dicArgs[@"isScale"])
    {
        frameWebView.scalesPageToFit = [[YTFConfigManager shareConfigManager] configWebViewScaleWithJSParam:dicArgs[@"isScale"]];
    }
    
    // isReload  页面已经打开时，是否重新加载页面
    if (dicArgs[@"isReload"] && [[YTFConfigManager shareConfigManager] configisReloadWithJSParam:dicArgs[@"isReload"]])
    {
        [frameWebView reload];
    }
    
    // isHidden
    if (dicArgs[@"ishidden"])
    {
        [frameWebView.superview sendSubviewToBack:frameWebView];
    } else {
        [frameWebView.superview bringSubviewToFront:frameWebView];
    }
    
    // softInputMode
    if (dicArgs[@"softInputMode"])
    {
        [YTFConfigManager shareConfigManager].softKeyboardMode = dicArgs[@"softInputMode"];
    }
    
    // 滑动手势 配置
    BaseWebView *fatherWeb = (BaseWebView *)frameWebView.superview;
    if (fatherWeb.drawerWinName)
    {
        frameWebView.isSideWinPanGuester = YES;
        frameWebView.leftEdge = fatherWeb.leftEdge;
        frameWebView.leftZone = fatherWeb.leftZone;
        frameWebView.leftScale = fatherWeb.leftScale;
    }
}

/**
 *  隐藏水平滑动条
 *
 *  @param frameWebView 指定的WebView
 */
- (void)hideisHScrollBar:(BaseWebView *)frameWebView boolValue:(BOOL)ytBool
{
    frameWebView.scrollView.showsHorizontalScrollIndicator = ytBool;
}

/**
 *  隐藏垂直滑动条
 *
 *  @param frameWebView 指定的WebView
 */
- (void)hideisVScrollBar:(BaseWebView *)frameWebView boolValue:(BOOL)ytBool
{
    frameWebView.scrollView.showsVerticalScrollIndicator = ytBool;
}
/**
 *  配置webView的 Frame 属性
 *
 *  @param frameWebView 要配置  frame 属性的  webView
 *  @param dicArgs      JS 传入的数据
 */
- (void)setFrame:(BaseWebView *)frameWebView dicArgs:(NSDictionary *)dicArgs
{
    CGFloat offsetX = dicArgs[@"xywh"][@"x"] == nil ? 0 : [dicArgs[@"xywh"][@"x"] floatValue];
    CGFloat offsetY = dicArgs[@"xywh"][@"y"] == nil ? 0 : [dicArgs[@"xywh"][@"y"] floatValue];
    
    CGFloat offsetW = 0;
    CGFloat offsetH = 0;
    
    if (dicArgs[@"xywh"][@"w"] && [dicArgs[@"xywh"][@"w"] isKindOfClass:[NSString class]] && [dicArgs[@"xywh"][@"w"] isEqualToString:@"auto"])
    {
        offsetW = ScreenWidth - offsetX;
    } else {
        offsetW = [dicArgs[@"xywh"][@"w"] floatValue];
    }
    
    if (dicArgs[@"xywh"][@"h"] && [dicArgs[@"xywh"][@"h"] isKindOfClass:[NSString class]] && [dicArgs[@"xywh"][@"h"] isEqualToString:@"auto"])
    {
        offsetH = ScreenHeight - offsetY;
    } else {
        offsetH = [dicArgs[@"xywh"][@"h"] floatValue];
    }
    
    CGFloat marginLeft = dicArgs[@"xywh"][@"marginLeft"] == nil ? 0 : [dicArgs[@"xywh"][@"marginLeft"] floatValue];
    CGFloat marginTop = dicArgs[@"xywh"][@"marginTop"] == nil ? 0 : [dicArgs[@"xywh"][@"marginTop"] floatValue];
    CGFloat marginBottom = dicArgs[@"xywh"][@"marginBottom"] == nil ? 0 : [dicArgs[@"xywh"][@"marginBottom"] floatValue];
    CGFloat marginRight = dicArgs[@"xywh"][@"marginRight"] == nil ? 0 : [dicArgs[@"xywh"][@"marginRight"] floatValue];
    
    [frameWebView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(frameWebView.superview).with.offset(marginTop + offsetY);
        make.left.equalTo(frameWebView.superview).with.offset(marginLeft + offsetX);
        
        if (offsetW != 0)
        {
            make.right.equalTo(frameWebView.superview).with.offset(-(ScreenWidth - marginLeft - marginRight - offsetX - offsetW));
        } else {
            make.right.equalTo(frameWebView.superview).with.offset(-marginRight);
        }
        
        if (offsetH != 0)
        {
            make.bottom.equalTo(frameWebView.superview).with.offset(-(ScreenHeight - marginTop - marginBottom - offsetY - offsetH));
        } else {
            make.bottom.equalTo(frameWebView.superview).with.offset(-marginBottom);
        }
    }];
}

@end
