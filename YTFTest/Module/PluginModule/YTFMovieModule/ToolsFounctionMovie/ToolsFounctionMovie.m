//
//  ToolsFounction.m
//  UZApp
//
//  Created by Evyn on 16/11/3.
//  Copyright © 2016年 YTFCloud. All rights reserved.
//

#import "ToolsFounctionMovie.h"
#import <UIKit/UIKit.h>
@implementation ToolsFounctionMovie


+ (instancetype)shareInstance{

    static  ToolsFounctionMovie * tollFounct = nil;
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tollFounct  = [[ToolsFounctionMovie alloc]init];
    });
    return tollFounct;
}

//  秒转 小时分
+ (NSString *)getTimeString:(CGFloat)timeInterval
{
    NSInteger hour = timeInterval / 3600.f;
    NSInteger minute = (timeInterval - hour * 3600.f) / 60.f;
    NSInteger second = timeInterval - hour * 3600.f - minute * 60.f;
    
    if(hour > 0)
    {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld",(long)hour,(long)minute,(long)second];
    }
    else
    {
        return [NSString stringWithFormat:@"%02ld:%02ld",(long)minute,(long)second];
    }
}

//  getter 
- (void)setFrameOriginX:(float)frameOriginX{
    if (!_frameOriginX) {
        _frameOriginX = frameOriginX;
    }
}

- (void)setFrameOriginY:(float)frameOriginY{
    if (!_frameOriginY) {
        _frameOriginY = frameOriginY;
    }
}
- (void)setFrameWidth:(float)frameWidth{
    if (!_frameWidth) {
        _frameWidth = frameWidth;
    }
}
- (void)setFrameHeight:(float)frameHeight{
    if (!_frameHeight) {
        _frameHeight = frameHeight;
    }
}

/**
 给 button  设置图片
 
 @param sender button
 @param imageString 图片路径或远程地址
 */
- (void)addImageViewInSender:(UIButton *)sender imageStr:(NSString *)imageString{
    if ([imageString hasPrefix:@"http"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageString]]] forState:UIControlStateNormal];
        });
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setBackgroundImage:[UIImage imageNamed:imageString] forState:UIControlStateNormal];
        });
    }
}


@end
