//
//  BottomView.h
//  UZApp
//
//  Created by Evyn on 16/10/20.
//  Copyright © 2016年 YTFCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtomViewMethodProtocol.h"

@interface BottomView : UIView

@property (nonatomic, weak) id <ButtomViewMethodProtocol> buttonDelegate;//点击各个button 触发的事件

@property (nonatomic, copy) NSString *pauseImgStr;//暂停按钮的图片地址
@property (nonatomic, copy) NSString *playImgStr;//播放按钮的图片地址
@property (nonatomic, copy) NSString *standImgStr;//竖屏按钮图片地址
@property (nonatomic, copy) NSString *sliderImgStr;//竖屏按钮图片地址
@property (nonatomic, copy) NSString *landscapeImgStr;//横屏按钮的图片地址

@property (nonatomic, strong) UIButton *playBt;
@property (nonatomic, strong) UIButton *standBt;//竖屏按钮
@property (nonatomic, strong) UIButton *landscapeBt;//横屏
@property (nonatomic, strong) UISlider *progress;//进度条
@property (nonatomic, assign) BOOL  isLandScape;//进度条

@property (nonatomic, strong) UILabel  *currentTimeLabel;
@property (nonatomic, strong) UILabel  *allTmieLabel;


/**
 初始化底部 View
 
 @param frame
 @param isLandscapeMode 是否为横屏
 
 @return
 */
- (instancetype)initWithFrame:(CGRect)frame  playImgStr:(NSString *)playImgStr
                  pauseImgStr:(NSString *)pauseImgStr  standImgStr:(NSString *)standImgStr landscapeImgStr:(NSString *)landscapeImgStr sliderImgStr:(NSString *)sliderImgStr LandscapeMode:(BOOL)isLandscapeMode;

@end
