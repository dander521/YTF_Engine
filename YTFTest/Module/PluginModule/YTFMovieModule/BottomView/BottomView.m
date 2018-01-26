//
//  BottomView.m
//  UZApp
//
//  Created by Evyn on 16/10/20.
//  Copyright © 2016年 YTFCloud. All rights reserved.
//

#import "BottomView.h"
#import "Macro.h"
#import "Masonry.h"
#import "ToolsFounctionMovie.h"

#define ButtonWidth    20.f
#define ButtonHeight   20.f

#define labelWidth     35.f
#define labelHeight    20.f

#define buttonTop      self.frame.size.height/2- ButtonHeight/2
#define labelTop       self.frame.size.height/2-labelHeight/2

#define progressHeight 1.f
#define progressTop    self.frame.size.height/2 - progressHeight/2

#define leftPedding     25.f
#define spacePedding    10.f

#define originAlpa      0.5f

@interface BottomView ()



@property (nonatomic, copy) NSString *currentTimeStr;//当前的播放时间
@property (nonatomic) NSTimer *timer;//计时  五秒后自动隐藏视图
@property (nonatomic, copy) NSString *playStatus;//当前播放状态
@property (nonatomic, copy) NSString *screenStatus;//当前播放状态

@end

@implementation BottomView


/**
 初始化底部 View

 @param frame
 @param isLandscapeMode 是否为横屏

 @return
 */

/**
 @param frame
 @param isLandscapeMode

 @return
 */
- (instancetype)initWithFrame:(CGRect)frame  playImgStr:(NSString *)playImgStr
                  pauseImgStr:(NSString *)pauseImgStr  standImgStr:(NSString *)standImgStr landscapeImgStr:(NSString *)landscapeImgStr sliderImgStr:(NSString *)sliderImgStr LandscapeMode:(BOOL)isLandscapeMode{
    if (self = [super initWithFrame:frame]) {
        
        self.playImgStr            = playImgStr;
        self.pauseImgStr           = pauseImgStr;
        self.landscapeImgStr       = landscapeImgStr;
        self.sliderImgStr          = sliderImgStr;
        self.backgroundColor       = [UIColor blackColor];
        self.isLandScape           = NO;
        self.backgroundColor       = [[UIColor blackColor] colorWithAlphaComponent:originAlpa];
        // 初始化控件
        self.playBt                = [UIButton buttonWithType:UIButtonTypeCustom];
        self.landscapeBt           = [UIButton buttonWithType:UIButtonTypeCustom];
        self.currentTimeLabel      = [[UILabel alloc]init];
        self.progress              = [[UISlider alloc]init];
        self.allTmieLabel          = [[UILabel alloc]init];
        
        // 接收通知  更新底部视图
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUIInterface:) name:KNotificationUpDataUI object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseOrPlayStatus:) name:KNotificationPauseOrPaly object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
             [self setUpUI];
        });
    }
    return self;
}


/**
 横屏后更新视图

 @param dic
 */
- (void)updateUIInterface:(NSNotification *)dic{
    
      self.screenStatus = dic.userInfo[@"screenStatus"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUpUI];
    });
}

