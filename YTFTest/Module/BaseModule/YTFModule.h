/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link        http://www.ytframework.cn
 * =============================================================================
 *  @author     Tangqian<tanufo@126.com>
 *  @created    2015-10-10
 *  @description 所有插件必须继承的父类
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define NotificationWhenModuleDealloc   @"NotificationWhenModuleDealloc"

@interface YTFModule : NSObject

@property (nonatomic, strong) UIViewController *viewController;

/**
 在指定窗口上面添加视图
 
 @param view 视图，
 
 @param fixedOn 目标窗口名字，默认为主窗口名字
 
 @param fixed 视图是否固定，为NO时跟随目标窗口内容滚动而滚动
 
 @return 添加视图是否成功，若fixedOn对应子窗口未找到则返回失败
 */
- (BOOL)addSubview:(UIView *)view
           fixedOn:(NSString *)fixedOn
             fixed:(BOOL)fixed;


/**
 执行回调方法返回数据
 
 @param bCbid 回调函数id
 
 @param dataDict 返回的数据
 
 @param errDict 错误信息
 
 @param doDelete 执行回调后是否删除回调函数对象
 */
- (void)sendCallBackDataWithCallbackBadge:(UIWebView *)currentWebView
                                     cbid:(NSString *)bCbid
                                 dataDict:(NSDictionary *)dataDict
                                  errDict:(NSDictionary *)errDict
                                 doDelete:(BOOL)doDelete;

/**
 获取指定窗口对象
 
 @param name 窗口名字
 
 @return 窗口对象
 */
- (UIView *)getWebViewByName:(NSString *)name;

@end


/**
 给系统的 UIView 类 添加一个属性：（只有通过类扩展来添加属性）
 */
@interface UIView ()

/**
 是否允许滑动返回
 */
@property (nonatomic,assign) BOOL slidBackEnabled;

/**
 是否允许滑动打开Drawer
 */
@property (nonatomic,assign) BOOL openDrawerEnabled;

@end
