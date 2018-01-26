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

#import <Foundation/Foundation.h>

@interface WXApiRequestHandler : NSObject

/**
 *  跳转微信支付
 *
 *  @param totalFee   价格 分为单位
 *  @param merchantId 商户id
 *  @param notifyUrl  通知url
 *  @param bodyDes    支付描述
 */
+ (void)jumpToWxPayWithTotalFee:(NSString *)totalFee merchantId:(NSString *)merchantId notifyUrl:(NSString *)notifyUrl  bodyDes:(NSString *)bodyDes;

@end
