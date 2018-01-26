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

#import "NetworkManager.h"
#import "Definition.h"
#import "BaseWebView.h"
#import "AjaxSQLiteManager.h"
#import "TaskManager.h"
#import "SBJsonWriter.h"



@interface NetworkManager ()
{
    NSString *signName; // 普通网络请求标识，可以传递此字段给 cancelAjax 方法来取消请求
    NSString *downLoadSignName; // 下载请求标识，可以传递此字段给 cancelAjax 方法来取消请求
}
@property (nonatomic, copy) NSString *cbId;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSDictionary *nameFormsDic;//国际文件后缀名集合

@end

@implementation NetworkManager

#pragma mark - Ajax

/**
 *  JS Ajax 网络请求
 *
 *  @param webView JSContext webView
 */
- (void)ajaxHttpRequestWithWebView:(BaseWebView *)webView
{
    
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfajax"] = ^()
    {
        weakself.cbId = [[JSContext currentArguments][0] toDictionary][@"cbId"];
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        
        NSString *methodType = dicArgs[@"methodType"];
        NSString *cacheKey   = dicArgs[@"cacheKey"];
        NSString *timeOut    = dicArgs[@"timeout"];
        BOOL isReport   = dicArgs[@"isReport"] ? [dicArgs[@"isReport"] boolValue] : true;
        
        // 单例保存 Header 参数 以便在其他 类方法中能拿到数据
        NSMutableDictionary *dicHeaders = [NSMutableDictionary dictionary];
        if (dicArgs[@"headers"])
        {
            [dicHeaders setDictionary:dicArgs[@"headers"]];
        }
        [dicHeaders setObject:@"XMLHttpRequest" forKey:@"X-Requested-With"];
        [dicHeaders setValue:[[JSContext currentArguments][0] toDictionary][@"cbId"] forKey:@"cbId"];
        
        [[TaskManager shareManager] setHeader:dicHeaders];
        
        // 默认传递responseObject
        signName = dicArgs[@"signName"];
        NSString *url = [dicArgs[@"url"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if ([methodType isEqualToString:@"get"])
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                [NetworkManager GET:url
                             params:nil
                            success:^(NSURLSessionDataTask *task, id responseObject,YTFAFHTTPSessionManager *manager)
                {
                   // 获取Json字符串
                   NSString *stringJson = [ToolsFunction dictionaryToJsonString:responseObject];
                   
                   //将signName  与任务绑定
                   if (signName)
                   {
                       NSDictionary * taskDic = @{signName:task};
                       [[TaskManager shareManager] setTaskDicMethod:taskDic];
                   }
                   // 数据库缓存
                   if (cacheKey) {
                       [[AjaxSQLiteManager sharedManager] addJsonString:stringJson cacheKey:cacheKey];
                   }
                   //设置请求超时
                   manager.requestSerializer.timeoutInterval = [timeOut doubleValue];
                   
                    SBJsonWriter * jsWrite = [[SBJsonWriter alloc]init];
                    NSString * sbJsonString = [jsWrite stringWithObject:responseObject];
                    
                    if (sbJsonString.length != 0 && [manager.requestSerializer.HTTPRequestHeaders objectForKey:@"cbId"] != nil &&
                        [ToolsFunction transformStringToJSJsonWithJsonString:sbJsonString] != nil && weakwebView != nil)
                    {
                        
                        NSDictionary *dic = @{ @{@"cbId" :  [manager.requestSerializer.HTTPRequestHeaders objectForKey:@"cbId"],
                                                 @"stringJson" : [ToolsFunction transformStringToJSJsonWithJsonString:sbJsonString]} : weakwebView};
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakself performSelector:@selector(evaluateJavaScriptMethodWithJsonString:) withObject:dic afterDelay:NO];
                        });
                    }
                }
                               fail:^(NSURLSessionDataTask *task, NSError *error,YTFAFHTTPSessionManager *manager)
                {
                     NSDictionary *dicError = [NSDictionary dictionaryWithObject:error forKey:@"error"];
                     // 实现failure回调数据的传递
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [weakwebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@',null,'%@',false);",[manager.requestSerializer.HTTPRequestHeaders objectForKey:@"cbId"], dicError]];
                     });
               
                }];
          });
        } else {
            // post
            // 上传文件
            if (dicArgs[@"data"][@"files"] && ((NSDictionary *)dicArgs[@"data"][@"files"]).count > 0)
            {
                // FIXME: 下载热修复文件
                
                NSDictionary *dicParam = nil;
                
                if (dicArgs[@"data"][@"values"])
                {
                    dicParam = dicArgs[@"data"][@"values"];
                }
                
                // 上传文件数组
                NSArray *arrayFilePath = dicArgs[@"data"][@"files"][@"flieupload"];
                
                if (arrayFilePath != 0)
                {
                    for (int i = 0; i < arrayFilePath.count; i++)
                    {
                        NSData *data = [NSData dataWithContentsOfFile:arrayFilePath[i]];
                        
                  //  网络请求 所有都放在全局  回调放在 主线程
                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                      
                      [NetworkManager uploadWithURL:dicArgs[@"url"]
                                             params:dicParam
                                           fileData:data
                                               name:@"flieupload"
                                           fileName:[arrayFilePath[i] lastPathComponent]
                                           mimeType:[ToolsFunction mimeWithString:arrayFilePath[i]]
                                           progress:^(NSProgress *progress) {
  
                                               if (isReport)
                                               {
                                                   NSDictionary *dic = @{@"progress" : [NSString stringWithFormat:@"%f", progress.fractionCompleted * 100]};
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [weakwebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',null,false);", weakself.cbId, [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
                                                       });
                                               }
                                           }
                                            success:^(NSURLSessionDataTask *task, id responseObject,YTFAFHTTPSessionManager *manager) {
                                                
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    [weakwebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',null,false);",weakself.cbId,[[ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dictionaryToJsonString:responseObject]] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
                                                });
                                                
                                                
                                            }
                                               fail:^(NSURLSessionDataTask *task, NSError *error,YTFAFHTTPSessionManager *manager) {
                                                   
                                                   NSDictionary *dic = @{@"code" : [NSString stringWithFormat:@"%ld", (long)error.code],@"msg":error.domain};
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [weakwebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@',null,'%@',false);",[manager.requestSerializer.HTTPRequestHeaders objectForKey:@"cbId"],
                                                                                                        [[ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dictionaryToJsonString:dic]] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
                                                   });
                                                   
                                                   
                                               }];
                                        });
                        
                    }
                }
            } else {
               
                // 上传参数
                NSDictionary *dicParam = dicArgs[@"data"][@"values"];
            
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [NetworkManager POST:url params:dicParam success:^(NSURLSessionDataTask *task, id responseObject,YTFAFHTTPSessionManager *manager)
                 {
                     SBJsonWriter * jsWrite = [[SBJsonWriter alloc]init];
                     NSString * sbJsonString = [jsWrite stringWithObject:responseObject];

                     if (sbJsonString.length != 0 && [manager.requestSerializer.HTTPRequestHeaders objectForKey:@"cbId"] != nil &&
                         [ToolsFunction transformStringToJSJsonWithJsonString:sbJsonString] != nil && weakwebView != nil)
                     {
                         
                     NSDictionary *dic = @{ @{@"cbId" :  [manager.requestSerializer.HTTPRequestHeaders objectForKey:@"cbId"],
                                           @"stringJson" : [ToolsFunction transformStringToJSJsonWithJsonString:sbJsonString]} : weakwebView};
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself performSelector:@selector(evaluateJavaScriptMethodWithJsonString:) withObject:dic afterDelay:NO];
            });
                         
        }
                     
                 } fail:^(NSURLSessionDataTask *task, NSError *error,YTFAFHTTPSessionManager *manager) {
                     NSDictionary *dic = @{@"code" : [NSString stringWithFormat:@"%ld", (long)error.code],@"msg":error.domain};
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                     [weakwebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@',null,'%@',false);",[manager.requestSerializer.HTTPRequestHeaders objectForKey:@"cbId"],[[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
                         
                        });
                 }];
               });
            }
        }
    };
}




