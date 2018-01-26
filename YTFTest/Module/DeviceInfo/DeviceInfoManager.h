/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Device infomation manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseWebView.h"

@interface DeviceInfoManager : NSObject

@property (nonatomic, copy) NSString *systemType; // 设备系统类型
@property (nonatomic, copy) NSString *systemVersion; // 设备系统版本
@property (nonatomic, copy) NSString *deviceName; // 设备名
@property (nonatomic, copy) NSString *deviceId; // 设备id
@property (nonatomic, copy) NSString *deviceModel; // 设备型号
@property (nonatomic, copy) NSString *screenWidth; // 屏幕宽度
@property (nonatomic, copy) NSString *screenHeight; // 屏幕高度
@property (nonatomic, copy) NSString *operatorName; // 运营商名

// 单例
+ (instancetype)shareManager;

/**
 *  注入js的设备信息
 *
 *  @return
 */
+ (NSArray *)deviceInfoArray;

/**
 *  设备系统类型
 *
 *  @return
 */
+ (NSString *)appSystemType;

/**
 *  设备系统版本
 *
 *  @return
 */
+ (NSString *)appSystemVersion;

/**
 *  设备id
 *
 *  @return
 */
+ (NSString *)appDeviceId;

/**
 *  设备名称
 *
 *  @return
 */
+ (NSString *)appDeviceName;

/**
 *  设备型号
 *
 *  @return
 */
+ (NSString *)appDeviceModel;

/**
 *  屏幕宽度
 *
 *  @return
 */
+ (NSString *)appScreenWidth;

/**
 *  屏幕高度
 *
 *  @return
 */
+ (NSString *)appScreenHeight;


/**
 运营商名

 @return
 */
+ (NSString *)operatorName;

/**
 获取设备网络状态
 */
- (void)getNetStatus:(BaseWebView *)webView;

@end
