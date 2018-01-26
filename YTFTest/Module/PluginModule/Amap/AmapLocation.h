//
//  AmapLocation.h
//  YTFTest
//
//  Created by Evyn on 16/12/7.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTFModule.h"
#import <AMapLocationKit/AMapLocationKit.h>
@interface AmapLocation : YTFModule

// 这个属性主要用来请求权限
@property (nonatomic, strong) AMapLocationManager *locationManager;
/**
 *  无界面后台定位
 *
 *  @param args JS传入的参数
 */
- (void)getLocation:(NSDictionary *)args;

@end