- (void)pauseOrPlayStatus:(NSNotification *)dic{
    @synchronized (self) {
        self.playStatus = dic.userInfo[@"playStatus"];
    }
    
    
}
- (void)setUpUI{

    //播放按钮
    self.playBt.backgroundColor = [UIColor clearColor];
    //self.playBt.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 监听播放状态 来修改图片设置
    if ([self.playStatus isEqualToString: @"play"]) {
        
        [[ToolsFounctionMovie shareInstance] addImageViewInSender:self.playBt imageStr:self.pauseImgStr];
       
    }else if ([self.playStatus isEqualToString: @"pause"]){
        
        [[ToolsFounctionMovie shareInstance] addImageViewInSender:self.playBt imageStr:self.playImgStr];
        
    }else{
        
        [[ToolsFounctionMovie shareInstance] addImageViewInSender:self.playBt imageStr:self.pauseImgStr];
    }
    [self.playBt addTarget:self action:@selector(playBtClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playBt];
    
   
    if ([self.screenStatus isEqualToString:@"LandScape"]){
        
        [self.playBt mas_updateConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(self.mas_left).with.offset(leftPedding+30);
        }];
        
    }else if ([self.screenStatus isEqualToString:@"proit"]){
        
        [self.playBt mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(leftPedding);
        }];
        
    }else{
        [self.playBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(buttonTop);
            make.left.equalTo(self.mas_left).with.offset(leftPedding);
            make.width.equalTo(@ButtonWidth);
            make.height.equalTo(@ButtonHeight);
        }];
    }
    //当前播放时间
    self.currentTimeLabel.backgroundColor = [UIColor clearColor];
    self.currentTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.currentTimeLabel.font = [UIFont systemFontOfSize:13];
    self.currentTimeLabel.adjustsFontSizeToFitWidth = YES;
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.currentTimeLabel.numberOfLines = 1;
    [self addSubview:self.currentTimeLabel];
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(labelTop);
        make.left.equalTo(self.playBt.mas_right).with.offset(spacePedding);
        make.width.equalTo(@labelWidth);
        make.height.equalTo(@labelHeight);
    }];
    
    
    //横屏按钮
    
    self.landscapeBt.translatesAutoresizingMaskIntoConstraints = NO;
    self.landscapeBt.backgroundColor = [UIColor clearColor];
    [[ToolsFounctionMovie shareInstance] addImageViewInSender:self.landscapeBt imageStr:self.landscapeImgStr];
    [self.landscapeBt addTarget:self action:@selector(landscapeBtClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.landscapeBt];
    [self.landscapeBt mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top).with.offset(buttonTop);
        make.width.equalTo(@ButtonWidth);
        make.height.equalTo(@ButtonHeight);
        
        if ([self.screenStatus isEqualToString:@"LandScape"]) {
            make.right.equalTo(self.mas_right).with.offset(-spacePedding-10);
        }else if ([self.screenStatus isEqualToString:@"proit"]){
            make.right.equalTo(self.mas_right).with.offset(-spacePedding);
        }else{
           make.right.equalTo(self.mas_right).with.offset(-spacePedding);
        }
        
    }];
    
    //总的时间
    self.allTmieLabel.backgroundColor = [UIColor clearColor];
    self.allTmieLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.allTmieLabel.font = [UIFont systemFontOfSize:13];
    self.allTmieLabel.textColor = [UIColor whiteColor];
    self.allTmieLabel.adjustsFontSizeToFitWidth = YES;
    self.allTmieLabel.textAlignment = NSTextAlignmentCenter;
    self.allTmieLabel.numberOfLines = 1;
    [self addSubview:self.allTmieLabel];
    [self.allTmieLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(labelTop);
        make.right.equalTo(self.landscapeBt.mas_left).with.offset(-spacePedding);
        make.width.equalTo(@labelWidth);
        make.height.equalTo(@labelHeight);
    }];
    
    //进度条
    [self.progress setThumbImage:[UIImage imageNamed:self.sliderImgStr]forState:UIControlStateNormal];
    self.progress.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progress setValue:0];
    [self.progress setTintColor:[UIColor redColor]];
    [self.progress addTarget:self action:@selector(slideAction:) forControlEvents:UIControlEventValueChanged];
     [self addSubview:self.progress];
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(progressTop);
        make.left.equalTo(self.currentTimeLabel.mas_right).with.offset(spacePedding/2);
        make.right.equalTo(self.allTmieLabel.mas_left).with.offset((-spacePedding)/2);
        make.height.equalTo(@progressHeight);
    }];
   

     self.allTmieLabel.center=self.currentTimeLabel.center=self.progress.center=self.landscapeBt.center;
}


-(void)setSlideValue:(CGFloat)value{

     [self.progress setValue:value animated:YES];
}

/**
 点击暂停按钮
 
 @param pauseSender 执行暂停事件
 */
- (void)playBtClick:(UIButton *)playSender{
    if (self.buttonDelegate && [self.buttonDelegate respondsToSelector:@selector(playButtonClick:)]) {
        [self.buttonDelegate playButtonClick:playSender];
    }
}

/**
 拖动进度条

 @param slider 改变位置，修改播放器的事件
 */
-(void)slideAction:(UISlider *)slider{
    if (self.buttonDelegate && [self.buttonDelegate respondsToSelector:@selector(progressSliderClick:)]) {
        [self.buttonDelegate progressSliderClick:slider];
    }
}
/**
 横屏
 
 @param sender 触发为横屏事件
 */
- (void)landscapeBtClick:(UIButton *)sender{
    
    if (self.buttonDelegate && [self.buttonDelegate respondsToSelector:@selector(landscapeButtonClick:)]) {
        [self.buttonDelegate landscapeButtonClick:sender];
    }
}

@end
