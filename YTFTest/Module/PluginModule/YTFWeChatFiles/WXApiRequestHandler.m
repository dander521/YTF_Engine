/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    WXApiRequestHandler.
 * =============================================================================
 */


#import "WXApiRequestHandler.h"
#import "YTFWeChatModule.h"
#import "DataMD5.h"
#import "XMLDictionary.h"
#import "YTFAFNetworking.h"
#import "AppDelegate.h"

#pragma mark - 用户获取设备ip地址
#include <ifaddrs.h>
#include <arpa/inet.h>

#define WXUNIFIEDORDERURL @"https://api.mch.weixin.qq.com/pay/unifiedorder"

#pragma mark - 统一下单请求参数键值

// 应用id
#define WXAPPID @"appid"
// 商户号
#define WXMCHID @"mch_id"
// 随机字符串
#define WXNONCESTR @"nonce_str"
// 签名
#define WXSIGN @"sign"
// 商品描述
#define WXBODY @"body"
// 商户订单号
#define WXOUTTRADENO @"out_trade_no"
// 总金额
#define WXTOTALFEE @"total_fee"
// 终端IP
#define WXEQUIPMENTIP @"spbill_create_ip"
// 通知地址
#define WXNOTIFYURL @"notify_url"
// 交易类型
#define WXTRADETYPE @"trade_type"
// 预支付交易会话
#define WXPREPAYID @"prepay_id"

@implementation WXApiRequestHandler

#pragma mark - 产生随机字符串

//生成随机数算法 ,随机字符串，不长于32位
//微信支付API接口协议中包含字段nonce_str，主要保证签名不可预测。
//我们推荐生成随机数算法如下：调用随机数函数生成，将得到的值转换为字符串。
+ (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    
    //  srand函数是初始化随机数的种子，为接下来的rand函数调用做准备。
    //  time(0)函数返回某一特定时间的小数值。
    //  这条语句的意思就是初始化随机数种子，time函数是为了提高随机的质量（也就是减少重复）而使用的。
    
    //　srand(time(0)) 就是给这个算法一个启动种子，也就是算法的随机种子数，有这个数以后才可以产生随机数,用1970.1.1至今的秒数，初始化随机数种子。
    //　Srand是种下随机种子数，你每回种下的种子不一样，用Rand得到的随机数就不一样。为了每回种下一个不一样的种子，所以就选用Time(0)，Time(0)是得到当前时时间值（因为每时每刻时间是不一样的了）。
    
    srand((unsigned)time(0)); // 此行代码有警告:
    
    for (int i = 0; i < kNumber; i++) {
    
        unsigned index = rand() % [sourceStr length];
        
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


#pragma mark - 获取设备ip地址 / 貌似该方法获取ip地址只能在wifi状态下进行

+ (NSString *)fetchIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


#pragma mark - Public Methods

/**
 *  跳转微信支付
 *
 *  @param totalFee   价格 分为单位
 *  @param merchantId 商户id
 *  @param notifyUrl  通知url
 *  @param bodyDes    支付描述
 */
+ (void)jumpToWxPayWithTotalFee:(NSString *)totalFee merchantId:(NSString *)merchantId notifyUrl:(NSString *)notifyUrl bodyDes:(NSString *)bodyDes
{
// 交易类型
#define TRADE_TYPE @"APP"
    // 客户端操作/ 实际操作由服务端操作
    
    // 随机字符串变量 这里最好使用和安卓端一致的生成逻辑
    NSString *tradeNO = [self generateTradeNO];
    
    // 设备IP地址,请再wifi环境下测试,否则获取的ip地址为error,正确格式应该是8.8.8.8
    NSString *addressIP = [self fetchIPAddress];
    
    // 随机产生订单号用于测试，正式使用请换成你从自己服务器获取的订单号
    NSString *orderno = [NSString stringWithFormat:@"%ld",time(0)];
    
//    NSLog(@"delegate===============%@",[UIApplication sharedApplication].delegate);

    // 获取SIGN签名
    DataMD5 *data = [[DataMD5 alloc] initWithAppid:[AppDelegate getExtendWithPluginName:@"weixin"][@"app_id"]
                                            mch_id:merchantId
                                         nonce_str:tradeNO
                                        partner_id:[AppDelegate getExtendWithPluginName:@"weixin"][@"partner_key"]
                                              body:bodyDes
                                      out_trade_no:orderno
                                         total_fee:totalFee
                                  spbill_create_ip:addressIP
                                        notify_url:notifyUrl
                                        trade_type:TRADE_TYPE];
    
    // 转换成XML字符串,这里知识形似XML，实际并不是正确的XML格式，需要使用AF方法进行转义
    NSString *string = [[data dic] XMLString];

    YTFAFHTTPSessionManager *session = [YTFAFHTTPSessionManager manager];
    // 这里传入的XML字符串只是形似XML，但不是正确是XML格式，需要使用AF方法进行转义
    session.responseSerializer = [[YTFAFHTTPResponseSerializer alloc] init];
    [session.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [session.requestSerializer setValue:WXUNIFIEDORDERURL forHTTPHeaderField:@"SOAPAction"];
 //   NSLog(@"delegate===============%@",[UIApplication sharedApplication].delegate);
    [session.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        
  //      NSLog(@"delegate===============%@",[UIApplication sharedApplication].delegate);
        
        return string;
    }];
    
  //  NSLog(@"delegate===============%@",[UIApplication sharedApplication].delegate);
    [session POST:WXUNIFIEDORDERURL parameters:string progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        //  输出XML数据
        NSString *responseString = [[NSString alloc] initWithData:responseObject
                                                         encoding:NSUTF8StringEncoding] ;
        //  将微信返回的xml数据解析转义成字典
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:responseString];
        
        // 判断返回的许可
        if ([[dic objectForKey:@"result_code"] isEqualToString:@"SUCCESS"]
            &&[[dic objectForKey:@"return_code"] isEqualToString:@"SUCCESS"] ) {
            // 发起微信支付，设置参数
            PayReq *request = [[PayReq alloc] init];
            request.openID = [dic objectForKey:WXAPPID];
            request.partnerId = [dic objectForKey:WXMCHID];
            request.prepayId= [dic objectForKey:WXPREPAYID];
            request.package = @"Sign=WXPay";
            request.nonceStr= [dic objectForKey:WXNONCESTR];
            
            // 将当前时间转化成时间戳
            NSDate *datenow = [NSDate date];
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
            UInt32 timeStamp =[timeSp intValue];
            request.timeStamp= timeStamp;
            // 签名加密
            DataMD5 *md5 = [[DataMD5 alloc] init];

            request.sign=[md5 createMD5SingForPay:request.openID
                                        partnerid:request.partnerId
                                         prepayid:request.prepayId
                                          package:request.package
                                         noncestr:request.nonceStr
                                        timestamp:request.timeStamp];
            
            
            // 调用微信
            BOOL bollTest = [WXApi sendReq:request];
            
            #pragma unused(bollTest)
        }
 
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

@end
