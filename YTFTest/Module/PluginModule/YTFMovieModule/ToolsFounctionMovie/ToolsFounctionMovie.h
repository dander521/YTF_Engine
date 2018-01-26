//
//  ToolsFounction.h
//  UZApp
//
//  Created by Evyn on 16/11/3.
//  Copyright © 2016年 YTFCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ToolsFounctionMovie : NSObject

@property (nonatomic , assign) float frameOriginX;
@property (nonatomic , assign) float frameOriginY;
@property (nonatomic , assign) float frameWidth;
@property (nonatomic , assign) float frameHeight;


+ (instancetype)shareInstance;

//  秒转 小时分
+ (NSString *)getTimeString:(CGFloat)timeInterval;

/**
 给 button  设置图片
 
 @param sender button
 @param imageString 图片路径或远程地址
 */
- (void)addImageViewInSender:(UIButton *)sender imageStr:(NSString *)imageString;
@end