/**
 *  JS Ajax 下载文件
 *
 *  @param webView JSContext
 */
- (void)ajaxDownloadFilesWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [weakwebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfAjaxDownload"] = ^() {
    
        /*
         {
         args =     {
         methodType = get;
         saveFileName = "master.zip";
         signName = testAjaxDownLoad;
         saveFilePath = ;
         url = "https://codeload.github.com/hongyangAndroid/okhttp-utils/zip/master";
         };
         cbId = download1;
         }
         */
        weakself.cbId = [ToolsFunction JSContextCBID];
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];;
        
       __block  NSString *downloadUrl = dicArgs[@"url"];
        downLoadSignName = dicArgs[@"signName"];
        NSString *methodType = dicArgs[@"methodType"];
        BOOL isReport   = dicArgs[@"isReport"] ? [dicArgs[@"isReport"] boolValue] : true;
        #pragma unused(methodType)
       __block  NSString *saveFileName = dicArgs[@"saveFileName"];
        
        __block  NSString *saveFilePath = nil;
        if (dicArgs[@"saveFilePath"])
        {
            BOOL isCreate = [ToolsFunction createDirectoryWithPath:[dicArgs[@"saveFilePath"] stringByDeletingLastPathComponent]];
            if (isCreate)
            {
                saveFilePath = dicArgs[@"saveFilePath"];
            }
        }
        //  单例保存每次的下载任务
        NSMutableDictionary *cbIdDownLoadTask = [NSMutableDictionary dictionary];
        
        [cbIdDownLoadTask setValue:[[JSContext currentArguments][0] toDictionary][@"cbId"] forKey:@"cbId"];
        [cbIdDownLoadTask setObject:@"XMLHttpRequest" forKey:@"X-Requested-With"];
        [[TaskManager shareManager] setdownLoadCbIdTask:cbIdDownLoadTask];
        

        YTFAFHTTPSessionManager *manager =[NetworkManager sharedHTTPSession];
        
        for (int index = 0 ; index < [[TaskManager shareManager].downLoadCbIdTask allKeys].count ; index ++) {
            [manager.requestSerializer setValue:[[TaskManager shareManager].downLoadCbIdTask allValues][index] forHTTPHeaderField:[[TaskManager shareManager].downLoadCbIdTask allKeys][index]];
        }
        
        NSURL *url = [NSURL URLWithString:downloadUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        __block int64_t  totalUnitCount = 0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakself.downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                
               totalUnitCount = downloadProgress.totalUnitCount;
                //将 downLoadSignName  与任务绑定
                if (downLoadSignName)
                {
                    NSDictionary * downLoadTaskDic = @{downLoadSignName:weakself.downloadTask};
                    [[TaskManager shareManager] setdownLoadTaskDicMethod:downLoadTaskDic];
                }
                
                if (isReport)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *dic = @{@"progress" : [NSString stringWithFormat:@"%d", (int)(downloadProgress.fractionCompleted * 100)]};
                        [weakwebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',null,false);",weakself.cbId,[[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
                    });
                }
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                if (!saveFileName) {
                    saveFileName = [NSString stringWithFormat:@"%@%@",downloadUrl,[NSNumber numberWithLongLong:totalUnitCount]];
                    saveFileName = [ToolsFunction getmd5WithString:saveFileName];
                }
                NSString *responMIMEType = [weakself convertSuffixName:[NSString stringWithFormat:@"%@",response.MIMEType]];
                saveFileName = [NSString stringWithFormat:@"%@%@",saveFileName,responMIMEType];
                
                saveFilePath = [NSString stringWithFormat:@"%@/download/%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject,saveFileName];
                [ToolsFunction createDirectoryWithPath:[saveFilePath stringByDeletingLastPathComponent]];
                
                return [NSURL fileURLWithPath:saveFilePath];///var/mobile/Containers/Data/Application/BCA0D85D-10F2-4F6E-AEE7-E7F8ABA3E6AB/Documents/download/master.zip

                
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                if (error)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSDictionary *dic = @{@"code" : [NSString stringWithFormat:@"%ld", (long)error.code],@"msg":error.domain};
                            [weakwebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@',null,'%@',false);",weakself.cbId,[[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
                            
                        });
                        
                    } else {
                        NSDictionary *dic = @{@"filePath" : saveFilePath,
                                              @"progress" : @"100"};
                        
                        SBJsonWriter * jsWrite = [[SBJsonWriter alloc]init];
                        NSString * sbJsonString = [jsWrite stringWithObject:dic];
                        
                        NSDictionary *dicEvalue = @{ @{@"cbId" :  [manager.requestSerializer.HTTPRequestHeaders objectForKey:@"cbId"],
                                                       @"stringJson" : [ToolsFunction transformStringToJSJsonWithJsonString:sbJsonString]} : weakwebView};
                        
                        [weakself performSelectorOnMainThread:@selector(evaluateJavaScriptMethodWithJsonString:) withObject:dicEvalue waitUntilDone:NO];
                    }
            }];
            // 3.执行Task
            [weakself.downloadTask resume];
            
        });
        
     };
}

