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

#import "RC4DecryModule.h"

@implementation RC4DecryModule

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
+ (NSData *)dataDecry_RC4WithByteArray:(Byte *)byteArray key:(NSString *)key fileData:(NSData *)fileData
{
    if (byteArray == nil || key == nil || fileData == nil)
    {
        return nil;
    }
    
    NSData *byteData = [[NSData alloc] initWithBytes:[RC4DecryModule RC4BaseWithByteArray:byteArray key:key fileData:fileData] length:fileData.length];
    
    return byteData;
}

/**
 *  解密byte数组
 *
 *  @param byteArray data 的 byte 数组
 *  @param key       解密的key
 *  @param fileData  需要解密的data数据
 *
 *  @return 解密的string
 */
+ (NSString *)decry_RC4WithByteArray:(Byte *)byteArray key:(NSString *)key fileData:(NSData *)fileData
{
    if (byteArray == nil || key == nil || fileData == nil)
    {
        return nil;
    }
    
    NSData *byteData = [[NSData alloc] initWithBytes:[RC4DecryModule RC4BaseWithByteArray:byteArray key:key fileData:fileData] length:fileData.length];
    NSString *byteString = [[NSString alloc] initWithData:byteData encoding:NSUTF8StringEncoding];
    
    return byteString;
}

/**
 *  解密byte数组
 *
 *  @param byteArray data 的 byte 数组
 *  @param key       解密的key
 *  @param fileData  需要解密的data数据
 *
 *  @return 解密byte的数据
 */
+ (Byte *)RC4BaseWithByteArray:(Byte *)byteArray key:(NSString *)key fileData:(NSData *)fileData
{
    int x = 0;
    int y = 0;
    
    Byte *b_key = [RC4DecryModule transformKeyToByteWithKey:key];
    int xorIndex = 0;
    
    Byte *result = malloc(fileData.length);
    memset(result, 0, fileData.length);
    
    for (int i = 0; i < fileData.length; i++) {
        x = (x + 1) & 0xff;
        y = ((b_key[x] & 0xff) + y) & 0xff;
        char tmp = b_key[x];
        b_key[x] = b_key[y];
        b_key[y] = tmp;
        xorIndex = ((b_key[x] & 0xff) + (b_key[y] & 0xff)) & 0xff;
        result[i] = (Byte) (byteArray[i] ^ b_key[xorIndex]);
    }
    
    return result;
}

/**
 *  string 转换到 byte数组
 *
 *  @param key 解密的key
 *
 *  @return byte数组
 */
+ (Byte *)transformKeyToByteWithKey:(NSString *)key
{
    Byte *b_key = [self getByteWithString:key];
    
    Byte *state = malloc(256);
    memset(state, 0, 256);
    
    for (int i = 0; i < 256; i++) {
        state[i] = (char)i;
    }
    
    int index1 = 0;
    int index2 = 0;
    if (key == nil || key.length == 0)
    {
        return nil;
    }
    
    for (int i = 0; i < 256; i++) {
        index2 = ((b_key[index1] & 0xff) + (state[i] & 0xff) + index2) & 0xff;
        char tmp = state[i];
        state[i] = state[index2];
        state[index2] = tmp;
        index1 = (index1 + 1) % key.length;
    }
    
    return state;
}

/**
 *  获取byte
 *
 *  @param string 数据字符串
 *
 *  @return byte数组
 */
+ (Byte *)getByteWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return (Byte *)[data bytes];
}

/**
 *  解密string算法 -> 暂时未使用
 *
 *  @param dataString 解密字符串
 *  @param key        解密key
 *
 *  @return 解密后字符串
 */
+ (NSString*)RC4Decode:(NSString*)dataString key:(NSString*)key
{
    NSString *resultString = dataString;
    // int 数组
    NSMutableArray *arrayDataString = [NSMutableArray new];
    // char 数组
    NSMutableArray *arrayKey = [NSMutableArray new];
    
    unsigned long dataStringLength = [dataString length];
    unsigned long keyStringLength = [key length];
    
    for (int i = 0; i < 256; i++)
    {
        UniChar c = [key characterAtIndex:i%keyStringLength];
        
        [arrayKey addObject:[NSNumber numberWithChar:c]];
        
        [arrayDataString addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i = 0; i < 256; i++)
    {
        int j = i;
        
        j = (j + [arrayDataString[i] intValue] + [arrayKey[i] intValue]) % 256;
        
        NSNumber *tempNum = nil;
        tempNum = arrayDataString[i];
        arrayDataString[i] = arrayDataString[j];
        arrayDataString[j] = tempNum;
    }
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (int i = 0; i < dataStringLength; i++)
    {
        int a = i;
        int j = i;
        
        a = (a + 1) % 256;
        j = (j + [arrayDataString[a] intValue]) % 256;
        
        NSNumber *tempNum = nil;
        tempNum = arrayDataString[a];
        arrayDataString[a] = arrayDataString[j];
        arrayDataString[j] = tempNum;
        
        int k = 0;
        k = [arrayDataString[(([arrayDataString[a] intValue] + [arrayDataString[j] intValue]) % 256)] intValue];
        
        [array addObject:[NSNumber numberWithInt:k]];
        
        UniChar c = (UniChar)[resultString characterAtIndex:i];
        
        UniChar ch = c^k;
        
        resultString = [resultString stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&ch length:1]];
    }
    
    return resultString;
}


@end
