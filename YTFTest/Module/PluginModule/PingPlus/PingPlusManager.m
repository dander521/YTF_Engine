//
//  PingPlusManager.m
//  PingPlusPlus
//
//  Created by Evyn on 17/1/5.
//  Copyright © 2017年 com.yuantuan.www. All rights reserved.
//

#import "PingPlusManager.h"
#import "AppDelegate.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "Pingpp.h"
#import "ToolsFunction.h"

@interface PingPlusManager ()

{
    UIWebView  *versionWebView;    //获取版本号webView回调环境
    NSString   *versionCbid;       //获取版本号的CbID;
    
    UIWebView  *payMentWebView;    //支付的webView回调环境
    NSString   *payMentCbid;       //支付的CbID;
    id          charge;            //js 传入的订单参数
    NSString   *scheme;            //iOS的URL scheme
}

@end
@implementation PingPlusManager



/**
 获取版本号
 
 @param args JS 传入原生的参数
 */
- (void)getVersion:(NSDictionary *)args{

    // 接收js参数
    versionCbid    =  args[@"cbId"];
    versionWebView =  args[@"target"];
    NSString * backString = [ToolsFunction dicToJavaScriptString:@{@"version":[Pingpp version]}];
    [args[@"target"] stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"YTFcb.on('%@','%@',false);",args[@"cbId"],backString]];

}


/**
 设置调试模式
 
 @param args JS 传入原生的参数
 */
- (void)setDebugMode:(NSDictionary *)args{

    [Pingpp setDebugMode:[args[@"enabled"] boolValue]];

}

/**
 调用支付控件进行支付

 @param args JS 传入原生的参数
 */
- (void)createPayment:(NSDictionary *)args{
    
   
    // 是否测试模式
     [Pingpp setDebugMode:YES];
    
    
   
    // 接收js参数
     payMentCbid    =  args[@"cbId"];
     payMentWebView =  args[@"target"];
     charge = args[@"args"][@"charge"];
    scheme = args[@"args"][@"scheme"];// 支付宝的scheme如果为其他网址则支付成功后无法正常回调到应用
    if ([charge containsString:@"alipay"] || [charge containsString:@"AliPay"] || [charge containsString:@"aliPay"] || [charge containsString:@"Alipay"]) {
        scheme = nil;
    }
      [Pingpp createPayment:charge
               viewController:self.viewController
                 appURLScheme:scheme
               withCompletion:^(NSString *result, PingppError *error) {
                   NSDictionary * resultDic;
                     if ([result isEqualToString:@"success"]) {
                       // 支付成功
                       resultDic = @{@"result":@"success"};
                   } else {
                      // NSLog(@"支付  失败     Error: code=%d msg=%@",error.code, [error getMsg]);
                       
                       if ([[error getMsg] isEqualToString:@"User cancelled the operation"]) {
                           // 取消支付
                            resultDic = @{@"result":@"cancel"};
                       }
                       
                       else if ([[error getMsg] isEqualToString:@"WeChat is not installed"]){
                           //  未安装微信
                           resultDic = @{@"result":@"invalid"};
                           
                       }else{
                       
                           resultDic = @{@"code":[NSNumber numberWithInteger:error.code],@"msg":[error getMsg]};
                       
                       }
                    }
                   
                   [self performSelectorOnMainThread:@selector(pingppJsCallBack:) withObject:resultDic waitUntilDone:NO];
               }];
    
    
    // 设置代理对象  此方法需要写在插件方法的最后（强制规定）
    [[AppDelegate shareAppDelegate] addAppDelegateHandle:self];

}

/**
 ping++的支付回调
 
 @param resultDic 回调参数
 */
- (void)pingppJsCallBack:(NSDictionary *)resultDic{
    
    NSString * testString = [ToolsFunction dicToJavaScriptString:resultDic];
    [payMentWebView stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"YTFcb.on('%@','%@',false);",payMentCbid,testString]];
}


#pragma maek -- AppDelegate
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{

    BOOL canHandleURL = [Pingpp handleOpenURL:url withCompletion:nil];
        return canHandleURL;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    BOOL canHandleURL = [Pingpp handleOpenURL:url withCompletion:nil];
    return canHandleURL;

}




@end
