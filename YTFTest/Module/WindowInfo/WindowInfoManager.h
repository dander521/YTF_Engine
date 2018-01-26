/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Window infomation manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import "YTFConfigManager.h"
#import "BaseWebView.h"

@interface WindowInfoManager : NSObject

@property (nonatomic, copy) NSString *windowHeight; // 窗口高度
@property (nonatomic, copy) NSString *windowWidth; // 窗口宽度
@property (nonatomic, copy) NSString *windowName; // 窗口名字
@property (nonatomic, copy) NSString *htmlParam; // 窗口参数
@property (nonatomic, copy) NSString *appId; // app id
@property (nonatomic, copy) NSString *appName; // app 名字
@property (nonatomic, copy) NSString *appVersion; // app 版本
@property (nonatomic, copy) NSString *frameHeight; // 子窗口高度
@property (nonatomic, copy) NSString *frameWidth; // 子窗口宽度
@property (nonatomic, copy) NSString *frameName; // 子窗口名字


// 单例
+ (instancetype)shareManager;

- (void)testDeallocMeth:(id)classMed;

/**
 *  注入js的设备信息
 *
 *  @return
 */
+ (NSArray *)windowInfoArray;

/**
 *  app id
 */
+ (NSString *)appId;

/**
 *  app 名字
 */
+ (NSString *)appName;

/**
 *  app 版本
 */
+ (NSString *)appVersion;

/**
 *  窗口高度
 *
 *  @return
 */
+ (NSString *)getWindowHeight;

/**
 *  窗口宽度
 *
 *  @return
 */
+ (NSString *)getWindowWidth;

/**
 *  窗口名字
 *
 *  @return
 */
+ (NSString *)getWindowName;

/**
 *  窗口参数
 *
 *  @return
 */
+ (NSString *)getHtmlParam;

/**
 *  子窗口高度
 *
 *  @return
 */
+ (NSString *)getFrameHeight;

/**
 *  子窗口宽度
 *
 *  @return
 */
+ (NSString *)getFrameWidth;

/**
 *  子窗口名字
 *
 *  @return
 */
+ (NSString *)getFrameName;


@end
