/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Application entry.
 * =============================================================================
 */

#import <UIKit/UIKit.h>


@class BaseViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BaseViewController *baseViewController;
@property (strong, nonatomic) UIWebView *excuteWebView;
@property (strong, nonatomic) NSMutableArray *globelWebArray;


#pragma mark - 代理单例

/**
 AppDelegate 单例

 @return 单例
 */
+ (AppDelegate *)shareAppDelegate;

/**
 实现UIApplicationDelegate方法来接收应用消息，例如推送

 @param handle 代理对象
 */
- (void)addAppDelegateHandle:(id <UIApplicationDelegate>)handle;

#pragma mark - 插件信息

/**
 获取插件的config配置信息

 @param name 插件名

 @return 插件的信息字典
 */
+ (NSDictionary *)getExtendWithPluginName:(NSString *)name;

#pragma mark - 目录路径

/**
 通过相对路径获取绝对路径

 @param relativePath 相对路径

 @return 绝对路径
 */
- (NSString *)getAbsolutePathWithRelativePath:(NSString *)relativePath;

/**
 获取widget目录

 @return widget目录
 */
- (NSString *)getWidgetPath;

/**
 获取fs目录

 @return fs目录
 */
- (NSString *)getFSPath;

@end

