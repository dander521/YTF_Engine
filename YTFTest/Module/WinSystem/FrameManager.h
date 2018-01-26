/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFramework frame operation file.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
@class BaseWebView;

//typedef void(^isFrameEditBlock)(BaseWebView *baseWebView,NSString* selectString);//配置是否可编辑需要在 didfinish里进行JS代码注入
@interface FrameManager : NSObject

//@property (nonatomic, copy) isFrameEditBlock isFrameEditblock;
@property (nonatomic, strong) UIView *gifView;
@property (nonatomic, strong) UIView *progView;


// 单例
+ (instancetype)shareManager;

/**
 *  打开frame
 *
 *  @param webView
 */
- (void)openFrameWithWebView:(BaseWebView *)webView;

/**
 *  关闭frame
 *
 *  @param webView
 */
- (void)closeFrameWithWebView:(BaseWebView *)webView;

/**
 *  激活frame
 *
 *  @param webView
 */
- (void)activeFrameWithWebView:(BaseWebView *)webView;

/**
 *  隐藏frame
 *
 *  @param webView
 */
- (void)disActiveFrameWithWebView:(BaseWebView *)webView;

/**
 *  设置frame属性
 *
 *  @param webView
 */
- (void)setFrameAttributeWithWebView:(BaseWebView *)webView;

@end
