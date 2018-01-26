/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    CustomWebViewProtocol to intercept local JS Css file.
 * =============================================================================
 */

#import "CustomWebViewProtocol.h"
#import <UIKit/UIKit.h>
#import "YTFSDWebImageManager.h"
#import "UIImage+YTFMultiFormat.h"
#import "NSData+YTFImageContentType.h"
#import "UIImage+YTFGIF.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "RC4DecryModule.h"

static NSString * const hasInitKey = @"CustomWebViewProtocolKey";

@interface CustomWebViewProtocol ()

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation CustomWebViewProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([[[request URL] host] isEqualToString:@"debugger"]){
        DLog(@"%@", [[[request URL] path] substringFromIndex: 1]);
    }
#ifdef DecryMode
    if ([request.URL.scheme isEqualToString:@"applewebdata"] ||
        [request.URL.scheme isEqualToString:@"file"])
    {
        NSString *str = request.URL.path;
        if (([str hasSuffix:@".ttf"] || [str hasSuffix:@".png"] || [str hasSuffix:@".js"] || [str hasSuffix:@".css"]|| [str hasSuffix:@".html"])
            && ![NSURLProtocol propertyForKey:hasInitKey inRequest:request])
        {
            return YES;
        }
    }
    
    return NO;
#else
    return NO;
#endif
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    return mutableReqeust;
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    
    // 做下标记，防止递归调用
    [NSURLProtocol setProperty:@YES forKey:hasInitKey inRequest:mutableReqeust];
    
    // 文件类型
    NSString *mimiType = nil;
    
    if([mutableReqeust.URL.lastPathComponent hasSuffix:@"html"] || [mutableReqeust.URL.lastPathComponent hasSuffix:@"htm"])
    {
        mimiType = MimeTypeHtml;
    }
    
    if([mutableReqeust.URL.lastPathComponent hasSuffix:@"png"])
    {
        mimiType = MimeTypePng;
    }
    
    if([mutableReqeust.URL.lastPathComponent hasSuffix:@"gif"])
    {
        mimiType = MimeTypeGif;
    }
    
    if([mutableReqeust.URL.lastPathComponent hasSuffix:@"jpg"] || [mutableReqeust.URL.lastPathComponent hasSuffix:@"jpeg"])
    {
        mimiType = MimeTypeJpg;
    }
    
    if([mutableReqeust.URL.lastPathComponent hasSuffix:@"js"])
    {
        mimiType = MimeTypeJs;
    }
    
    if([mutableReqeust.URL.lastPathComponent hasSuffix:@"css"])
    {
        mimiType = MimeTypeCss;
    }
    
    if([mutableReqeust.URL.lastPathComponent hasSuffix:@"ttf"])
    {
        mimiType = MimeTypeTtf;
    }
    
    // 获取相对路径
//    NSString *reletivePath = [NSString stringWithFormat:@"assets/widget%@", mutableReqeust.URL.relativePath];
//    NSString *hotFixPath = [FilePathCustomHotFix stringByAppendingPathComponent:reletivePath];
    NSString *localFilePath = mutableReqeust.URL.relativePath;
//    if ([ToolsFunction isFileExistAtPath:hotFixPath])
//    {
//        localFilePath = hotFixPath;
//    } else {
//        localFilePath = [FilePathAppResources stringByAppendingPathComponent:reletivePath];
//    }

    NSData *decryData = nil;
    
    if([mimiType isEqualToString:MimeTypeCss] || [mimiType isEqualToString:MimeTypeJs] || [mimiType isEqualToString:MimeTypeHtml])
    {
        NSData *data = [NSData dataWithContentsOfFile:localFilePath];
        decryData = [RC4DecryModule dataDecry_RC4WithByteArray:(Byte *)[data bytes] key:DecryKey fileData:data];
    } else {
        decryData = [NSData dataWithContentsOfFile:localFilePath];
    }
    
    if (mimiType) {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[[self request] URL]
                                                            MIMEType:mimiType
                                               expectedContentLength:[decryData length]
                                                    textEncodingName:@"UTF8"];
        
        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [[self client] URLProtocol:self didLoadData:decryData];
        [[self client] URLProtocolDidFinishLoading:self];
    }
    else {
        self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
    }
}

- (void)stopLoading
{
    [self.connection cancel];
}

#pragma mark- NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] init];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *cacheImage = [UIImage sd_imageWithData:self.responseData];
    //利用SDWebImage提供的缓存进行保存图片
    [[YTFSDImageCache sharedImageCache] storeImage:cacheImage
                           recalculateFromImage:NO
                                      imageData:self.responseData
                                         forKey:[[YTFSDWebImageManager sharedManager] cacheKeyForURL:self.request.URL]
                                         toDisk:YES];
    
    [self.client URLProtocolDidFinishLoading:self];
}

@end
