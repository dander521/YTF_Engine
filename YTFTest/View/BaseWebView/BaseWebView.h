/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic webView.
 * =============================================================================
 */

#import <UIKit/UIKit.h>
#import "WebViewParamObject.h"

@class MessageNotificationManager;

@interface BaseWebView : UIWebView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isSlipCloseWin; // 是否侧滑关闭win
@property (nonatomic, assign) BOOL isLoad; // 是否已加载
@property (nonatomic, assign) BOOL isRemoteWeb; // 是否为远程页面
@property (nonatomic, assign) BOOL isDrawerWin; // 是否为抽屉win
@property (nonatomic, assign) BOOL isGroupFrame; // 是否为groupframe
@property (nonatomic, assign) BOOL isDrawerOpen; // 抽屉是否打开
@property (nonatomic, assign) BOOL isDrawerSide; // 抽屉侧边
@property (nonatomic, assign) BOOL isEdit; // 是否可编辑
@property (nonatomic, assign) BOOL isSideWinPanGuester; // 是否添加侧滑手势
@property (nonatomic, assign) NSUInteger groupFrameIndex; // framegroup 中 frame index
@property (nonatomic, assign) double scrollBottomHeight; // 滑动到底部位置

@property (nonatomic, strong) NSNumber *leftEdge; // 侧滑window停留时露出的宽度，默认0.6
@property (nonatomic, strong) NSNumber *leftZone; // 从左侧起始，滑动范围，默认0.3
@property (nonatomic, strong) NSNumber *leftScale;// 左侧滑时，侧滑window移动时能缩放的最小倍数，0-1.0，默认1.0，数字类型
@property (nonatomic, strong) NSString *drawerWinName; // 抽屉win的名字
@property (nonatomic, strong) NSString *winName; // win 名字
@property (nonatomic, strong) NSString *frameName; // frame 名字
@property (nonatomic, strong) NSString *frameHtmlParam; // frame 参数
@property (nonatomic, strong) NSString *frameGroupName; // frame group 名字
@property (nonatomic, strong) NSURL *webViewUrl; // 页面url 路径协议转换
@property (nonatomic, strong) UIView *gifView; // gif动画 view
@property (nonatomic, strong) UILabel *toastLabel; // toast 标签
@property (nonatomic, strong) MessageNotificationManager *messageNotificationManager;
@property (nonatomic, strong) WebViewParamObject *paramObject; // 参数对象
@property (nonatomic, strong) UIView *moduleCustomView; // 参数对象
@property (nonatomic, strong) NSMutableArray *moduleName_InWebView_Array;



@property (nonatomic, copy) NSString *touchCbId;

/**
 *  初始化webView
 *
 *  @param frame    frame
 *  @param url      url
 *  @param isWindow win
 *
 *  @return
 */
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url isWindow:(BOOL)isWindow;

/**
 *  设置抽屉webView名字
 *
 *  @param baseWebViewsArray 抽屉的webView
 *  @param drawerName        抽屉名
 */
+ (void)configDrawerBaseWebView:(NSArray <BaseWebView *>*)baseWebViewsArray drawerName:(NSString *)drawerName;

/**
 *  初始化 JS 执行环境
 */
- (void)configJavaScriptExcuteEnvironment;


@end



