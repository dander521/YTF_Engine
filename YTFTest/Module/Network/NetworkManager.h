/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic network manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "YTFAFNetworking.h"

@class BaseWebView;

/**
 *  宏定义请求成功的block
 *
 *  @param response 请求成功返回的数据
 */
typedef void (^YTFResponseSuccess)(NSURLSessionDataTask *task, id responseObject,YTFAFHTTPSessionManager *manager);

/**
 *  宏定义请求失败的block
 *
 *  @param error 报错信息
 */
typedef void (^YTFResponseFail)(NSURLSessionDataTask *task, NSError *error,YTFAFHTTPSessionManager *manager);

/**
 *  上传或者下载的进度
 *
 *  @param progress 进度
 */
typedef void (^YTFProgress)(NSProgress *progress);

@interface NetworkManager : NSObject



#pragma mark - Ajax

/**
 *  JS Ajax 网络请求
 *
 *  @param webView JSContext webView
 */
- (void)ajaxHttpRequestWithWebView:(BaseWebView *)webView;

/**
 *  JS Ajax 下载文件
 *
 *  @param webView JSContext
 */
- (void)ajaxDownloadFilesWithWebView:(BaseWebView *)webView;

/**
 *  JS Ajax 取消下载
 *
 *  @param webView JSContet
 */
- (void)ajaxCancelDownloadWithWebView:(BaseWebView *)webView;

#pragma mark - AFNetworking

/**
 *  普通get方法请求网络数据
 *
 *  @param url     请求网址路径
 *  @param params  请求参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void)GET:(NSString *)url
     params:(NSDictionary *)params
    success:(YTFResponseSuccess)success
       fail:(YTFResponseFail)fail;
/**
 *  含有baseURL的get方法
 *
 *  @param url     请求网址路径
 *  @param baseUrl 请求网址根路径
 *  @param params  请求参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void)GET:(NSString *)url
    baseURL:(NSString *)baseUrl
     params:(NSDictionary *)params
    success:(YTFResponseSuccess)success
       fail:(YTFResponseFail)fail;

/**
 *  普通post方法请求网络数据
 *
 *  @param url     请求网址路径
 *  @param params  请求参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void)POST:(NSString *)url
      params:(NSDictionary *)params
     success:(YTFResponseSuccess)success
        fail:(YTFResponseFail)fail;

/**
 *  含有baseURL的post方法
 *
 *  @param url     请求网址路径
 *  @param baseUrl 请求网址根路径
 *  @param params  请求参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+ (void)POST:(NSString *)url
     baseURL:(NSString *)baseUrl
      params:(NSDictionary *)params
     success:(YTFResponseSuccess)success
        fail:(YTFResponseFail)fail;

/**
 *  单文件 普通路径上传文件
 *
 *  @param url      请求网址路径
 *  @param params   请求参数
 *  @param filedata 文件
 *  @param name     指定参数名
 *  @param filename 文件名（要有后缀名）
 *  @param mimeType 文件类型
 *  @param progress 上传进度
 *  @param success  成功回调
 *  @param fail     失败回调
 */
+ (void)uploadWithURL:(NSString *)url
               params:(NSDictionary *)params
             fileData:(NSData *)filedata
                 name:(NSString *)name
             fileName:(NSString *)filename
             mimeType:(NSString *) mimeType
             progress:(YTFProgress)progress
              success:(YTFResponseSuccess)success
                 fail:(YTFResponseFail)fail;



/**
 * 多文件 普通路径上传文件
 *
 *  @param url      请求网址路径
 *  @param params   请求参数
 *  @param filedata 文件
 *  @param name     指定参数名
 *  @param filename 文件名（要有后缀名）
 *  @param mimeType 文件类型
 *  @param progress 上传进度
 *  @param success  成功回调
 *  @param fail     失败回调
 */
+ (void)mutableUploadWithURL:(NSString *)url
               params:(NSDictionary *)params
             fileData:(NSData *)filedata
                 name:(NSString *)name
             fileName:(NSString *)filename
             mimeType:(NSString *) mimeType
             progress:(YTFProgress)progress
              success:(YTFResponseSuccess)success
                 fail:(YTFResponseFail)fail;

/**
 *  含有跟路径的上传文件
 *
 *  @param url      请求网址路径
 *  @param baseurl  请求网址根路径
 *  @param params   请求参数
 *  @param filedata 文件
 *  @param name     指定参数名
 *  @param filename 文件名（要有后缀名）
 *  @param mimeType 文件类型
 *  @param progress 上传进度
 *  @param success  成功回调
 *  @param fail     失败回调
 */
+ (void)uploadWithURL:(NSString *)url
              baseURL:(NSString *)baseurl
               params:(NSDictionary *)params
             fileData:(NSData *)filedata
                 name:(NSString *)name
             fileName:(NSString *)filename
             mimeType:(NSString *) mimeType
             progress:(YTFProgress)progress
              success:(YTFResponseSuccess)success
                 fail:(YTFResponseFail)fail;

/**
 *  下载文件
 *
 *  @param url      请求网络路径
 *  @param fileURL  保存文件url
 *  @param progress 下载进度
 *  @param success  成功回调
 *  @param fail     失败回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，重新开启下载调用resume方法
 */
+ (NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                  savePathURL:(NSURL *)fileURL
                                     progress:(YTFProgress )progress
                                      success:(void (^)(NSURLResponse *response, NSURL *url,YTFAFHTTPSessionManager *manager))success
                                         fail:(void (^)(NSError *error,YTFAFHTTPSessionManager *manager))fail;

+ (YTFAFHTTPSessionManager *)sharedHTTPSession;

@end
