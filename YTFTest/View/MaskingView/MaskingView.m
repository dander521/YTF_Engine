//
//  MaskingView.m
//  YTFTest
//
//  Created by Evyn on 16/12/1.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "MaskingView.h"
#import "YTFConfigManager.h"
#import "Definition.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

@interface MaskingView ()

@property (nonatomic, strong)UITapGestureRecognizer * tapBackDrawerGest;
@property (nonatomic, strong)UIPanGestureRecognizer * groupSideWinPan;
@property (nonatomic, weak) BaseWebView  *baseWebView;
@property (nonatomic, weak) BaseWebView  *sideWeb;
@property (nonatomic, strong) PanGeusterDelegateClass * panDelegateObj;//实现手势坐标逻辑的类
@property (nonatomic, strong) NSMutableArray *sideWebViewArray;//所有的sideDrawer


@end
@implementation MaskingView

/**
 单例初始化对象
 
 @return self
 */
+ (instancetype)shareInstanceMaskingView{
    
    static MaskingView * maskV = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        maskV = [[self alloc] init];
        maskV.backgroundColor = [UIColor clearColor];
        maskV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [maskV createGuester];
        maskV.panDelegateObj =[PanGeusterDelegateClass shareInshance]; //[[PanGeusterDelegateClass alloc]init];
        [ToolsFunction getCurrentVC];        
        
    });
    return maskV;
}


/**
 创建手势
 */
- (void)createGuester{

    self.tapBackDrawerGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHideDrawerGest:)];
    self.groupSideWinPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(maskingGroupPan:)];
    [self addGestureRecognizer:self.tapBackDrawerGest];
    [self addGestureRecognizer:self.groupSideWinPan];

}

/**
 单点击 隐藏drawer
 @param tapGest
 */
- (void)tapHideDrawerGest:(UITapGestureRecognizer *)tapGest{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 animations:^{
            self.baseWebView.transform = CGAffineTransformIdentity;
            self.sideWeb.transform = CGAffineTransformIdentity;
            self.baseWebView.isDrawerOpen = NO;
            self.backgroundColor = [UIColor clearColor];
            self.sideWeb.isDrawerOpen = NO;
            self.hidden = YES;
        }];
    });
    [self getSideWebViewArr];
    for (BaseWebView * baseWeb in self.sideWebViewArray) {
        baseWeb.isDrawerOpen = NO;
    }
    
}


/**
 向左边滑 隐藏drawer
 @param maskingPan
 */
- (void)maskingGroupPan:(UIPanGestureRecognizer *)maskingPan{
    
    if ([((BaseWebView *)(self.superview.superview)) isMemberOfClass:[UIScrollView class]]) {
        
        [self.panDelegateObj  groupSidePanGuester:self.baseWebView sideWin:self.sideWeb guester:maskingPan leftEdge:[[YTFConfigManager shareConfigManager] configLeftEdge:self.baseWebView.leftEdge] leftZone:[[YTFConfigManager shareConfigManager] configLeftZone:self.baseWebView.leftZone] leftScale:self.baseWebView.leftScale];
    }else{
        [self.panDelegateObj frameSidePanGuester:self.baseWebView sideWin:self.sideWeb guester:maskingPan leftEdge:[[YTFConfigManager shareConfigManager] configLeftEdge:self.baseWebView.leftEdge] leftZone:[[YTFConfigManager shareConfigManager] configLeftZone:self.baseWebView.leftZone] leftScale:self.baseWebView.leftScale];
    
    }
}

/**
 显示蒙板类
 
 @param baseWebView
 
 @param sideWebView
 */
+ (void)showMaskView:(MaskingView *)maskingView
         baseWebView:(BaseWebView *)baseWebView
             sideweb:(BaseWebView *)sideWebView{
    //蒙版配置属性
    maskingView.baseWebView =  baseWebView;
    maskingView.sideWeb     =  sideWebView;
    maskingView.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.8];
    maskingView.hidden      = NO;
    
    if (![baseWebView.subviews containsObject:maskingView]) {
         [baseWebView addSubview:maskingView];
    }
}




/**
 获取现在所有的 side web
 */
- (void)getSideWebViewArr{
    
    if (!self.sideWebViewArray) {
        self.sideWebViewArray = [NSMutableArray array];
    }
    
    for (BaseWebView *baseWebView in [AppDelegate shareAppDelegate].baseViewController.view.subviews){
        if ([baseWebView isMemberOfClass:[BaseWebView class]] && baseWebView.drawerWinName.length!=0) {
            [self.sideWebViewArray addObject:baseWebView];
        }
    }
    
}

- (void)dealloc{

    DLog(@"-------Masking Dealloc-----------");

}


@end
