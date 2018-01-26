//
//  UIViewController+SetAndGet.m
//  YTFTest
//
//  Created by Evyn on 16/12/8.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "UIView+SetAndGet.h"
#import "SlipCloseWinGuesterManager.h"
#import "BaseWebView.h"
#import "Definition.h"

@implementation UIView (SetAndGet)

/**
 复写 由匿名分类(类扩展extension)新增的属性 的 set方法
 @param slidBackEnabled slidBackEnabled
 */
- (void)setSlidBackEnabled:(BOOL)slidBackEnabled{
    if(slidBackEnabled){
        // 将插件开发者自定义的 view 传过去，再那边调用 加上侧滑关闭窗口的手势
        [[NSNotificationCenter defaultCenter]postNotificationName:ModuleViewSlipBackGuestureNotific object:nil userInfo:@{@"object":self}];
    }
}


/**
 复写由匿名分类新增的属性--侧滑打开Drawer属性
 
 @param openDrawerEnabled 侧滑打开Drawer
 */
- (void)setOpenDrawerEnabled:(BOOL)openDrawerEnabled{
    if(!openDrawerEnabled){
        // 只有当自定义的  view 上有手势需要响应时 才不会向下传递，也就不会响应父视图的手势
      [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moduleViewOpenDrawerPan:)]];
        
    }
    
}

- (void)moduleViewOpenDrawerPan:(UIPanGestureRecognizer *)pan{

    DLog(@"子视图响应了手势");

}

@end
