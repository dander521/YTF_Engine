//
//  YTFMovieController.m
//  YTFTest
//
//  Created by Evyn on 16/11/4.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "YTFMovieView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Macro.h"
#import "ToolsFounctionMovie.h"
#import "Masonry.h"

//消失时间
#define DisappearTime  4
#define ScreenHeight       [UIScreen mainScreen].bounds.size.height    //获取设备屏幕的长
#define ScreenWidget       [UIScreen mainScreen].bounds.size.width     //获取设备屏幕的宽
#define AVPlayerHeight     [UIScreen mainScreen].bounds.size.height/3.0//播放器的高度
#define buttomViewHeight   45                          // 底部View的高度


@interface YTFMovieView ()<UIGestureRecognizerDelegate,UITextFieldDelegate,ButtomViewMethodProtocol>
/**
 是否正在播放
 */
@property (nonatomic , assign) BOOL isPlaying;
/**
 当前播放时间
 */
@property (nonatomic,assign) CGFloat currentTime;

/**
 电影总时长
 */
@property (nonatomic,assign) CGFloat wholeTime;

/**
 播放完成回调
 */
@property (nonatomic,copy) void(^EndBlock) ();


/**
 影片播放器
 */
@property (nonatomic , strong) AVPlayer *videoPlayer;//播放器
@property (nonatomic , strong) AVPlayerItem *videoItem;//播放单元
@property (nonatomic , strong) AVPlayerItem *hditem;//播放单元
@property (nonatomic , strong) AVPlayerLayer *videoPlayerLayer;//播放界面（layer）


@property (nonatomic , strong) UIActivityIndicatorView *activity; // 系统菊花
@property (nonatomic , strong) UITapGestureRecognizer * tipGeuster;
@property (nonatomic , strong) ToolsFounctionMovie * toolsMovie;

@end

@implementation YTFMovieView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
       return self;
}

- (void)prepareToPlay{
    
    if (self.videoWidth==0) {
        self.videoWidth = ScreenWidth;
    }
    
    self.toolsMovie = [ToolsFounctionMovie shareInstance];
    self.toolsMovie.frameOriginX =   (self.superview).frame.origin.x;
    self.toolsMovie.frameOriginY = (self.superview).frame.origin.y;
    self.toolsMovie.frameWidth   = (self.superview).frame.size.width;
    self.toolsMovie.frameHeight  = (self.superview).frame.size.height;    
    
    self.frame = CGRectMake(self.originX, self.originY, self.videoWidth, self.videoHeight);
    self.backgroundColor  = [UIColor yellowColor];
    
    
    [self createAvPlayer];
    [self setButtomUpUI];
    [self createActiveyView];
    [self creatGuester];
    
    
}

/**
 初始化播放器Avplayer
 */
-(void)createAvPlayer{
    
    self.videoItem = [AVPlayerItem playerItemWithURL:self.mainPath];
    self.videoPlayer = [AVPlayer playerWithPlayerItem:self.videoItem];
    self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    self.videoPlayerLayer.frame =  CGRectMake(0, 0, self.videoWidth , self.videoHeight);
    self.videoPlayerLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.videoPlayerLayer];
    [self.videoPlayer play];
    self.isPlaying = YES;
    
    LWWeakSelf(self);
    [self.videoPlayer seekToTime:kCMTimeZero];
    [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CMTime myCurrentTimeCM = weakself.videoPlayer.currentTime;
        CMTime totalTimeCM     = weakself.videoPlayer.currentItem.duration;
        CGFloat progress       = CMTimeGetSeconds(myCurrentTimeCM)/CMTimeGetSeconds(totalTimeCM);
        CGFloat currentTime    = (CMTimeGetSeconds(myCurrentTimeCM)/1);
        weakself.wholeTime     = (CMTimeGetSeconds(totalTimeCM)/1);
        // 传递时间参数
        weakself.buttomView.currentTimeLabel.text = [NSString stringWithFormat:@"%@",[ToolsFounctionMovie getTimeString:(CGFloat)currentTime]];
            weakself.buttomView.allTmieLabel.text = [NSString stringWithFormat:@"%@",[ToolsFounctionMovie getTimeString:(CGFloat)weakself.wholeTime]];
       
        [weakself.buttomView.progress setValue:(CGFloat)progress animated:YES];
        if (weakself.videoPlayer.status == AVPlayerStatusReadyToPlay) {
            [weakself.activity stopAnimating];
        } else {
            [weakself.activity startAnimating];
        }
    }];
    
    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.videoPlayer.currentItem];
}


