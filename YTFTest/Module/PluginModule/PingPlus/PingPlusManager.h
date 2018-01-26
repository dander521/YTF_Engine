//
//  PingPlusManager.h
//  PingPlusPlus
//
//  Created by Evyn on 17/1/5.
//  Copyright © 2017年 com.yuantuan.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTFModule.h"
#import "AppDelegate.h"

@interface PingPlusManager : YTFModule <UIApplicationDelegate>



/**
 获取版本号

 @param args JS 传入原生的参数
 */
- (void)getVersion:(NSDictionary *)args;

/**
 设置调试模式

 @param args JS 传入原生的参数
 */
- (void)setDebugMode:(NSDictionary *)args;

/**
 调用支付控件进行支付
 
 @param args JS 传入原生的参数
 */
- (void)createPayment:(NSDictionary *)args;
@end