/**
 *  JS Ajax 取消下载
 *
 *  @param webView JSContet
 */
- (void)ajaxCancelDownloadWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"CancelDownload"] = ^() {
    
        weakself.cbId = [[JSContext currentArguments][0] toDictionary][@"cbId"];
        [weakself.downloadTask cancel];
    };
}

#pragma mark - Custom Method

- (void)evaluateJavaScriptMethodWithJsonString:(NSDictionary *)dicEvaluate
{
    [((BaseWebView *)[dicEvaluate allValues].firstObject) stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',null,false);", [dicEvaluate allKeys].firstObject[@"cbId"], [[dicEvaluate allKeys].firstObject[@"stringJson"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
}

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
       fail:(YTFResponseFail)fail
{
    YTFAFHTTPSessionManager *manager = [NetworkManager managerWithBaseURL:nil sessionConfiguration:NO];
    
    
    for (int index = 0 ; index < [[TaskManager shareManager].headerDictionary allKeys].count ; index ++) {
    
        [manager.requestSerializer setValue:[[TaskManager shareManager].headerDictionary allValues][index] forHTTPHeaderField:[[TaskManager shareManager].headerDictionary allKeys][index]];
    }
    
      [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [NetworkManager responseConfiguration:responseObject];
      
        success(task,dic,manager);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error,manager);
    }];
    
    
    
}

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
       fail:(YTFResponseFail)fail
{
    YTFAFHTTPSessionManager *manager = [NetworkManager managerWithBaseURL:baseUrl sessionConfiguration:NO];
    [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        id dic = [NetworkManager responseConfiguration:responseObject];
        
        success(task,dic,manager);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error,manager);
    }];
}

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
        fail:(YTFResponseFail)fail
{
    YTFAFHTTPSessionManager *manager = [NetworkManager managerWithBaseURL:nil sessionConfiguration:NO];
    
 

    for (int index = 0 ; index < [[TaskManager shareManager].headerDictionary allKeys].count ; index ++) {
        
        [manager.requestSerializer setValue:[[TaskManager shareManager].headerDictionary allValues][index] forHTTPHeaderField:[[TaskManager shareManager].headerDictionary allKeys][index]];
    }
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [NetworkManager responseConfiguration:responseObject];
        success(task,dic,manager);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error,manager);
    }];
}

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
        fail:(YTFResponseFail)fail
{
    YTFAFHTTPSessionManager *manager = [NetworkManager managerWithBaseURL:baseUrl sessionConfiguration:NO];
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [NetworkManager responseConfiguration:responseObject];
        
        success(task,dic,manager);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error,manager);
    }];
}