/**
 播放完成   系统通知
 */
- (void)moviePlayDidEnd:(id)sender
{
    [self psuseOnClick];
    if (self.EndBlock) {
        self.EndBlock();
    }
    
}
/**
 播放完成回调
 */
- (void)endPlay:(EndBolck) end
{
    self.EndBlock = end;
}
/**
 设置小菊花
 */
- (void)createActiveyView{
    
    self.activity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-50, self.frame.size.height/2-50, 100 , 100)];
    self.activity.activityIndicatorViewStyle =  UIActivityIndicatorViewStyleGray;
    [self.videoPlayerLayer addSublayer:self.activity.layer];
    [self.activity startAnimating];
}

/**
 初始化 底部 视图
 */
-(void)setButtomUpUI
{
    
    NSLog(@"--------%f",self.frame.size.height - buttomViewHeight);
    self.buttomView = [[BottomView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-buttomViewHeight , self.videoWidth, buttomViewHeight) playImgStr:self.playImage pauseImgStr:self.pauseImage standImgStr:self.full_screenImage landscapeImgStr:self.full_screenImage sliderImgStr:self.sliderImage LandscapeMode:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [self addSubview:self.buttomView];
    });
    
    NSLog(@"--------%f",self.buttomView.frame.origin.y);
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime target:self selector:@selector(disappear:) userInfo:nil repeats:NO];
    self.buttomView.buttonDelegate = self;
}

/**
 初始化点击手势
 */
- (void)creatGuester{
    
    self.tipGeuster=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBottomView:)];
    self.tipGeuster.numberOfTouchesRequired = 1; //手指数
    self.tipGeuster.numberOfTapsRequired = 1;    //tap次数
    [self addGestureRecognizer:self.tipGeuster];
}


/**
 点击屏幕 出现底部视图
 
 @param tap
 */
- (void)showBottomView:(UITapGestureRecognizer *)tap{
    
    if (self.buttomView.alpha == 1) {
        //取消定时消失
        [_timer invalidate];
        LWWeakSelf(self);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:^{
                weakself.buttomView.alpha = 0;
            }];
        });
       
        
    }else if (self.buttomView.alpha == 0){
        //添加定时消失
        _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime target:self selector:@selector(disappear:) userInfo:nil repeats:NO];
        LWWeakSelf(self);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:^{
                weakself.buttomView.alpha = 1;
            }];
        });
 
    }
}

#pragma mark - 定时消失
- (void)disappear:(NSTimer *)timer
{
    LWWeakSelf(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            weakself.buttomView.alpha = 0;
        }];
    });
}

#pragma mark -- bottomViewDelegate
/**
 播放进度条
 
 @param sender
 */
- (void)progressSliderClick:(UISlider *)slider{
    
    CGFloat progress = slider.value;
    self.currentTime = progress * self.wholeTime;
    CMTime newTime = CMTimeMakeWithSeconds(self.currentTime,  self.videoPlayer.currentItem.duration.timescale);
    LWWeakSelf(self);
    [ self.videoPlayer seekToTime:newTime completionHandler:^(BOOL finished) {
        if (!finished) {
            [weakself.activity startAnimating];
            DLog(@"网络不好，，，应该转菊花了······················");
        }else{
            [weakself.activity stopAnimating];
            [weakself.videoPlayer play];//KNotificationPauseOrPaly
            [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPauseOrPaly object:nil userInfo:@{@"playStatus":@"play"}];
        }
    }];
}

/**
 全屏 切换 开关
 
 @param sender
 */
- (void)landscapeButtonClick:(UIButton *)sender{
    //取消定时消失
    [_timer invalidate];
    if (!self.buttomView.isLandScape) {
        [self videoPlayerLandScape];
        self.buttomView.isLandScape = YES;
    }else{
        [self videoPlayerPrioriate];
        self.buttomView.isLandScape = NO;
    }
}

