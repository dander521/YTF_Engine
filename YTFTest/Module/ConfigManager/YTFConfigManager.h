/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Config manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseWebView.h"

@interface YTFConfigManager : NSObject

@property (nonatomic, copy) NSString *appId; // 应用id
@property (nonatomic, copy) NSString *indexSrc; // 启动页路径

// preference
@property (nonatomic, copy) NSString *appBackgroundColor; // app背景颜色
@property (nonatomic, copy) NSString *windowBackgroundColor; // window背景颜色
@property (nonatomic, copy) NSString *frameBackgroundColor; // frame背景颜色
@property (nonatomic, copy) NSString *frameGroupBackgroundColor; // frameGroup背景颜色
@property (nonatomic, copy) NSString *statusBarAppearance; // 沉浸式效果
@property (nonatomic, copy) NSString *softKeyboardMode; // 键盘弹出方式

@property (nonatomic, copy) NSString *windowBounce; // window页面是否弹动
@property (nonatomic, copy) NSString *frameBounce; // frame页面是否弹动
@property (nonatomic, copy) NSString *webScale; // web页面是否缩放
@property (nonatomic, copy) NSString *horizonScrollBar; // 水平滚动条
@property (nonatomic, copy) NSString *veticalScrollBar; // 垂直滚动条
@property (nonatomic, copy) NSString *autoLaunch; // 启动页是否自动隐藏
@property (nonatomic, copy) NSString *fullScreen; // 全屏运行
@property (nonatomic, assign) BOOL isDebugMode; // 测试模式

@property (nonatomic, copy) NSNumber *leftZone; // 左边侧滑范围
@property (nonatomic, copy) NSNumber *leftEdge; // 左边sideWin显示的区域

@property (nonatomic, strong) NSDictionary *extendDictionary; // 第三方插件配置字典

#pragma mark - SingleTon

// 配置管理类
+ (instancetype)shareConfigManager;

- (void)setLoaderParam:(NSDictionary *)dicLoader;

#pragma mark - Basic Config

// 获取 appid
- (NSString *)configAppId;

// 获取 启动页路径
- (NSString *)configIndexSrc;

#pragma mark - Preference

// 设置 app背景颜色
- (NSString *)configAppBackgroundColorWithJSParam:(NSString *)appBG;

// 设置 window背景颜色
- (NSString *)configWindowBackgroundColorWithJSParam:(NSString *)winBG;

// 设置 frame背景颜色
- (NSString *)configFrameBackgroundColorWithJSParam:(NSString *)frameBG;

// 设置 frameGroup背景颜色
- (NSString *)configFrameGroupBackgroundColorWithJSParam:(NSString *)frameGroupBG;

// 设置 沉浸式效果
- (NSString *)configStatusBarAppearanceWithJSParam:(NSString *)statusBarAppearance;

// 设置 键盘弹出方式
- (NSString *)configSoftKeyboardModeWithJSParam:(NSString *)softKeyboardMode;

// 设置 window页面是否弹动
- (BOOL)configWindowBounceWithJSParam:(NSNumber *)winBounce;

// 设置 frame页面是否弹动
- (BOOL)configFrameBounceWithJSParam:(NSNumber *)frameBounce;

// 设置 WebView页面是否可以缩放
- (BOOL)configWebViewScaleWithJSParam:(NSNumber *)webScale;


// 设置 水平滚动条
- (BOOL)configHorizonScrollBarWithJSParam:(NSNumber *)hScrollBar;

// 设置 垂直滚动条
- (BOOL)configVeticalScrollBarWithJSParam:(NSNumber *)vScrollBar;

// 设置 启动页是否自动隐藏
- (BOOL)configAutoLaunchWithJSParam:(NSNumber *)autoLaunch;

// 设置 全屏运行
- (BOOL)configFullScreenWithJSParam:(NSNumber *)fullScreen;

// 设置 是否重新加载页面
- (BOOL)configisReloadWithJSParam:(NSNumber *)isReload;

// 设置 是否允许长按页面时弹出选择菜单
- (NSString *)configisEditWithJSParam:(NSNumber *)isEdit;

// 设置 frame 组是否能够左右滚动
- (BOOL)configisScrollWithJSParam:(NSNumber *)isScroll;

// 设置 frame 组是否可以循环滑动，滑动到最后返回第一个frame
- (BOOL)configisLoopWithJSParam:(NSNumber *)isLoop;

// 设置 是否支持多选，默认不支持多选
- (NSInteger)configisCheckboxWithJSParam:(NSNumber *)isCheckbox;

// 设置 是否支持裁剪，默认不支持。
- (BOOL)configPictureIsEdit:(BOOL)picIsEdit;

// 设置 侧滑的有效范围。默认0.3Width
- (NSNumber *)configLeftZone:(NSNumber *)leftZone;

// 设置 侧滑的有效范围。
- (NSNumber *)configLeftEdge:(NSNumber *)leftEdge;



@end
