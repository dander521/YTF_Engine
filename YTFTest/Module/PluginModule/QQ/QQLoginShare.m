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

#import "QQLoginShare.h"
#import "ToolsFunction.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "QQApiInterfaceObject.h"
#import "QQApiInterface.h"
#import "AppDelegate.h"

@interface QQLoginShare ()

{
    NSString * loginCbid;// 登陆 cbid
    id loginWebView;//登陆执行的webView回调环境
    NSString *  shareCbid;// 分享的CbID;
    
    NSString * shareType;//分享的类型  文本 音频 视频 图片
    NSString * shareTitle;//  分享简介
    NSString * descriotion;
    BOOL shareToFriend;//是否是分享到朋友  否则是分享到qq空间
    
    NSString *  imagePath;//图片分享的本地路径
    NSString *  newsUrl;
    NSString *  newsImageUrl;//新闻的预览图片
    
    NSString *  musicUrl;
    NSString *  musicImageUrl;//音乐的预览图片
    NSString *  musicFlashUrl;//音乐的UrL
    
    
    NSString *  videoImagePatch;//视频的预览图片
    NSString *  videoUrl;
    NSString * getUserInfoCbid;
    
    TencentOAuth *tencentOAuth;
    NSArray *  permissions;
    
    NSString * logoutCbid;
}

@end

@implementation QQLoginShare


/**
 *  判断用户是否安装 QQ
 */
- (NSNumber *)isInstalled:(NSDictionary *)paramsDictionary{

    NSNumber * retenNum;
    BOOL qqIsInstalled      = [TencentOAuth iphoneQQInstalled];
    if (qqIsInstalled) {
        retenNum = [NSNumber numberWithInt:1];
    }else{
        retenNum = [NSNumber numberWithInt:0];
    }
    
  
    
    return retenNum;
}


/**
 代理方法的空实现

 @param response
 */
- (void)isOnlineResponse:(NSDictionary *)response{

}



- (void)dealloc{
    
 // [[NSNotificationCenter defaultCenter]postNotificationName:NotificationWhenModuleDealloc object:nil];
}

/**
 *  每个分享方法的公共参数解析/////
 *
 *  @param args
 */
- (void)commonParamInit:(NSDictionary *)args{

    shareCbid                    =  args[@"cbId"];
    if (shareCbid.length == 0) {       
         shareTitle  =  args[@"text"];
        
    }else{
        self.shareWebView            =  args[@"target"];
        NSDictionary * shareInfoDic  =  args[@"args"];
        shareTitle                   =  shareInfoDic[@"text"];
        shareToFriend                =  shareInfoDic[@"shareToFriend"];

    
    }
    
    // 设置代理对象
    [[AppDelegate shareAppDelegate] addAppDelegateHandle:self];
    NSString * appId = [AppDelegate getExtendWithPluginName:@"qq"][@"app_id"];
    tencentOAuth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
}


/**
 *  QQ 登陆
 *
 *  @param args JS传入的参数
 */
- (void)login:(NSDictionary *)args{
    
    NSString * appId = [AppDelegate getExtendWithPluginName:@"qq"][@"app_id"];
    // 参数解析
    loginCbid = args[@"cbId"];
    loginWebView  = args[@"target"];
    // 设置代理对象
    [[AppDelegate shareAppDelegate] addAppDelegateHandle:self];
    // 登陆实现
    tencentOAuth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
    tencentOAuth.sessionDelegate = self;
    tencentOAuth.redirectURI = @"www.qq.com";
     permissions = [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo", @"add_t", nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
          [tencentOAuth authorize:permissions inSafari:NO];
    });
    
  
}

/**
 *  退出 登陆
 *
 *  @param args JS传入的参数
 */
- (void)logout:(NSDictionary *)args{


    logoutCbid = args[@"cbId"];
    loginWebView  =args[@"target"];
    [tencentOAuth logout:self];
    BOOL isLogin = [tencentOAuth isSessionValid];
    
    NSDictionary *dic;
    if (isLogin) {
        // 注销失败 登陆状态中
        dic = @{@"status" :@0};
    }else{
        // 注销成功
        dic = @{@"status" :@1};
    }
    NSString * testString = [ToolsFunction dicToJavaScriptString:dic];
    
    
    [self performSelectorOnMainThread:@selector(loginOutCallBack:) withObject:testString waitUntilDone:NO];
    
}


/**
 *  获取用户信息
 *
 *  @param args JS传入的参数
 */
- (BOOL)getUserInfo:(NSDictionary *)args{
    
    getUserInfoCbid = args[@"cbId"];
    loginWebView  =args[@"target"];
    BOOL  asdasd = [tencentOAuth getUserInfo];//这个方法返回BOOL
    return asdasd;
}

