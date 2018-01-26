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

#import "PanGeusterDelegateClass.h"
#import "BaseViewController.h"
#import "AppDelegate.h"
#import "Definition.h"
#import "FrameGroupManager.h"
#import "InteractiveManager.h"
#import "YTFAnimationManager.h"
#import "ToolsFunction.h"
#import "YTFConfigManager.h"
#import "MaskingView.h"

#define leftViewWidth       [UIScreen mainScreen].bounds.size.width/3+100
#define DrawerDragZone      ([leftZone floatValue])*([UIScreen mainScreen].bounds.size.width)
#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
#define removeWindowDetel   120

@interface PanGeusterDelegateClass ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) MaskingView *maskingView;//蒙板view
@property (nonatomic, weak) BaseWebView  *baseWebView;
@property (nonatomic, weak) BaseWebView  *sideWeb;

@end

@implementation PanGeusterDelegateClass
{

    NSInteger currentX;
    
    CGFloat  delta;//拖拽的距离
}

/**
 *  单例创建对象
 *
 *  @return self
 */

+ (instancetype)shareInshance{
    
   static  PanGeusterDelegateClass * panObj = nil;
   static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        panObj = [[self alloc]init];
    });
    return panObj;
}




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
                  leftScale:(NSNumber *)leftScale{
    
    self.baseWebView = baseWebView;
    self.sideWeb     = sideWeb;
     CGPoint location = [pan locationInView:self.baseWebView];
     CGPoint dicectPoint = [pan translationInView:pan.view];//用于判断滑动方向
     UIScrollView * groupScroll;
    
    for (UIView * scroll in self.baseWebView.subviews) {
        if ([scroll isKindOfClass:[UIScrollView class]]) {
            groupScroll = (UIScrollView *)scroll;
        }
    }
    if (pan.state == UIGestureRecognizerStateBegan) {// 如果刚开始拖拽
        currentX = location.x; // 拿到当前的位置
    }
    if (pan.state == UIGestureRecognizerStateChanged) { // 如果拖拽进行中
        delta = location.x - currentX;  // 拿到拖拽的距离
        if (currentX>DrawerDragZone) {
            groupScroll.scrollEnabled = YES;
            return;
        }else if (currentX<=DrawerDragZone){
            
            groupScroll.scrollEnabled = NO;
            
            // 因为transform是相对最开始位置的，所有这里 要区分两种拖拽的可能
            // 向右边滑动
            if ( delta < leftViewWidth && delta > 0) {
            //sideWin 打开后  禁止响应向右边滑动
                if (!self.sideWeb.isDrawerOpen) {
                    if (dicectPoint.x>0){
                        return;
                    }else if (dicectPoint.x>0){
                        if (self.sideWeb.isDrawerOpen) {
                            return;
                    }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIView animateWithDuration:0.15 animations:^{
                                self.baseWebView.transform = CGAffineTransformMakeTranslation(delta, 0);
                                self.sideWeb.transform = CGAffineTransformMakeTranslation(delta, 0);
                            }];
                        });
                    }
                }
            }
            else if(delta < 0 && leftViewWidth+delta >= 0){ // transform是相对最开始的中心的位置，当
                if (dicectPoint.x>0 && !self.sideWeb.isDrawerOpen){
                    return;//sideWin 打开后  禁止响应向右边滑动
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UIView animateWithDuration:0.15 animations:^{
                        self.baseWebView.transform = CGAffineTransformMakeTranslation(leftViewWidth + delta, 0);
                        self.sideWeb.transform = CGAffineTransformMakeTranslation(leftViewWidth + delta, 0);
                    }];
                });
            }
            groupScroll.scrollEnabled = YES;
        }
    }
    if (pan.state == UIGestureRecognizerStateEnded) { // 如果拖拽停止了
        
        if (currentX>DrawerDragZone) {
            groupScroll.scrollEnabled = YES;
            
            return;
        }else if (currentX<=DrawerDragZone){
            
            groupScroll.scrollEnabled = NO;
            
            if(delta > 30 ){
                [self showGroupLeftView:self.baseWebView sideWebView:self.sideWeb leftEdge:leftEdge];
            }else{
                [self hideGroupLeftView:self.baseWebView sideWebView:self.sideWeb ];
            }
            
        }
    }
    
    groupScroll.scrollEnabled = YES;
}

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
                  leftScale:(NSNumber *)leftScale{
    
        CGPoint location = [pan locationInView:self.currentVC.view];
        CGPoint dicectPoint = [pan translationInView:pan.view];//用于判断滑动方向
        if (pan.state == UIGestureRecognizerStateBegan) {// 如果刚开始拖拽
            dispatch_async(dispatch_get_main_queue(), ^{
             [baseWebView addSubview:[MaskingView shareInstanceMaskingView]];
         
            });            
            currentX = location.x; // 拿到当前的位置
        }
        if (pan.state == UIGestureRecognizerStateChanged) { // 如果拖拽进行中
            delta = location.x - currentX;  // 拿到拖拽的距离
            // 因为transform是相对最开始位置的，所有这里 要区分两种拖拽的可能
            if ( delta < leftViewWidth && delta > 0) {
                if (!sideWeb.isDrawerOpen) {
                    if (dicectPoint.x<0){
                        return;
                        //sideWin 打开后  禁止响应向右边滑动
                    }else if (dicectPoint.x>0){
                        if (sideWeb.isDrawerOpen) {
                            return;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIView animateWithDuration:0.15 animations:^{
                                baseWebView.transform = CGAffineTransformMakeTranslation(delta, 0);
                                sideWeb.transform = CGAffineTransformMakeTranslation(delta, 0);
                                self.maskingView = [MaskingView shareInstanceMaskingView];
                                self.maskingView.hidden = NO;
                                self.maskingView.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:(baseWebView.transform.tx/250)];
                            }];
                        });
                        
                    }
                }
            }else if(delta < -20 && leftViewWidth+delta >= 0){ // transform是相对最开始的中心的位置，当
                
                if (dicectPoint.x<0 && !sideWeb.isDrawerOpen){
                    
                    return;
                    //sideWin 打开后  禁止响应向右边滑动
                }
                

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                [UIView animateWithDuration:0.15 animations:^{
                        baseWebView.transform = CGAffineTransformMakeTranslation(leftViewWidth + delta, 0);
                        self.maskingView = [MaskingView shareInstanceMaskingView];
                        self.maskingView.hidden = NO;
                        self.maskingView.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:(baseWebView.transform.tx/250)];
                }];
            });
            }
        }
        if (pan.state == UIGestureRecognizerStateEnded) { // 如果拖拽停止了
 
            //手势相对于屏幕currentVC.view的坐标
            if(delta > 30 ){
                if (sideWeb.isDrawerOpen) {
                    return;
                }
                [self showLeftView:baseWebView sideWebView:sideWeb leftEdge:leftEdge];
               //找到这个 sideWebView  并设置其属性 isDrawerOpen
                for (BaseWebView * baseWeb in self.sideWebViewArray) {
                    baseWeb.isDrawerOpen = YES;
                }
            }else{
                [self hideLeftView:baseWebView sideWebView:sideWeb];
                for (BaseWebView * baseWeb in self.sideWebViewArray) {
                    baseWeb.isDrawerOpen = NO;
            }
        }
    }
}


