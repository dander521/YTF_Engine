//
//  SlipCloseWinGuesterManager.m
//  YTFTest
//
//  Created by Evyn on 16/12/1.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "SlipCloseWinGuesterManager.h"
#import "ToolsFunction.h"
#import "FrameGroupManager.h"
#import "Definition.h"

#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
#define leftViewWidth       [UIScreen mainScreen].bounds.size.width/3+100
#define removeWindowDetel    120


@interface SlipCloseWinGuesterManager ()
{
    NSInteger currentX;
    CGFloat  delta;//拖拽的距离

}
@end
@implementation SlipCloseWinGuesterManager




/**
 单例初始化对象
 
 @return self
 */
+ (instancetype)shareInstance{
    
    static SlipCloseWinGuesterManager * slipClosMang = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        slipClosMang = [[self alloc] init];
    });
    
    return slipClosMang;
}


/**
 侧滑关闭窗口
 
 @param targetWebView frameWebView
 @param isWinWebView 手指是否作用在 win 上
 @param closePan 手势对象
 @param isModuleView 作用在web上还是作用在插件自定义的view上
 */
- (void)sideSlipCloseWinPanGuester:(UIView *)targetWebView
                      isWinWebView:(BOOL )isWinWebView
                      closeGuester:(UIPanGestureRecognizer *)closePan
                      isModuleView:(BOOL)isModuleView{
    
    
    BaseWebView * closeWinWeb;
    if (!isWinWebView) {
        closeWinWeb = [self getTargetCloseWebView:targetWebView];
    }else{
        closeWinWeb = (BaseWebView *)targetWebView;
    }
    // 获取当前 win 的上一层 win
    BaseWebView * subBaseWebView = [ToolsFunction getSubBaseWebView:closeWinWeb];
    
    CGPoint location = [closePan locationInView:[ToolsFunction getCurrentVC].view];
    CGPoint dicectPoint = [closePan translationInView:closePan.view];//用于判断滑动方向
    if (closePan.state == UIGestureRecognizerStateBegan) {// 如果刚开始拖拽
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:closeWinWeb.bounds];
            closeWinWeb.layer.masksToBounds = NO;
            closeWinWeb.layer.shadowColor = [UIColor blackColor].CGColor;
            closeWinWeb.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
            closeWinWeb.layer.shadowOpacity = 0.5f;
            closeWinWeb.layer.shadowPath = shadowPath.CGPath;
        });
        currentX = location.x; // 拿到当前的位置
        
        if (currentX > ScreenWidth/3) {
            return;
        }
    }
    
    if (closePan.state == UIGestureRecognizerStateChanged) { // 如果拖拽进行中

        if (currentX > ScreenWidth/3) {
            return;
        }
        delta = location.x - currentX;  // 拿到拖拽的距离
        // 因为transform是相对最开始位置的，所有这里 要区分两种拖拽的可能
        if ( delta < leftViewWidth && delta > 0) {
            if (dicectPoint.x<0){
                return;
                //sideWin 打开后  禁止响应向右边滑动
            }else if (dicectPoint.x>0){
                
                [UIView animateWithDuration:0.15 animations:^{
                    
                    
                        closeWinWeb.frame = CGRectMake(delta,
                                                       closeWinWeb.frame.origin.y,
                                                       closeWinWeb.frame.size.width,
                                                       closeWinWeb.frame.size.height);
                        
                        subBaseWebView.frame = CGRectMake(delta -ScreenWidth,
                                                          closeWinWeb.frame.origin.y,
                                                          closeWinWeb.frame.size.width,
                                                          closeWinWeb.frame.size.height);
               
                }];
            }
        }
        
        else if(delta < 0 && leftViewWidth+delta >= 0){ // transform是相对最开始的中心的位置，当

            if (dicectPoint.x<0){
                return;
                //sideWin 打开后  禁止响应向右边滑动
            }
            [UIView animateWithDuration:0.15 animations:^{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    closeWinWeb.frame = CGRectMake(leftViewWidth + delta,
                                                   closeWinWeb.frame.origin.y,
                                                   closeWinWeb.frame.size.width,
                                                   closeWinWeb.frame.size.height);
                    
                    subBaseWebView.frame = CGRectMake(leftViewWidth + delta -ScreenWidth,
                                                      closeWinWeb.frame.origin.y,
                                                      closeWinWeb.frame.size.width,
                                                      closeWinWeb.frame.size.height);
                });
                
            }];
        }  else if(delta > leftViewWidth && delta > 0){
        
            [UIView animateWithDuration:0.15 animations:^{
                
                
                closeWinWeb.frame = CGRectMake(delta,
                                               closeWinWeb.frame.origin.y,
                                               closeWinWeb.frame.size.width,
                                               closeWinWeb.frame.size.height);
                
                subBaseWebView.frame = CGRectMake(delta -ScreenWidth,
                                                  closeWinWeb.frame.origin.y,
                                                  closeWinWeb.frame.size.width,
                                                  closeWinWeb.frame.size.height);
                
            }];
        }
    }
    
    if (closePan.state == UIGestureRecognizerStateEnded) { // 如果拖拽停止了
        
        
        if (currentX > ScreenWidth/3) {
            return;
        }
        if(delta > removeWindowDetel ){
            //  remove
            if (isModuleView == NO) {
              
                if (((BaseWebView *)closeWinWeb).frameGroupName)
                {
                    [[FrameGroupManager shareManager].frameGroupScrollViewDictionary removeObjectForKey:((BaseWebView *)closeWinWeb).frameGroupName];
                    [[FrameGroupManager shareManager].frameGroupNamesArray removeLastObject];
                    [[FrameGroupManager shareManager].frameGroupConfigsArray removeLastObject];
                    [[FrameGroupManager shareManager].frameGroupCbIdsArray removeLastObject];
                }
            }                        
            [UIView animateWithDuration:0.25 animations:^{
                
                closeWinWeb.frame = CGRectMake(ScreenWidth,
                                               closeWinWeb.frame.origin.y,
                                               closeWinWeb.frame.size.width,
                                               closeWinWeb.frame.size.height);
                
                subBaseWebView.frame = CGRectMake(0,
                                                  closeWinWeb.frame.origin.y,
                                                  closeWinWeb.frame.size.width,
                                                  closeWinWeb.frame.size.height);
                
            } completion:^(BOOL finished) {
                RCWeakSelf(closeWinWeb);
                [ToolsFunction deallocModule:weakcloseWinWeb]; // 销毁掉 web上的所用到的所有模块插件
                [closeWinWeb removeFromSuperview];
            }];
            
        }else{
            // do not remove
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.15 animations:^{
                    
                    closeWinWeb.frame = CGRectMake(0,
                                                   closeWinWeb.frame.origin.y,
                                                   closeWinWeb.frame.size.width,
                                                   closeWinWeb.frame.size.height);
                    
                    subBaseWebView.frame = CGRectMake(-ScreenWidth,
                                                      closeWinWeb.frame.origin.y,
                                                      closeWinWeb.frame.size.width,
                                                      closeWinWeb.frame.size.height);
                    
                }];
            });
        }
    }
}



/**
 获取当前frame的 Win

 @param ytfView 传入的View  （当前手势的win只有一个frame时，ytfView则为frameWebView 如果当前这个win 是groupFrame，则ytfView为 win的子视图 scrollView）
 @return winWebView
 */
- (BaseWebView *)getTargetCloseWebView:(UIView *)ytfView{
    
    return (BaseWebView *)(ytfView.superview);
}


@end
