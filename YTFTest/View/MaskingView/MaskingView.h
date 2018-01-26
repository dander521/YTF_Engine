//
//  MaskingView.h
//  YTFTest
//
//  Created by Evyn on 16/12/1.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseWebView.h"
#import "PanGeusterDelegateClass.h"
@interface MaskingView : UIView



/**
 单例初始化对象

 @return self
 */
+ (instancetype)shareInstanceMaskingView;

/**
 创建手势
 */
- (void)createGuester;


/**
 显示蒙板类
 
 @param baseWebView
 
 @param sideWebView
 */
+ (void)showMaskView:(MaskingView *)maskingView
         baseWebView:(BaseWebView *)baseWebView
             sideweb:(BaseWebView *)sideWebView;
@end