/**
 *  普通路径上传文件
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
                 fail:(YTFResponseFail)fail
{
    
    YTFAFHTTPSessionManager *manager = [NetworkManager managerWithBaseURL:nil sessionConfiguration:NO];
    
       for (int index = 0 ; index < [[TaskManager shareManager].headerDictionary allKeys].count ; index ++) {
        
        [manager.requestSerializer setValue:[[TaskManager shareManager].headerDictionary allValues][index] forHTTPHeaderField:[[TaskManager shareManager].headerDictionary allKeys][index]];
    }
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<YTFAFMultipartFormData>  _Nonnull formData) {

        [formData appendPartWithFileData:filedata name:name fileName:filename mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [NetworkManager responseConfiguration:responseObject];
        success(task,dic,manager);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error,manager);
    }];
}



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
                        fail:(YTFResponseFail)fail{




}

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
                fail:(YTFResponseFail)fail
{
    YTFAFHTTPSessionManager *manager = [NetworkManager managerWithBaseURL:baseurl sessionConfiguration:YES];
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<YTFAFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:filedata name:name fileName:filename mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id dic = [NetworkManager responseConfiguration:responseObject];
        
        success(task,dic,manager);
        
        
        success(task,responseObject,manager);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(task,error,manager);
    }];
}

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
                                        fail:(void (^)(NSError *error,YTFAFHTTPSessionManager *manager))fail
{
    YTFAFHTTPSessionManager *manager = [self managerWithBaseURL:nil sessionConfiguration:YES];
    
    for (int index = 0 ; index < [[TaskManager shareManager].downLoadCbIdTask allKeys].count ; index ++) {
        [manager.requestSerializer setValue:[[TaskManager shareManager].downLoadCbIdTask allValues][index] forHTTPHeaderField:[[TaskManager shareManager].downLoadCbIdTask allKeys][index]];
    }
    
    NSURL *urlpath = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlpath];
    
    NSURLSessionDownloadTask *downloadtask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [fileURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error) {
            fail(error,manager);
        }else{
            
           success(response,filePath,manager);
        }
    }];
    
    [downloadtask resume];
    
    return downloadtask;
}

#pragma mark - Private

/**
 *  初始化请求管理类
 *
 *  @param baseURL         请求url
 *  @param isconfiguration
 *
 *  @return 请求管理类
 */
