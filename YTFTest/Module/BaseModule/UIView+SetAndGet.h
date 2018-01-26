//
//  UIViewController+SetAndGet.h
//  YTFTest
//
//  Created by Evyn on 16/12/8.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SetAndGet) <UIGestureRecognizerDelegate>


/**
 复写由匿名分类新增的属性--侧滑关闭窗口属性

 @param slidBackEnabled slidBackEnabled
 */
- (void)setSlidBackEnabled:(BOOL)slidBackEnabled;


/**
 复写由匿名分类新增的属性--侧滑打开Drawer属性

 @param openDrawerEnabled 侧滑打开Drawer
 */
- (void)setOpenDrawerEnabled:(BOOL)openDrawerEnabled;



@end
