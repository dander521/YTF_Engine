/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic userinterface manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "MJRefresh.h"
#import "BaseWebView.h"

@interface UIControlManager : NSObject



#pragma mark - Refresh

/**
 *  上拉加载
 *
 *  @param webView JSContext
 */
- (void)setPullUpRefreshWithWebView:(BaseWebView *)webView;

/**
 *  设置上拉加载组建为刷新状态
 *
 *  @param webView JSContext
 */
- (void)pullUpRefreshLoadingWithWebView:(BaseWebView *)webView;

/**
 *  通知上拉加载数据加载完毕，回复到默认状态，下拉刷新结束
 *
 *  @param webView JSContext
 */
- (void)pullUpRefreshDoneWithWebView:(BaseWebView *)webView;

/**
 *  下拉刷新
 *
 *  @param webView JSContext
 */
- (void)setPullRefreshWithWebView:(BaseWebView *)webView;

/**
 *  设置下拉刷新组建为刷新状态
 *
 *  @param webView JSContext
 */
- (void)pullRefreshLoadingWithWebView:(BaseWebView *)webView;

/**
 *  通知下拉刷新数据加载完毕，回复到默认状态，下拉刷新结束
 *
 *  @param webView JSContext
 */
- (void)pullRefreshDoneWithWebView:(BaseWebView *)webView;

#pragma mark - Alert

/**
 *  弹出框
 *
 *  @param webView JSContext
 */
- (void)alertWithWebView:(BaseWebView *)webView;

/**
 *  弹出带两个或者三个按钮的confirm对话框
 *
 *  @param webView JSContext
 */
- (void)confirmWithWebView:(BaseWebView *)webView;

/**
 *  弹出带两个或三个按钮和输入框的对话框
 *
 *  @param webView JSContext
 */
- (void)promptWithWebView:(BaseWebView *)webView;

#pragma mark - Gif

/**
 *  显示进度提示框
 *
 *  @param webView JSContext
 */
- (void)showProgressWithWebView:(BaseWebView *)webView;

/**
 *  隐藏进度提示框
 *
 *  @param webView JSContext
 */
- (void)hideProgressWithWebView:(BaseWebView *)webView;

/**
 *  显示进度提示框
 *
 *  @param webView JSContext
 */
- (void)showCustomProgressWithWebView:(BaseWebView *)webView;

/**
 *  隐藏进度提示框
 *
 *  @param webView JSContext
 */
- (void)hideCustomProgressWithWebView:(BaseWebView *)webView;

#pragma mark - Toast

/**
 *  自动关闭的提示框toast
 *
 *  @param webView JSContext
 */
- (void)toastWithWebView:(BaseWebView *)webView;

#pragma mark - PopView

/**
 *  显示pop弹窗
 *
 *  @param webView JSContext
 */
- (void)popViewWithWebView:(BaseWebView *)webView;

/**
 *  隐藏pop弹窗
 *
 *  @param webView JSContext
 */
- (void)hidePopViewWithWebView:(BaseWebView *)webView;

/**
 添加3DTouch监听
 
 @param paramDictionary JS 参数
 */
- (void)config3DTouchListener:(BaseWebView *)webView;


/**
 设置3DTouch菜单
 
 @param paramDictionary JS 参数
 */
- (void)config3DTouchMenu:(BaseWebView *)webView;

@end
