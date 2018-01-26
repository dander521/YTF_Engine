/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFLocationModule Plugin.
 * =============================================================================
 */

#import "YTFLocationModule.h"
#import "ToolsFunction.h"

@implementation YTFLocationModule

/**
 *  无界面后台定位
 *
 *  @param args JS传入的参数
 */
- (void)getLocation:(NSDictionary *)args{

    /**
     *  0：Hight_Accuracy，高精度模式
        1：Device_Sensors，仅设备(Gps)模式
        2：Battery_Saving，低功耗模式
     */
     // 参数解析
    noViewCbid                     = args[@"cbId"];
    noViewWebView                  = args[@"target"];
    NSDictionary * noViewInfoDic   = args[@"args"];
    // 定位精度模式
    NSString * locationMode = noViewInfoDic[@"mode"];
    //实例化manager  以及定位的基础设置
    [self initLocationManagerAndGeoder:locationMode];
   
}


/**
 *  无界面后台定位  停止
 *
 *  @param args JS传入的参数
 */
- (void)noViewStopLocation:(NSDictionary *)args{

    [self.locationManager stopUpdatingLocation];

    NSDictionary *dictionarg = @{@"status" :@"停止定位成功"};
    NSString * testString = [ToolsFunction dicToJavaScriptString:dictionarg];
    
     [args[@"target"] stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",args[@"cbId"],testString]];
}

/**
 *  y有界面后台定位
 *
 *  @param args JS传入的参数
 */
- (void)viewLocationMethod:(NSDictionary *)args{
    
    
    
    
}


/**
 *  实例化manager  以及定位的基础设置
 */
- (void)initLocationManagerAndGeoder:(NSString *)locationMode{

    // 实例化定位管理器
    self.locationManager = [[CLLocationManager alloc] init];
    self.geocoder = [CLGeocoder new];
    
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 1;
    
    // 根据JS  要求来设置 定位精度
    if ([locationMode isEqual: [NSNumber numberWithInt:0]]) {
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    }
    
    if ([locationMode isEqual: [NSNumber numberWithInt:1]]) {
        self.locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters;
    }
    
    if ([locationMode isEqual: [NSNumber numberWithInt:2]]) {
        self.locationManager.desiredAccuracy=kCLLocationAccuracyThreeKilometers;
    }
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
     //   NSLog(@"------------------------     后台定位中 __IPHONE_9_0   ------------------");
    }
    //启动跟踪定位
    [self.locationManager startUpdatingLocation];
    //   NSLog(@"------------------------     后台定位中 __IPHONE_9_0   ------------------");
}

#pragma mark --locationManager delegate

