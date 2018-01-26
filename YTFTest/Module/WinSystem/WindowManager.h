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

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import "BaseWebView.h"


//typedef void(^isWinEditBlock)(BaseWebView *baseWebView,NSString *selectString);//配置是否可编辑需要在 didfinish里进行JS代码注入
@interface WindowManager : NSObject

//@property (nonatomic,weak) id moduleObject;//模块对象
// 单例
+ (instancetype)shareManager;

/**
 *  打开win
 *
 *  @param webView
 */
- (void)openWinWithWebView:(BaseWebView *)webView;

/**
 *  关闭win
 *
 *  @param webView
 */
- (void)closeWinWithWebView:(BaseWebView *)webView;

/**
 *  关闭到win
 *
 *  @param webView
 */
- (void)closeToWinWithWebView:(BaseWebView *)webView;

/**
 *  退出应用
 *
 *  @param webView 
 */
- (void)appCloseWithWebView:(BaseWebView *)webView;

@end

