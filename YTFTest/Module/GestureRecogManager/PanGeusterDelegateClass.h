/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic Geuster method.
 * =============================================================================
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class BaseWebView;
@interface PanGeusterDelegateClass : NSObject


@property (nonatomic, strong) NSMutableArray * sideWebViewArray;//两个sideWebView
@property (nonatomic, weak) UIViewController * currentVC;


+ (instancetype)shareInshance;

/**
 groupFrame 上是 DrawerWin ，手势打开Drawer

 @param baseWebView 手势所在的Frame
 @param sideWeb     sideWin
 @param pan         手势
 @param leftEdge
 @param leftZone
 @param leftScale
 */
- (void)groupSidePanGuester:(BaseWebView *)baseWebView
                     sideWin:(BaseWebView *)sideWeb
                     guester:(UIPanGestureRecognizer *)pan
                    leftEdge:(NSNumber *)leftEdge
                    leftZone:(NSNumber *)leftZone
                   leftScale:(NSNumber *)leftScale;


/**
 *  加在单个frame上的Pan手势
 *
 *  @param baseWebView side-main
 *  @param sideWeb     side-side
 *  @param pan         UIPanGestureRecognizer
 */
- (void)frameSidePanGuester:(BaseWebView *)baseWebView
                    sideWin:(BaseWebView *)sideWeb
                    guester:(UIPanGestureRecognizer *)pan
                   leftEdge:(NSNumber *)leftEdge
                   leftZone:(NSNumber *)leftZone
                  leftScale:(NSNumber *)leftScale;


/**
 获取现在所有的 side web
 */
- (void)getSideWebView;

/**
 frame侧滑隐藏 Drawer
 
 @param baseWebView 手势作用视图
 @param sideWebView 要显示的视图
 */
- (void)hideLeftView:(BaseWebView *)baseWebView sideWebView:(BaseWebView *)sideWebView;

@end