#pragma mark - frame Drawer
/**
 frame侧滑显示 Drawer
 
 @param baseWebView 手势作用视图
 @param sideWebView 要显示的视图
 @param leftEdge
 */

- (void)showLeftView:(BaseWebView *)baseWebView
         sideWebView:(BaseWebView *)sideWebView
            leftEdge:(NSNumber *)leftEdge{
    

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 animations:^{
            baseWebView.transform = CGAffineTransformMakeTranslation(ScreenWidth*[leftEdge doubleValue], 0);
            sideWebView.transform = CGAffineTransformMakeTranslation(ScreenWidth*[leftEdge doubleValue], 0);
            baseWebView.isDrawerOpen = YES;
            sideWebView.isDrawerOpen = YES;

            //  创建蒙板
            dispatch_async(dispatch_get_main_queue(), ^{
                self.maskingView =  [MaskingView shareInstanceMaskingView];
                [MaskingView showMaskView:self.maskingView baseWebView:baseWebView sideweb:sideWebView];
            });

        }];
    });
    
    [[InteractiveManager shareManager] JSExcuteJS:sideWebView];
    

}
/**
frame侧滑隐藏 Drawer 
 @param baseWebView 手势作用视图
 @param sideWebView 要显示的视图
 */
- (void)hideLeftView:(BaseWebView *)baseWebView sideWebView:(BaseWebView *)sideWebView{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 animations:^{
            baseWebView.transform = CGAffineTransformIdentity;
            sideWebView.transform = CGAffineTransformIdentity;
            baseWebView.isDrawerOpen = NO;
            sideWebView.isDrawerOpen = NO;

            [MaskingView shareInstanceMaskingView].hidden = YES;
            
        }];
    });
    
}


#pragma mark - group Drawer
/**
 group侧滑显示 Drawer

 @param baseWebView 手势作用视图
 @param sideWebView 要显示的视图
 @param leftEdge
 */
- (void)showGroupLeftView:(BaseWebView *)baseWebView
              sideWebView:(BaseWebView *)sideWebView
                 leftEdge:(NSNumber *)leftEdge{

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 animations:^{
            
            baseWebView.transform = CGAffineTransformMakeTranslation(ScreenWidth*[leftEdge doubleValue], 0);
            sideWebView.transform = CGAffineTransformMakeTranslation(ScreenWidth*[leftEdge doubleValue], 0);
            baseWebView.isDrawerOpen = YES;
         
            //  创建蒙板
            dispatch_async(dispatch_get_main_queue(), ^{
                self.maskingView =  [MaskingView shareInstanceMaskingView];
                [MaskingView showMaskView:self.maskingView baseWebView:baseWebView sideweb:sideWebView];
           });

        }];
    });
}
/**
 group侧滑隐藏 Drawer
 
 @param baseWebView 手势作用视图
 @param sideWebView 要显示的视图
 */
- (void)hideGroupLeftView:(BaseWebView *)baseWebView sideWebView:(BaseWebView *)sideWebView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 animations:^{
            baseWebView.transform = CGAffineTransformIdentity;
            sideWebView.transform = CGAffineTransformIdentity;
            baseWebView.isDrawerOpen = NO;
            
            [UIView animateWithDuration:0.18 animations:^{
                [MaskingView shareInstanceMaskingView].alpha = 0.20;
            } completion:^(BOOL finished) {
                [MaskingView shareInstanceMaskingView].hidden = YES;
            }];
           
        }];
    });
}



#pragma mark --Coustum Method
/**
 获取现在所有的 side web
 */
- (void)getSideWebView{
    if (!self.sideWebViewArray) {
        self.sideWebViewArray = [NSMutableArray array];
    }
    
    for (BaseWebView *baseWebView in [AppDelegate shareAppDelegate].baseViewController.view.subviews){
    if ([baseWebView isMemberOfClass:[BaseWebView class]] && baseWebView.drawerWinName.length!=0) {
              [self.sideWebViewArray addObject:baseWebView];
         }
    }
    
}


#pragma mark -- Coustum Method
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