//这是定位手机的代理，这个代理会返回一个locations是一个数组给你  因为同一个地方有很多种描述方式
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    /**
     *  latitude:0,//纬度
     　　longitude:0,//经度
     　　province:"省",//省份
     　　city:"市",//市
     　　district:"区域",//区域
     　　address:"详细地址",//详细地址
     　　street:"街道",//街道
     　　streetNum:"街道号",//街道号
     　　locationType:0,//定位方式
     */
    
    //locations数组里边存放的是CLLocation对象，一个CLLocation对象就代表着一个位置
    CLLocation *loc = [locations firstObject];
    self.userLocation = [[CLLocation alloc] initWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude];
    [self.geocoder reverseGeocodeLocation:self.userLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //获取最后一个地标对象
        CLPlacemark *placemark              = [placemarks lastObject];
        NSString *cityName                  = placemark.addressDictionary[@"City"];
        NSString * provinceName             = placemark.addressDictionary[@"State"];
        NSString * streetName               = placemark.addressDictionary[@"Street"];
        NSString * thoroughfareName         = placemark.addressDictionary[@"thoroughfare"];
        NSString * subThoroughfareName      = placemark.addressDictionary[@"subThoroughfare"];
       
        NSString * subLocalityName          = placemark.addressDictionary[@"SubLocality"];
        
        //北京市 --> 北京(前提:模拟器语言中文的)
        cityName = [cityName substringToIndex:cityName.length - 1];
        
        NSDictionary * resultDic;
        if (!resultDic) {
            resultDic = [NSMutableDictionary dictionary];
        }
        if (placemark) {
            
            if (!thoroughfareName && subThoroughfareName) {
                
                resultDic = @{@"latitude":[NSNumber numberWithDouble:loc.coordinate.latitude],@"longitude":[NSNumber numberWithDouble:loc.coordinate.longitude],@"province":provinceName,@"city":cityName,@"district":subLocalityName,@"street":streetName,@"streetNum":subThoroughfareName};
                
            }else if (!subThoroughfareName && thoroughfareName){
             
                resultDic = @{@"latitude":[NSNumber numberWithDouble:loc.coordinate.latitude],@"longitude":[NSNumber numberWithDouble:loc.coordinate.longitude],@"province":provinceName,@"city":cityName,@"district":subLocalityName,@"street":streetName,@"address":thoroughfareName};
                
            }else if (subThoroughfareName && thoroughfareName){
            
                resultDic = @{@"latitude":[NSNumber numberWithDouble:loc.coordinate.latitude],@"longitude":[NSNumber numberWithDouble:loc.coordinate.longitude],@"province":provinceName,@"city":cityName,@"district":subLocalityName,@"street":streetName,@"address":thoroughfareName,@"streetNum":subThoroughfareName};
            
            }else if (!subThoroughfareName && !thoroughfareName){
                
                resultDic = @{@"latitude":[NSNumber numberWithDouble:loc.coordinate.latitude],@"longitude":[NSNumber numberWithDouble:loc.coordinate.longitude],@"province":provinceName,@"city":cityName,@"district":subLocalityName,@"street":streetName};
            
            }
            NSString * testString = [ToolsFunction dicToJavaScriptString:resultDic];
            [self performSelectorOnMainThread:@selector(jsCallBackLocation:) withObject:testString waitUntilDone:NO];
            //  返回数据之后  就停止定位 调一次定一次
            [self.locationManager stopUpdatingLocation];
        }
    }];
}


- (void)locationManager:(CLLocationManager *)manager

       didFailWithError:(NSError *)error {
    
    NSDictionary *dictionarg;
    if (!dictionarg) {
        dictionarg = [NSDictionary dictionary];
    }
    switch (error.code) {
        case kCLErrorLocationUnknown:
            
            dictionarg = @{@"errCode":@0,@"errInfo":@"定位服务返回定位失败"};
     //NSLog(@"location is currently unknown, but CL will keep trying");
            
            break;
        case kCLErrorNetwork:
            
            dictionarg = @{@"errCode":@1,@"errInfo":@"请求服务器过程中的异常，多为网络情况差，链路不通导致"};
    //NSLog(@"请求服务器过程中的异常，多为网络情况差，链路不通导致");
            break;
        case kCLErrorGeocodeCanceled:
            
            dictionarg = @{@"errCode":@2,@"errInfo":@"请求被恶意劫持，定位结果解析失败"};
    //NSLog(@"请求服务器过程中的异常，多为网络情况差，链路不通导致");
            
            break;
        
            
        default:
           dictionarg = @{@"errCode":@3,@"errInfo":@"未知错误"};
            break;
    }
    
    NSString * testString = [ToolsFunction dicToJavaScriptString:dictionarg];
    
    
     [self performSelectorOnMainThread:@selector(locationFailedCallBack:) withObject:testString waitUntilDone:NO];
    
 }

/**
 定位成功回调
 
 @param testString
 */
- (void)jsCallBackLocation:(NSString *)resultString{
    
    [noViewWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",noViewCbid,resultString]];
    
    
}

/**
 定位失败回调

 @param testString
 */
- (void)locationFailedCallBack:(NSString *)testString{
    
    [noViewWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",noViewCbid,testString]];

}

@end
