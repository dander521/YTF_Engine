//
//  AmapLocation.m
//  YTFTest
//
//  Created by Evyn on 16/12/7.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "AmapLocation.h"
#import "AppDelegate.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ToolsFunction.h"

@interface AmapLocation ()

@property (nonatomic, weak) UIWebView *noViewWebView;
@property (nonatomic, copy) NSString *noViewCbid;

@end

@implementation AmapLocation


/**
 *  无界面后台定位
 *
 *  @param args JS传入的参数
 */
- (void)getLocation:(NSDictionary *)args{

    [AMapServices sharedServices].apiKey = [AppDelegate getExtendWithPluginName:@"aMap"][@"app_key_ios"];
    
    self.locationManager = [[AMapLocationManager alloc] init];

    
    /**
     *  0：Hight_Accuracy，高精度模式
     1：Device_Sensors，仅设备(Gps)模式
     2：Battery_Saving，低功耗模式
     */
    
    
    // 参数解析
    self.noViewCbid                 = args[@"cbId"];
    self.noViewWebView              = args[@"target"];
    NSDictionary * noViewInfoDic    = args[@"args"];
    // 定位精度模式
    NSNumber * locationMode = noViewInfoDic[@"mode"];
    
    //设置模式
    if ([locationMode isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    }
    else  if ([locationMode isEqualToNumber:[NSNumber numberWithInteger:1]]){
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
    }
    else  if ([locationMode isEqualToNumber:[NSNumber numberWithInteger:2]]){
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    }
    
    
    //    定位超时时间，最低2s，此处设置为2s
    self.locationManager.locationTimeout =2;
    //    逆地理请求超时时间，最低2s，此处设置为2s
    self.locationManager.reGeocodeTimeout = 2;
    //    带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            NSString * testString = [ToolsFunction dicToJavaScriptString:@{@"errCode":[NSNumber numberWithLong:(long)error.code]}];
            [self performSelectorOnMainThread:@selector(aMapFailCallBackLocation:) withObject:testString waitUntilDone:NO];
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        if (regeocode)
        {
            NSDictionary * resultDic;
            if (!resultDic) {
                resultDic = [NSMutableDictionary dictionary];
            }
            
            resultDic = @{@"latitude":[NSString stringWithFormat:@"%f",location.coordinate.latitude],
                          @"longitude":[NSString stringWithFormat:@"%f",location.coordinate.longitude],
                          @"province":regeocode.province,
                          @"city":regeocode.city,
                          @"district":regeocode.district,
                          @"street":regeocode.street,
                          @"streetNum":regeocode.number};
            
            NSString * testString = [ToolsFunction dicToJavaScriptString:resultDic];
            [self performSelectorOnMainThread:@selector(aMapCallBackLocation:) withObject:testString waitUntilDone:NO];
            
        }
    }];

}


/**
 定位失败回调
 
 @param testString
 */
- (void)aMapFailCallBackLocation:(NSString *)resultString{
    
    [self.noViewWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',false);",self.noViewCbid,resultString]];
    
    
}

/**
 定位成功回调
 
 @param testString
 */
- (void)aMapCallBackLocation:(NSString *)resultString{
    
    [self.noViewWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',false);",self.noViewCbid,resultString]];
    
    
}

@end
