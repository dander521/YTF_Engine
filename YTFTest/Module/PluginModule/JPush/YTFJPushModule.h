/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         LiWei<15002887901@163.com>
 *  @created        2016-9-7
 *  @description    YTFJPushModule Plugin.
 * =============================================================================
 */


#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "YTFModule.h"

@interface YTFJPushModule : YTFModule<UIApplicationDelegate>
{

    NSString *  startCbid;// 启动推送的CBID
    id jPushWebView;
    
    NSString * setListenerCbid;//setListener  方法的CBID
    
   
}
@property(nonatomic,assign) BOOL clearAllMsg;//是否清除所有通知


///**
// *  启动推送
// *
// *  @param args JS传入的参数
// */
//- (void)ytfStartJPush:(NSDictionary *)args;

/**
 *  设置消息监听
 *
 *  @param args JS传入的参数
 */
- (void)setListener:(NSDictionary *)args;

/**
 *  移除消息监听
 *
 *  @param args JS传入的参数
 */
- (void)removeListener:(NSDictionary *)args;

/**
 *  清除极光推送发送到状态栏的通知
 *
 *  @param args JS传入的参数
 */
- (void)removeMessage:(NSDictionary *)args;

/**
 *  停止推送
 *
 *  @param args JS传入的参数
 */
- (void)stopPush:(NSDictionary *)args;

/**
 *  重启推送
 *
 *  @param args JS传入的参数
 */
- (void)resumePush:(NSDictionary *)args;

/**
 *  判断当前APP是否允许推送
 *
 *  @param args JS传入的参数
 */
- (void)isPushStopped:(NSDictionary *)args;

/**
 *  获取一个唯一的该设备的标识RegistrationID
 *
 *  @param args JS传入的参数
 */
- (void)getRegistrationId:(NSDictionary *)args;


@end
