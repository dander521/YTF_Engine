/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFramework framegroup operation file.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

@class BaseWebView;

@interface FrameGroupManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *frameGroupScrollViewDictionary;// 将frameGroup放在 scrollview
@property (nonatomic, strong) NSMutableArray *frameGroupNamesArray; // 当前framegroups名
@property (nonatomic, strong) NSMutableArray *frameGroupCbIdsArray; // 当前framegroups名
@property (nonatomic, strong) NSMutableArray *frameGroupConfigsArray; // 当前framegroup配置字典
@property (nonatomic, strong) NSMutableDictionary *htmlParamDictionary;// webview <-> htmlParam
@property (nonatomic, strong) NSMutableDictionary *reuseDictionary;
@property (nonatomic, strong) NSMutableDictionary *preloadDictionary;
@property(nonatomic, strong) NSMutableArray *closeWinFrameArray; // 将创建的frame都装起来 循环遍历为每一个frame添加侧滑关闭窗口的属性
@property(nonatomic,strong) NSMutableArray *originXFrameArray; //  记住第一次加载程序时  group中每一个frame 的origin.x位置


// 单例
+ (instancetype)shareManager;

/**
 *  打开framegroup
 *
 *  @param webView
 */
- (void)openFrameGroupWithWebView:(BaseWebView *)webView;

/**
 *  关闭framegroup
 *
 *  @param webView
 */
- (void)closeFrameGroupWithWebView:(BaseWebView *)webView;

/**
 *  设置framegroup index
 *
 *  @param webView
 */
- (void)setFrameGroupIndexWithWebView:(BaseWebView *)webView;

/**
 *  设置framegroup属性
 *
 *  @param webView
 */
- (void)setFrameGroupAttributeWithWebView:(BaseWebView *)webView;

@end