/**
 播放器    变全屏
 */
- (void)videoPlayerLandScape{
    
    LWWeakSelf(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        CGAffineTransform transform =CGAffineTransformMakeRotation(-M_PI_2);
        [weakself setTransform:transform];
        (weakself.superview).frame = CGRectMake((weakself.superview).frame.origin.x, -20, (weakself.superview).frame.size.width, (weakself.superview).frame.size.height+20);
    
        [UIView animateWithDuration:0.2 animations:^{
            weakself.center = CGPointMake(ScreenWidget/2, ScreenHeight/2);
            weakself.frame = CGRectMake(0, 0, ScreenWidget, ScreenHeight);
            weakself.buttomView.frame = CGRectMake(0, weakself.frame.size.width - weakself.buttomView.frame.size.height, ScreenHeight, weakself.buttomView.frame.size.height);
            
            [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationUpDataUI object:nil userInfo:@{@"screenStatus":@"LandScape"}];
            weakself.backgroundColor = [UIColor yellowColor];
            if (weakself.videoPlayerLayer) {
                weakself.videoPlayerLayer.frame  = CGRectMake(0, 0, ScreenHeight, ScreenWidget);
            }
        }];
    });
}


/**
 播放器    回竖屏
 */
- (void)videoPlayerPrioriate{
    
    LWWeakSelf(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        // transForm 恢复到之前的状态   -(M_PI_2*4)
        weakself.transform = CGAffineTransformIdentity;
        (weakself.superview).frame = CGRectMake(weakself.toolsMovie.frameOriginX, weakself.toolsMovie.frameOriginY,weakself.toolsMovie.frameWidth, weakself.toolsMovie.frameHeight);
        [UIView animateWithDuration:0.2 animations:^{
            weakself.frame = CGRectMake(0,0,weakself.videoWidth, weakself.videoHeight);
            weakself.buttomView.frame = CGRectMake(0, weakself.frame.size.height - weakself.buttomView.frame.size.height, self.videoWidth, weakself.buttomView.frame.size.height);
            [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationUpDataUI object:nil userInfo:@{@"screenStatus":@"proit"}];
            if (weakself.videoPlayerLayer) {
                weakself.videoPlayerLayer.frame  = CGRectMake(0, 0, weakself.videoWidth , weakself.videoHeight);
            }
        }];
    });
}

/**
 播放开关
 */
- (void)playButtonClick:(UIButton *)sender{
    if (self.isPlaying) {
        
        [self psuseOnClick];
        
        
    }else{
        
        [self playOnClick];
        
     }
}


/**
 暂停
 */
- (void)psuseOnClick{
    self.isPlaying = NO;
    [[ToolsFounctionMovie shareInstance] addImageViewInSender:self.buttomView.playBt imageStr:self.playImage];
    [self.videoPlayer pause];
     [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPauseOrPaly object:nil userInfo:@{@"playStatus":@"pause"}];
    if (self.PlayBlock) {
        self.PlayBlock(@0);
    }
}

/**
 播放
 */
- (void)playOnClick{

    self.isPlaying = YES;
    [[ToolsFounctionMovie shareInstance] addImageViewInSender:self.buttomView.playBt imageStr:self.pauseImage];
    [self.videoPlayer play];
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPauseOrPaly object:nil userInfo:@{@"playStatus":@"play"}];
    if (self.PlayBlock) {
        self.PlayBlock(@1);
    }
}
/**
 播放暂停
 
 @param playStatusBt 传递的Block
 */
- (void)playStatusButton:(playStatusBlock)playStatusBt{

      self.PlayBlock = playStatusBt;
}


- (void)dealloc{

    [[NSNotificationCenter defaultCenter]removeObserver:KNotificationUpDataUI];
    [[NSNotificationCenter defaultCenter]removeObserver:KNotificationPauseOrPaly];
    [self.videoPlayer pause];
    self.videoPlayer = nil;
    DLog(@"---------------------------videoView 被销毁了");
}




@end