+ (YTFAFHTTPSessionManager *)managerWithBaseURL:(NSString *)baseURL
                        sessionConfiguration:(BOOL)isconfiguration
{
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    YTFAFHTTPSessionManager *manager = [NetworkManager sharedHTTPSession];
    
//    NSURL *url = [NSURL URLWithString:baseURL];
//    
//    if (isconfiguration)
//    {
//        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:configuration];
//    }else{
//        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
//    }
//    
    manager.requestSerializer  = [YTFAFHTTPRequestSerializer serializer];
    manager.responseSerializer = [YTFAFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/html", nil];
    
    return manager;
}

static YTFAFHTTPSessionManager *manager ;
static YTFAFURLSessionManager *urlsession ;

+ (YTFAFHTTPSessionManager *)sharedHTTPSession
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [YTFAFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 10;
    });
    return manager;
}

+ (YTFAFURLSessionManager *)sharedURLSession
{
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        urlsession = [[YTFAFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return urlsession;
}

/**
 *  Json转字典
 *
 *  @param responseObject 请求返回Json数据
 *
 *  @return 字典
 */
+ (id)responseConfiguration:(id)responseObject
{
    NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
    if (string == nil)
    {
        return nil;
    }
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //  dic 原来是字典
    id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    return dic;
}

#pragma mark - Custom Method


/**
 将下载到的文件的后缀名做转换

 @param suffixOld 文件原始后缀名
 @return 国际通用后缀名
 */
- (NSString *)convertSuffixName:(NSString *)suffixOld
{
    //在此设置要改的变量
    __block NSString *suffixNew = @"";
    [self.nameFormsDic enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if ([suffixOld isEqualToString:[NSString stringWithFormat:@"%@",value]])
        {
            suffixNew = [NSString stringWithFormat:@"%@",key];
            *stop = YES;
        }
    }];
    return suffixNew;
}


/**
 getter

 @return 获取文件后缀名的键值对
 */
- (NSDictionary *)nameFormsDic{
    if (!_nameFormsDic) {
        _nameFormsDic = [ToolsFunction fileSuffixReName];
    }

    return _nameFormsDic;
}




@end
