//
//  YTFQRCodeModule.h
//  YTFQRCodeModule
//
//  Created by apple on 2016/10/19.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTFModule.h"

@interface YTFQRCodeModule : YTFModule
{
    id qrWebView;
    NSString *qrCbId;
}

/**
 *  打开QRCode页面
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)openScanQRCodeView:(NSDictionary *)paramsDictionary;

/**
 *  读取二维码图片
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)decodeQRCodeImage:(NSDictionary *)paramsDictionary;

/**
 *  生成二维码图片
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)encodeQRCodeImage:(NSDictionary *)paramsDictionary;

@end