/**
 * 退出登录的回调
 */
- (void)tencentDidLogout{

}

/**
 *  纯文本 分享
 */
- (void)shareText:(NSDictionary *)args{
    [self commonParamInit:args];
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:shareTitle];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        //将内容分享到qq
    dispatch_async(dispatch_get_main_queue(), ^{
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
    });
}

/**
 *  分享纯图片消息
 */
- (void)shareImage:(NSDictionary *)args{
    [self commonParamInit:args];
    NSString * path = args[@"args"][@"imageUrl"];
    NSData *imgData = [NSData dataWithContentsOfFile:path];
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData
                                               previewImageData:imgData
                                                          title:shareTitle
                                                    description:nil];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
    //将内容分享到qq
    dispatch_async(dispatch_get_main_queue(), ^{
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
    });
}

/**
 *  分享新闻
 */
- (void)shareWebPage:(NSDictionary *)args{
    [self commonParamInit:args];
    NSDictionary * shareInfoDic  =  args[@"args"];
    newsUrl                      =  shareInfoDic[@"targetUrl"];
    newsImageUrl                 =  shareInfoDic[@"imageUrl"];
    NSString *newSUrl = newsUrl;
    NSString *title   =  shareInfoDic[@"title"];
    NSString *desc    =  shareInfoDic[@"summary"];
    NSString *previewImageUrl = newsImageUrl;
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:newSUrl]
                                title:title
                                description:desc
                                previewImageURL:[NSURL URLWithString:previewImageUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    if (shareToFriend==YES) {
        //  分享给好友
        dispatch_async(dispatch_get_main_queue(), ^{
             QQApiSendResultCode sent;
             sent = [QQApiInterface sendReq:req];
             [self handleSendResult:sent];
        });
   }else{
       dispatch_async(dispatch_get_main_queue(), ^{
        QQApiSendResultCode sent;
        //  将被容分享到qzone
        sent = [QQApiInterface SendReqToQZone:req];
        [self handleSendResult:sent];
           
      });
   }
}


/**
 *  分享音乐
 */
- (void)shareMusic:(NSDictionary *)args{

    [self commonParamInit:args];
    
    NSDictionary * shareInfoDic  =  args[@"args"];
    musicUrl                     =  shareInfoDic[@"targetUrl"];
    musicImageUrl                =  shareInfoDic[@"imageUrl"];
    NSString * audioURL          =  shareInfoDic[@"audioUrl"];
    
    NSString *utf8String = musicUrl;
    NSString *title =   shareInfoDic[@"title"];
    NSString *desc  = shareInfoDic[@"summary"];
    NSString *previewImageUrl = musicImageUrl;
    QQApiAudioObject *audioObj =
    [QQApiAudioObject objectWithURL:[NSURL URLWithString:utf8String]
                              title:title
                        description:desc
                    previewImageURL:[NSURL URLWithString:previewImageUrl]];
    audioObj.flashURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",audioURL]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];

    if (shareToFriend == YES) {
        //  分享给好友
        dispatch_async(dispatch_get_main_queue(), ^{
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        });
        
        
    }else if(shareToFriend == NO){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //  将被容分享到qzone
            QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
            [self handleSendResult:sent];
        });
        
    }
     
}


/**
 *  分享视频
 */
