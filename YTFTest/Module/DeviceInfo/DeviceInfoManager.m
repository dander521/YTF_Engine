/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Device infomation manager.
 * =============================================================================
 */

#import "DeviceInfoManager.h"
#import "Definition.h"
#import "sys/utsname.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "Reachability.h"

@implementation DeviceInfoManager

+ (instancetype)shareManager
{
    static DeviceInfoManager *deviceInfoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceInfoManager = [[self alloc] init];
    });
    
    return deviceInfoManager;
}

/**
 *  注入js的设备信息
 *
 *  @return
 */
+ (NSArray *)deviceInfoArray
{
    NSMutableArray *arrayDeviceInfo = [NSMutableArray new];

    [arrayDeviceInfo addObject:@{SystemType : [DeviceInfoManager appSystemType]}];
    [arrayDeviceInfo addObject:@{DeviceName : [DeviceInfoManager appDeviceName]}];
    [arrayDeviceInfo addObject:@{SystemVersion : [DeviceInfoManager appSystemVersion]}];
    [arrayDeviceInfo addObject:@{DeviceId : [DeviceInfoManager appDeviceId]}];
    [arrayDeviceInfo addObject:@{DeviceModel : [DeviceInfoManager appDeviceModel]}];
    [arrayDeviceInfo addObject:@{AppScreenWidth : [DeviceInfoManager appScreenWidth]}];
    [arrayDeviceInfo addObject:@{AppScreenHeight : [DeviceInfoManager appScreenHeight]}];
    [arrayDeviceInfo addObject:@{OperatorName : [DeviceInfoManager operatorName]}];
    
    return arrayDeviceInfo;
}

/**
 *  设备系统类型
 *
 *  @return
 */
+ (NSString *)appSystemType
{
    return [[UIDevice currentDevice] systemName];
}

/**
 *  设备系统版本
 *
 *  @return
 */
+ (NSString *)appSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

/**
 *  设备id
 *
 *  @return
 */
+ (NSString *)appDeviceId
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    CFRelease(uuid);
    
    return uuidString;
}

/**
 *  设备名称
 *
 *  @return
 */
+ (NSString *)appDeviceName
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    return deviceString;
}

/**
 *  设备型号
 *
 *  @return
 */
+ (NSString *)appDeviceModel
{
    return [[UIDevice currentDevice] model];
}

/**
 *  屏幕宽度
 *
 *  @return
 */
+ (NSString *)appScreenWidth
{
    return [NSString stringWithFormat:@"%f", ScreenWidth];
}

/**
 *  屏幕高度
 *
 *  @return
 */
+ (NSString *)appScreenHeight
{
    return [NSString stringWithFormat:@"%f", ScreenHeight];
}

/**
 运营商名
 
 @return
 */
+ (NSString *)operatorName
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    //当前手机所属运营商名称
    
    NSString *mobile = nil;
    
    //先判断有没有SIM卡，如果没有则不获取本机运营商
    
    if (!carrier.isoCountryCode)
    {
        mobile = @"无运营商";
    }else{
        mobile = [carrier carrierName];
    }

    return mobile;
}

/**
 获取设备网络状态
 */
- (void)getNetStatus:(BaseWebView *)webView
{
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfGetNetStatus"] = ^() {

        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NSString *tips = @"";
        switch (reach.currentReachabilityStatus)
        {
            case NotReachable:
                tips = @"offLine";
                break;
                
            case ReachableViaWiFi:
                tips = @"wifi";
                break;
                
            case ReachableViaWWAN:

            case kReachableVia2G:
                tips = @"2G";
                break;
                
            case kReachableVia3G:
                tips = @"3G";
                break;
                
            case kReachableVia4G:
                tips = @"4G";
                break;
            default:
                tips = @"unknown";
                break;
        }
        
        return tips;
    };
}


@end
