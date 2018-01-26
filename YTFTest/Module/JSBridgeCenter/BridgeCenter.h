/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Plugin center.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


@class BaseWebView;
@interface BridgeCenter : NSObject

//@property (nonatomic, strong)id targetViewController;


/**
 单例

 @return self
 */
+ (instancetype)shareManager;

/**
 *  插件的调度中心  js 统一来调用这个方法 由此方法接收的参数来 进行相应 原生方法的调用
 *
 *  @param baseWebView 执行此方法的 webView
 */
- (void)ytfNativeBridget:(BaseWebView *)baseWebView;

/**
 *  最先响应插件的方法 require  用来只初始化一个对象
 *
 *  @param baseWebView 执行此方法的 webView
 */
- (void)ytfRequireNativeMethod:(BaseWebView *)baseWebView;

@end
