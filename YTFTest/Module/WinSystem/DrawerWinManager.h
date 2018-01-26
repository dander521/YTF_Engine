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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "MaskingView.h"

@class BaseWebView;

@interface DrawerWinManager : NSObject

@property (nonatomic, strong) MaskingView *maskingView;

// 单例
+ (instancetype)shareManager;

/**
 *  生成DrawerWin
 *
 *  @param webView
 */
- (void)openDrawerWinWithWebView:(BaseWebView *)webView;

/**
 *  移除DrawerWin
 *
 *  @param webView
 */
- (void)closeDrawerWinWithWebView:(BaseWebView *)webView;

/**
 *  打开DrawerWin
 *
 *  @param webView
 */
- (void)openDrawerWithWebView:(BaseWebView *)webView;

/**
 *  关闭DrawerWin
 *
 *  @param webView
 */
- (void)closeDrawerWithWebView:(BaseWebView *)webView;

/**
 *  锁定DrawerWin
 *
 *  @param webView
 */
- (void)lockDrawerWinWithWebView:(BaseWebView *)webView;

/**
 *  解锁DrawerWin
 *
 *  @param webView
 */
- (void)unlockDrawerWinWithWebView:(BaseWebView *)webView;

@end
