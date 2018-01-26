/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFAliPayModule Plugin.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "YTFModule.h"
// XIUGAI
@interface YTFAliPayModule : YTFModule <UIApplicationDelegate>
{

    NSString *   aliPayCbid;
    id   aliPayWebView;
    NSString * productNameArgs;
    NSString * productDescriptionArgs;
    NSString * itBPayArgs;
    NSString * amountArgs;
    NSDictionary * quanjuDicResult;

}

/**
 *  AliPay 支付宝
 *
 *  @param args JS传入的参数
 */
- (void)pay:(NSDictionary *)args;

@end
