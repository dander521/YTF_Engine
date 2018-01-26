/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link        http://www.ytframework.cn
 * =============================================================================
 *  @author     Tangqian<tanufo@126.com>
 *  @created    2015-10-10
 *  @description
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "BaseWebView.h"

@interface AppSingleton : NSObject

@property (nonatomic, strong) BaseWebView *touchWebView;

/**
 *  单例存储AppDelegate系统的代理
 */
@property (nonatomic, assign) AppDelegate *appDelegate;

/**
 *  初始化单例对象
 *
 *  @return 类的实例对象
 */
+ (instancetype)shareManager;//单例


@end
