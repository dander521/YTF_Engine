/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic function method.
 * =============================================================================
 */

#import <Foundation/Foundation.h>

@interface RC4DecryModule : NSObject

#pragma mark - RC4

/**
 *  解密byte数组
 *
 *  @param byteArray data 的 byte 数组
 *  @param key       解密的key
 *  @param fileData  需要解密的data数据
 *
 *  @return 解密的data
 */
+ (NSData *)dataDecry_RC4WithByteArray:(Byte *)byteArray key:(NSString *)key fileData:(NSData *)fileData;

/**
 *  解密byte数组
 *
 *  @param byteArray data 的 byte 数组
 *  @param key       解密的key
 *  @param fileData  需要解密的data数据
 *
 *  @return 解密的string
 */
+ (NSString *)decry_RC4WithByteArray:(Byte *)byteArray key:(NSString *)key fileData:(NSData *)fileData;

@end
