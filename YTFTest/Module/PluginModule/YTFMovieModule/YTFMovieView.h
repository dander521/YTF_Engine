//
//  YTFMovieController.h
//  YTFTest
//
//  Created by Evyn on 16/11/4.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomView.h"
typedef void(^playStatusBlock)(NSNumber * statusNum);
typedef void(^EndBolck)();

@interface YTFMovieView : UIView

//插件传入的参数
@property (nonatomic, assign)  CGFloat   originX;
@property (nonatomic, assign)  CGFloat   originY;
@property (nonatomic, assign)  CGFloat   videoWidth;
@property (nonatomic, assign)  CGFloat   videoHeight;
@property (nonatomic, copy)    NSString  *fixedOn;
@property (nonatomic, assign)   BOOL    *fixed;
@property (nonatomic, copy)    NSString *playImage;
@property (nonatomic, copy)    NSString *sliderImage;
@property (nonatomic, copy)    NSString *pauseImage;
@property (nonatomic, copy)    NSString *full_screenImage;
@property (nonatomic, copy)    NSURL *mainPath;

/**
 轻拍定时器
 */
@property (nonatomic,strong) NSTimer *timer;


/**
 底部的视图栏
 */
@property (nonatomic , strong) BottomView *buttomView;

/**
 播放或者暂停的回调
 */
@property (nonatomic,copy) void(^PlayBlock) (NSNumber *playButtonStatus);



/**
 播放暂停

 @param playStatusBt 传递的Block
 */
- (void)playStatusButton:(playStatusBlock) playStatusBt;

/**
 播放完成回调
 */
- (void)endPlay:(EndBolck) end;

/**
 整体创建播放器
 */
- (void)prepareToPlay;

/**
 播放
 */
- (void)playOnClick;

/**
 暂停
 */
- (void)psuseOnClick;

/**
 播放器    变全屏
 */
- (void)videoPlayerLandScape;

/**
 播放器    回竖屏
 */
- (void)videoPlayerPrioriate;
@end
