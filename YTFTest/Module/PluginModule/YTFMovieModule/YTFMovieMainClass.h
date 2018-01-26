//
//  YTFMovieMainClass.h
//  YTFTest
//
//  Created by Evyn on 16/11/4.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "YTFModule.h"
#import "YTFMovieView.h"
@interface YTFMovieMainClass : YTFModule


/**
 初始化视频播放器

 @param args js 参数
 */
- (void)instanceMovie:(NSDictionary *)args;


/**
 监听播放暂停的状态

 @param args js 参数
 */
- (void)addListenerMovie:(NSDictionary *)args;


/**
 设置播放暂停的状态
 
 @param args js 参数
 */
- (void)setPlayStatusMovie:(NSDictionary *)args;


/**
 设置全屏 半屏 的状态
 
 @param args js 参数
 */
- (void)setFullScreenStatusMovie:(NSDictionary *)args;



@end
