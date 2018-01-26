//
//  YTFMovieMainClass.m
//  YTFTest
//
//  Created by Evyn on 16/11/4.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "YTFMovieMainClass.h"
#import "Macro.h"
#import "AppDelegate.h"



@interface YTFMovieMainClass ()

@property (nonatomic , copy)   NSString *instanceCBId;
@property (nonatomic , weak)   UIWebView *movieInWebView;
@property (nonatomic , strong) YTFMovieView * movieView;


@end

@implementation YTFMovieMainClass

- (void)instanceMovie:(NSMutableDictionary *)args{
    
    NSDictionary * uiParamsDic    = args[@"args"];
    self.movieView                = [[YTFMovieView alloc]init];
    
    self.instanceCBId             = args[@"cbId"];
    self.movieInWebView           = args[@"target"];
    
    // 设置 frame
    self.movieView.originX        = [uiParamsDic[@"x"] doubleValue];
    self.movieView.originY        = [@0 doubleValue];
    self.movieView.videoWidth     = [uiParamsDic[@"w"] doubleValue];
    self.movieView.videoHeight    = [uiParamsDic[@"h"] doubleValue];
    self.movieView.fixedOn        = uiParamsDic[@"fixedOn"];
    
    // 设置图片
    [self setImageResources:uiParamsDic];
    // 视频url
    self.movieView.mainPath = [NSURL URLWithString:uiParamsDic[@"hdUrl"]];
    // 是否添加上了视图
    BOOL  isAddSuccess =  [self addSubview:self.movieView fixedOn:self.movieView.fixedOn fixed:NO];
    // 开始播放
    [self.movieView prepareToPlay];
    // 回调
    [self sendCallBackDataWithCallbackBadge:args[@"target"] cbid:args[@"cbid"] dataDict:@{@"status":[NSNumber numberWithBool:isAddSuccess]} errDict:nil doDelete:NO];
    
}

/**
 调用播放暂停的状态
 
 @param args js 参数
 */
- (void)addListenerMovie:(NSMutableDictionary *)args{
    
    NSString *  bCbid           = args[@"cbId"];
    id   currentWebView         = args[@"target"];
    
    LWWeakSelf(self);
    LWWeakSelf(currentWebView);
    
    // 播放暂停 状态回调给js
    [self.movieView playStatusButton:^(NSNumber *statusNum) {
        [weakself sendCallBackDataWithCallbackBadge:weakcurrentWebView
                                               cbid:bCbid
                                           dataDict:@{@"status":statusNum}
                                            errDict:nil doDelete:NO];
    }];
    
    // 播放完毕  回调给js
    [self.movieView endPlay:^{
        [weakself sendCallBackDataWithCallbackBadge:weakcurrentWebView
                                               cbid:bCbid
                                           dataDict:@{@"status":@"playEnded"}
                                            errDict:nil doDelete:NO];
    }];
    
}

/**
 设置播放暂停的状态
 @param args js 参数
 */
- (void)setPlayStatusMovie:(NSDictionary *)args{

    NSDictionary * paramsDic    = args[@"args"];
    NSNumber *playMark          = paramsDic[@"play"];
    if ([playMark isEqualToNumber:[NSNumber numberWithBool:1]]) {
        //播放
        [self.movieView playOnClick];
        
    }else if ([playMark isEqualToNumber:[NSNumber numberWithBool:0]]){
        //暂停
        [self.movieView psuseOnClick];
    }
}


/**
 设置全屏 半屏 的状态
 @param args js 参数
 */
- (void)setFullScreenStatusMovie:(NSDictionary *)args{

    NSDictionary * paramsDic          = args[@"args"];
    NSNumber *fullScreenMark          = paramsDic[@"fullScreen"];
    [self.movieView.timer invalidate];//取消定时消失
    if ([fullScreenMark isEqualToNumber:[NSNumber numberWithBool:1]]) {
        //全屏
        self.movieView.buttomView.isLandScape = YES;
        [self.movieView videoPlayerLandScape];
        
    }else if ([fullScreenMark isEqualToNumber:[NSNumber numberWithBool:0]]){
        //竖屏
        self.movieView.buttomView.isLandScape = NO;
        [self.movieView videoPlayerPrioriate];
    }

}


#pragma mark -- Coustom Method
/**
 设置图片，js不传就带默认图片

 @param uiParamsDic js参数
 */
- (void)setImageResources:(NSDictionary *)uiParamsDic{

    ((NSString *)uiParamsDic[@"play"]).length        == 0 ? (self.movieView.playImage = @"YTFmediacontroller_play") :  (self.movieView.playImage =[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:uiParamsDic[@"play"]]);
    
    ((NSString *)uiParamsDic[@"pause"]).length       == 0 ? (self.movieView.pauseImage = @"YTFmediacontroller_pause") : (self.movieView.pauseImage = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:uiParamsDic[@"pause"]]);
    
    ((NSString *)uiParamsDic[@"process"]).length     == 0 ? (self.movieView.sliderImage = @"YTF1") : (self.movieView.sliderImage =[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:uiParamsDic[@"process"]]);
    
    ((NSString *)uiParamsDic[@"full_screen"]).length == 0 ? (self.movieView.full_screenImage = @"YTFmediacontroller_landscape") : (self.movieView.full_screenImage =[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:uiParamsDic[@"full_screen"]]);


}


- (void)dealloc{
    
    DLog(@"--------------------------- MovieMainClass 被销毁了");
}




@end
