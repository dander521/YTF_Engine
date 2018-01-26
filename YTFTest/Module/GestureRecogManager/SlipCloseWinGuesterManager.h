//
//  SlipCloseWinGuesterManager.h
//  YTFTest
//
//  Created by Evyn on 16/12/1.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseWebView.h"
@interface SlipCloseWinGuesterManager : NSObject


/**
 单例初始化对象
 
 @return self
 */
+ (instancetype)shareInstance;


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
                      isModuleView:(BOOL)isModuleView;
@end