- (void)shareVideo:(NSDictionary *)args{

    
    [self commonParamInit:args];
    
    shareCbid                    =  args[@"cbId"];
    self.shareWebView            =  args[@"target"];
    NSDictionary * shareInfoDic  =  args[@"args"];
    shareTitle                   =  shareInfoDic[@"title"];
    shareToFriend                =  shareInfoDic[@"shareToFriend"];
    NSString * summary           =  shareInfoDic[@"summary"];

    videoImagePatch             =  shareInfoDic[@"imageUrl"];
    videoUrl                    =  shareInfoDic[@"targetUrl"];

    NSData* previewData = [NSData dataWithContentsOfFile:videoImagePatch];
    NSString *utf8String = videoUrl;
    QQApiVideoObject *videoObj = [QQApiVideoObject objectWithURL:[NSURL URLWithString:utf8String ? : @""]
                                                           title:shareTitle
                                                     description:summary
                                                previewImageData:previewData];
    [videoObj setFlashURL:[NSURL URLWithString:videoUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:videoObj];
    
    
  //  QQApiSendResultCode sent;
    if (shareToFriend==YES) {
        //  分享给好友
        dispatch_async(dispatch_get_main_queue(), ^{
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        });
        
    }else{
        
        //  将被容分享到qzone
        dispatch_async(dispatch_get_main_queue(), ^{
            QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
            [self handleSendResult:sent];
        });
        
    }
    

}

#pragma mark -- ytfDelegate
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{

    return  [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{

   return  [TencentOAuth HandleOpenURL:url];

}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
   
    return  [TencentOAuth HandleOpenURL:url];
}

#pragma mark -- QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req{

}

- (void)onResp:(QQBaseReq *)resp {
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            if ([sendResp.result isEqualToString:@"0"]) {
                
                NSDictionary *dic = @{@"status" :@1};
                NSString * testString = [ToolsFunction dicToJavaScriptString:dic];
                
                 [self performSelectorOnMainThread:@selector(qqShareCallBack:) withObject:testString waitUntilDone:NO];
                
                
            }
            else {
                
                NSDictionary *dic = @{@"status" :@0};
                NSString * testString = [ToolsFunction dicToJavaScriptString:dic];
                [self performSelectorOnMainThread:@selector(qqShareCallBack:) withObject:testString waitUntilDone:NO];

            }
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)qqShareCallBack:(NSString *)testString{
    
   [self.shareWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",shareCbid,testString]];

}

#pragma mark -- QQLoginDelegate
- (void)tencentDidLogin{
   // 登陆成功 将所有信息回调给JS
    NSString * testString;
    if (tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length])
    {
        NSDictionary *dic = @{@"登陆状态" : @"登陆成功"};
        testString = [ToolsFunction dicToJavaScriptString:dic];
    }
    else
    {
     //   NSLog(@"登陆不成功 没有获取accessToken");
        NSDictionary *dic = @{@"登陆状态" : @"登陆失败"};
        testString = [ToolsFunction dicToJavaScriptString:dic];
    }
    [self performSelectorOnMainThread:@selector(loginCallBack:) withObject:testString waitUntilDone:NO];
}
- (void)tencentDidNotLogin:(BOOL)cancelled{
    NSDictionary *dic = @{@"登陆状态" : @"登陆失败"};
    NSString *  testString = [ToolsFunction dicToJavaScriptString:dic];
    [self performSelectorOnMainThread:@selector(loginCallBack:) withObject:testString waitUntilDone:NO];
}
- (void)tencentDidNotNetWork{
    NSDictionary *dic = @{@"登陆失败" : @"无网络"};
    NSString *  testString = [ToolsFunction dicToJavaScriptString:dic];
    [self performSelectorOnMainThread:@selector(loginCallBack:) withObject:testString waitUntilDone:NO];
}
- (void)getUserInfoResponse:(APIResponse*) response{
   //判空处理
    if (response.jsonResponse) {

        NSString * testString = [ToolsFunction dicToJavaScriptString:response.jsonResponse];        
        [self performSelectorOnMainThread:@selector(jsGetInfoCallBack:) withObject:testString waitUntilDone:NO];
    }
}
// QQ Share
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    
    NSString * testString;
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            NSDictionary *dic = @{@"status" :@0,@"msg":@"App未注册"};
            testString = [ToolsFunction dicToJavaScriptString:dic];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            NSDictionary *dic = @{@"status" :@0,@"msg":@"发送参数错误"};
           testString = [ToolsFunction dicToJavaScriptString:dic];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            NSDictionary *dic = @{@"status" :@0,@"msg":@"未安装手Q"};
           testString = [ToolsFunction dicToJavaScriptString:dic];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            NSDictionary *dic = @{@"status" :@0};
            testString = [ToolsFunction dicToJavaScriptString:dic];
            break;
        }
        case EQQAPISENDFAILD:
        {
            NSDictionary *dic = @{@"status":@0,@"msg":@"发送失败"};
            testString = [ToolsFunction dicToJavaScriptString:dic];
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE:
        {
            NSDictionary *dic = @{@"status" :@0,@"msg":@"当前QQ版本太低，需要更新"};
             testString = [ToolsFunction dicToJavaScriptString:dic];
            break;
        }
        default:
        {
            break;
        }
    }
       [self performSelectorOnMainThread:@selector(handleSendResultPerform:) withObject:testString waitUntilDone:NO];

}

/**
 *  获取用户信息的回调
 *
 *  @param testString 要回调的 字符串内容
 */
- (void)jsGetInfoCallBack:(NSString *)testString{

    [loginWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",getUserInfoCbid,testString]];

}

/**
 *  调用分享失败
 *
 *  @param testString 要回调的 字符串内容
 */
- (void)handleSendResultPerform:(NSString *)testString{

   [self.shareWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",shareCbid,testString]];

}

/**
 *  登陆回调
 *
 *  @param testString 要回调的 字符串内容
 */
- (void)loginCallBack:(NSString *)testString{

    [loginWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",loginCbid,testString]];
}

- (void)loginOutCallBack:(NSString *)testString{

    [loginWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",logoutCbid,testString]];
}

@end
