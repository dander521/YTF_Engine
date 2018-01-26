/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link        http://www.ytframework.cn
 * =============================================================================
 *  @author     Tangqian<tanufo@126.com>
 *  @created    2015-10-10
 *  @description
 * =============================================================================
 */

#import "YTFAliPayModule.h"
#import "AppDelegate.h"
#import "ToolsFunction.h"
//导入支付宝相关头文件
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import "Definition.h"


@implementation YTFAliPayModule

/**
 *  AliPay 支付宝
 *
 *  @param args JS传入的参数
 */
- (void)pay:(NSDictionary *)args{
    
    /**
     *  partner:"2088421786602282",
     seller_id:"yuantuan@yuantuan.com",
     rsa_private:"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBANTTHnnQnecLIvCAbRkgnaV8ehpGBpr4Wsd7mc1dwphjWwUbT30/7JPsqQQgwIgyGLb9FmsISBBbB0ALrbohlMFq0S+z3UeCUXPRc2EF4T7H4F4JZy89n+T0dzL5YVnI1cUNxlUbT64BhDBejAxlP6LREieBxpNP1WtOyTPuLldDAgMBAAECgYBaKfsuVoCfIquxwmb2D0halMrSGLqxqugivS2iwMcxcl5cYn6hrJRY8xmD4zBOQxMPa1e1DrQhIb+HlasLQTDYnnRUGcO8lN8Hfif+S4lcR1LQilLF5nhcvIyuRwamX2fxsAOzydGSgcD7z+hFnML4RV7s0yAOX4bphNSarDFT2QJBAPhjJvsiBvml7e9YTBBLQ7IxS/Xn8mpjYCf/GDcYyzGDyyz+Hcrp6MRF5pSCsJFImWoU047S7rhSSkDVyiHxC7UCQQDbWPE35gWHJvqJN9qlR95d1zLHchGsE1uRDNHD1UXL+V5jZtMRGOX31C0uB4AqJoLuYLYK70b0dXbcRWLDv2IXAkEAiHubEMVKxeS6EBkZep6QrRpPXei8mF7QmEmgWa4DAMslWiyr3DKZVzf9kj8ZnEsjGVomQUWALMHy0RtoPSxBPQJAOU1+Du1fqlQrhWd7Dky9MeTDVkldhoe0FyuzLSbtSgFGgE9feor3oQvkFa9N8zUGZYIMbMTf04NQXvEdgSfhVwJAZBdILGE717X68+f9qyQ3aT8RIVCPQkkkrM0EIVQpFyTmOLn9aYdeGnUc6+c+hhCBh+gq3Et2UZOQASQ4mvn1lw==",
     tradeNO:"22382222",
     productName:"iPhone 1 MAX",
     productDescription:"光棍福利,大降价",
     amount:"0.01",
     notifyURL:"http://www.baidu.com",
     appScheme:"YTFTest",
     itBPay:"30m"
     */
   
    
    // 参数解析
    aliPayCbid                 = args[@"cbId"];
    aliPayWebView              = args[@"target"];
    NSDictionary * prodInfoDic  = args[@"args"];
    
    productNameArgs            = prodInfoDic[@"subject"];
    productDescriptionArgs     = prodInfoDic[@"body"];
    amountArgs                 = prodInfoDic[@"total_fee"];
    itBPayArgs                 = prodInfoDic[@"it_b_pay"];
    
    
    DLog(@"------------调用支付宝------------");
    
    // 设置 ApplicationDelegate  代理对象
     [[AppDelegate shareAppDelegate] addAppDelegateHandle:self];
     DLog(@"self.viewController========%@",self.viewController);
    //****************************************** 支付业务
    Order *order = [[Order alloc] init];
    //配置支付信息
    order.partner = [AppDelegate getExtendWithPluginName:@"aliPay"][@"partner"];
    order.seller = [AppDelegate getExtendWithPluginName:@"aliPay"][@"seller_id"];
    //交易号，订单号  由服务器提供，也就是说你买东西，提交订单，服务器会给你返回一个订单ID，这个ID在服务器中是唯一的
    order.tradeNO = [self getTradeID]; //订单ID（由商家?自?行制定）
    order.productName = productNameArgs; //商品标题
    order.productDescription = productDescriptionArgs; //商品描述
    //商品价格，单元：元
    order.amount = amountArgs; //商品价格
    //回调URL,支付宝支付完成时需要通知服务器修改订单信息
    order.notifyURL = [AppDelegate getExtendWithPluginName:@"aliPay"][@"notify_url"]; //回调URL
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = itBPayArgs;
    
    //scheme:一个应用程序调用另一个应用程序，另一个应用程序回到最初调用的程序时需要设置scheme
    //NSString *appScheme = [AppDelegate getExtendWithPluginName:@"aliPay"][@"appScheme"];
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    //  NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner([AppDelegate getExtendWithPluginName:@"aliPay"][@"rsa_private"]);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
    
       NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
         [[AlipaySDK defaultService] payOrder:orderString fromScheme:appName callback:^(NSDictionary *resultDic) {
            //支付成功
           [self performSelectorOnMainThread:@selector(jsCallBack:) withObject:resultDic waitUntilDone:NO];
             
        }];
    }
}

#pragma mark --YTFApplicationDelegate
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            //            NSLog(@"aliPay result ========= %@",resultDic);
        }];
    }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            //            NSLog(@"result = %@",resultDic);
        }];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            //          NSLog(@"aliPay result ========= %@",resultDic);
            //block 代码中执行UI 必须回到主线程
            [self performSelectorOnMainThread:@selector(jsCallBack:) withObject:resultDic waitUntilDone:NO];
            
        }];
    }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
        }];
    }
    
    return YES;
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options{
    
    
    //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
          //  NSLog(@"aliPay result ========= %@ memo=========%@",[resultDic[@"resultStatus"] superclass] ,resultDic[@"memo"]);
            NSDictionary * callBackDic ;
            CFStringRef aCFString = (__bridge CFStringRef)resultDic[@"resultStatus"];
            NSString *aNSString = (__bridge NSString *)aCFString;
//            NSLog(@"aNSString====%@",aNSString);
            if ([aNSString isEqualToString:[NSString stringWithFormat:@"9000"]]) {
                callBackDic = @{@"status":@1};
                
            }else if (![aNSString isEqualToString:[NSString stringWithFormat:@"9000"]]){

//                 NSLog(@"00000000000");
 //                NSLog(@"00000000000====%@",[resultDic[@"resultStatus"] class]);
                callBackDic = @{@"status":@0,@"msg":resultDic[@"memo"]};
            }
            
            //block 代码中执行UI 必须回到主线程
            [self performSelectorOnMainThread:@selector(jsCallBack:) withObject:callBackDic waitUntilDone:NO];
        }];
    }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
        }];
    }
    
    return YES;
    
}

/**
 *  随机生成支付订单
 *
 *  @return 当前时间戳加随机数
 */
- (NSString *)getTradeID{

    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
     int randomString = arc4random()% 10000;
    
    NSString * tradeString = [NSString stringWithFormat:@"%@%d",dateString,randomString];

    return tradeString;
}

- (void)jsCallBack:(NSDictionary *)resultDic{
    
    NSString * testString = [ToolsFunction dicToJavaScriptString:resultDic];
    [aliPayWebView stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"YTFcb.on('%@','%@',false);",aliPayCbid,testString]];
}

- (void)dealloc{

    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationWhenModuleDealloc object:nil];
}

@end
