/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFWeiboModule Plugin.
 * =============================================================================
 */


#import "YTFWeiboModule.h"
#import "WeiboSDK.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "PathProtocolManager.h"
#import "BaseViewController.h"
#import "WBHttpRequest.h"

#define MediaTypeVideo      @"video"
#define MediaTypeWebPage    @"webpage"
#define MediaTypeMusic      @"music"
#define MediaTypeVoice      @"voice"

@interface YTFWeiboModule ()<WeiboSDKDelegate, WBHttpRequestDelegate>

@property (strong, nonatomic) NSString *wbtoken; // 微博token
@property (strong, nonatomic) NSString *wbRefreshToken; // 更新token
@property (strong, nonatomic) NSString *wbCurrentUserID; // 用户id

@end

@implementation YTFWeiboModule

+ (instancetype)shareInstance
{
    static YTFWeiboModule *weiboModule = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weiboModule = [[self alloc] init];
    });
    
    return weiboModule;
}

/**
 *  是否安装微博
 *
 *  @param paramsDictionary JS参数字典
 */
- (NSNumber *)isInstalled:(NSDictionary *)paramsDictionary
{
    NSNumber *result = nil;
    
    if ([WeiboSDK isWeiboAppInstalled])
    {
        result = [NSNumber numberWithInt:1];
    } else {
        result = [NSNumber numberWithInt:0];
    }
    
    return result;
}


/**
 *  微博授权
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)auth:(NSDictionary *)paramsDictionary
{
    /*
     {
     args =     {
     "app_key" = 759951650;
     "redirect_url" = "http://www.yuantuan.com";
     scope = "email,direct_messages_read,direct_messages_write,friendships_groups_read,friendships_groups_write,statuses_to_me_read,follow_app_official_microblog,invitation_write";
     };
     cbId = auth2;
     target = "<BaseWebView: 0x7fadd388d1e0; baseClass = UIWebView; frame = (0 38; 375 609); layer = <CALayer: 0x7fadd38f33b0>>";
     }
     */
    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    [[AppDelegate shareAppDelegate] addAppDelegateHandle:self];

    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = [AppDelegate getExtendWithPluginName:@"weibo"][@"redirect_url"];
    request.scope = [AppDelegate getExtendWithPluginName:@"weibo"][@"scope"];
    
    [WeiboSDK sendRequest:request];
}

/**
 *  微博取消授权
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)cancelAuth:(NSDictionary *)paramsDictionary
{
    /*
     {
     cbId = cancelAuth2;
     target = "<BaseWebView: 0x7fe50a7b72b0; baseClass = UIWebView; frame = (0 38; 375 609); layer = <CALayer: 0x7fe50a7b9820>>";
     }
     */
    [WeiboSDK logOutWithToken:self.wbtoken delegate:self withTag:@"user1"];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSDictionary *dicBack = @{@"status" : @0,
                              @"msg" : @"取消授权"};
    NSString *stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
    [self performSelectorOnMainThread:@selector(mainThreadOperateWithParamsString:) withObject:stringBack waitUntilDone:NO];
}

/**
 获取用户信息
 
 @param paramsDictionary JS参数字典
 */
- (void)getUserInfo:(NSDictionary *)paramsDictionary
{
    /*
     {
     {
     args =     {
     "uid" = 759951650;
     "access_token" = "sfdsf56464";
     };
     cbId = cancelAuth2;
     target = "<BaseWebView: 0x7fe50a7b72b0; baseClass = UIWebView; frame = (0 38; 375 609); layer = <CALayer: 0x7fe50a7b9820>>";
     }
     */
    
    if (!paramsDictionary ||
        !paramsDictionary[@"args"][@"uid"] ||
        !paramsDictionary[@"args"][@"access_token"]) {
        return;
    }

    NSString *urlStr=[NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?uid=%@&access_token=%@",paramsDictionary[@"args"][@"uid"], paramsDictionary[@"args"][@"access_token"]];
    
    NSURL *url = [NSURL URLWithString:urlStr];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    [request setHTTPMethod:@"GET"];

    NSURLResponse *response = nil;

    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];

    NSDictionary *dicBack = nil;
    if (data == nil)
    {
        dicBack = @{@"status" : [NSNumber numberWithInt:0],
                    @"msg" : @"获取失败"};
    } else {
        dicBack = @{@"status" : [NSNumber numberWithInt:1],
                    @"userInfo" : [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]};
    }
 
    NSString *stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
    [self performSelectorOnMainThread:@selector(mainThreadOperateWithParamsString:) withObject:stringBack waitUntilDone:NO];
}

/**
 *  分享文字
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareText:(NSDictionary *)paramsDictionary
{
    /*
     {
     args =     {
     "app_key" = 759951650;
     "redirect_url" = "http://www.yuantuan.com";
     scope = "email,direct_messages_read,direct_messages_write,friendships_groups_read,friendships_groups_write,statuses_to_me_read,follow_app_official_microblog,invitation_write";
     supportType = 2;
     text = "\U6587\U672c\U5206\U4eab";
     };
     cbId = shareText1;
     target = "<BaseWebView: 0x7fa19b4f02d0; baseClass = UIWebView; frame = (0 38; 375 609); layer = <CALayer: 0x7fa19b4f7740>>";
     }
     */
    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = paramsDictionary[@"args"][@"text"];

    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = [AppDelegate getExtendWithPluginName:@"weibo"][@"redirect_url"];
    authRequest.scope = [AppDelegate getExtendWithPluginName:@"weibo"][@"scope"];
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbtoken];
    
    [WeiboSDK sendRequest:request];
}

/**
 *  分享图片
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareImage:(NSDictionary *)paramsDictionary
{
    /*
     {
     args =     {
     imageUrl = "/storage/emulated/0/YtfMap/widget/images/1.png";
     supportType = 2;
     text = "\U56fe\U7247\U5206\U4eab\U5206\U4eab";
     };
     cbId = shareImage2;
     target = "<BaseWebView: 0x7fa19b4f02d0; baseClass = UIWebView; frame = (0 38; 375 609); layer = <CALayer: 0x7fa19b4f7740>>";
     }
     */
    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    
    WBMessageObject *message = [WBMessageObject message];
    
    if (paramsDictionary[@"args"][@"text"])
    {
        message.text = paramsDictionary[@"args"][@"text"];
    }
    
    WBImageObject *image = [WBImageObject object];
    
    image.imageData = [NSData dataWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imageUrl"]]];
    message.imageObject = image;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = [AppDelegate getExtendWithPluginName:@"weibo"][@"redirect_url"];
    authRequest.scope = [AppDelegate getExtendWithPluginName:@"weibo"][@"scope"];
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbtoken];

    [WeiboSDK sendRequest:request];
}

/**
 分享多媒体
 
 @param paramsDictionary  JS参数字典
 */
- (void)share:(NSDictionary *)paramsDictionary
{
    if (paramsDictionary[@"args"][@"shareType"] == nil)
    {
        return;
    }
    
    if ([paramsDictionary[@"args"][@"shareType"] isEqualToString:MediaTypeVideo])
    {
        [self shareVideo:paramsDictionary];
    } else if ([paramsDictionary[@"args"][@"shareType"] isEqualToString:MediaTypeVoice])
    {
        [self shareVoice:paramsDictionary];
    } else if ([paramsDictionary[@"args"][@"shareType"] isEqualToString:MediaTypeMusic])
    {
        [self shareMusic:paramsDictionary];
    } else if ([paramsDictionary[@"args"][@"shareType"] isEqualToString:MediaTypeWebPage])
    {
        [self shareWeb:paramsDictionary];
    }
}

/**
 *  分享视频
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareVideo:(NSDictionary *)paramsDictionary
{
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    
    WBMessageObject *message = [WBMessageObject message];
    
    if (paramsDictionary[@"args"][@"text"])
    {
        message.text = paramsDictionary[@"args"][@"text"];
    }
    
    WBVideoObject *vedio = [WBVideoObject object];
    
    vedio.objectID = @"vedio";
    vedio.title = paramsDictionary[@"args"][@"title"];
    vedio.description = paramsDictionary[@"args"][@"description"];
    vedio.thumbnailData = [NSData dataWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imageUrl"]]];
    vedio.videoUrl = paramsDictionary[@"args"][@"shareUrl"];
    message.mediaObject = vedio;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = [AppDelegate getExtendWithPluginName:@"weibo"][@"redirect_url"];
    authRequest.scope = [AppDelegate getExtendWithPluginName:@"weibo"][@"scope"];
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbtoken];
    [WeiboSDK sendRequest:request];
}

/**
 *  分享音乐
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareMusic:(NSDictionary *)paramsDictionary
{
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    
    WBMessageObject *message = [WBMessageObject message];
    
    if (paramsDictionary[@"args"][@"text"])
    {
        message.text = paramsDictionary[@"args"][@"text"];
    }
    
    WBMusicObject *music = [WBMusicObject object];
    
    music.objectID = @"music";
    music.title = paramsDictionary[@"args"][@"title"];
    music.description = paramsDictionary[@"args"][@"description"];
    music.thumbnailData = [NSData dataWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imageUrl"]]];
    music.musicUrl = paramsDictionary[@"args"][@"shareUrl"];
    message.mediaObject = music;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = [AppDelegate getExtendWithPluginName:@"weibo"][@"redirect_url"];
    authRequest.scope = [AppDelegate getExtendWithPluginName:@"weibo"][@"scope"];
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbtoken];
    
    [WeiboSDK sendRequest:request];
}

/**
 *  分享网页
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareWeb:(NSDictionary *)paramsDictionary
{
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    
    WBMessageObject *message = [WBMessageObject message];
    
    if (paramsDictionary[@"args"][@"text"])
    {
        message.text = paramsDictionary[@"args"][@"text"];
    }
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    
    webpage.objectID = @"webpage";
    webpage.title = paramsDictionary[@"args"][@"title"];
    webpage.description = paramsDictionary[@"args"][@"description"];
    webpage.thumbnailData = [NSData dataWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imageUrl"]]];
    webpage.webpageUrl = paramsDictionary[@"args"][@"shareUrl"];
    message.mediaObject = webpage;

    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = [AppDelegate getExtendWithPluginName:@"weibo"][@"redirect_url"];
    authRequest.scope = [AppDelegate getExtendWithPluginName:@"weibo"][@"scope"];
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbtoken];
    
    [WeiboSDK sendRequest:request];
}

/**
 *  分享声音
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareVoice:(NSDictionary *)paramsDictionary
{
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    
    WBMessageObject *message = [WBMessageObject message];
    
    if (paramsDictionary[@"args"][@"text"])
    {
        message.text = paramsDictionary[@"args"][@"text"];
    }
    
    WBMusicObject *voice = [WBMusicObject object];
    
    voice.objectID = @"voice";
    voice.title = paramsDictionary[@"args"][@"title"];
    voice.description = paramsDictionary[@"args"][@"description"];
    voice.thumbnailData = [NSData dataWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imageUrl"]]];
    voice.musicUrl = paramsDictionary[@"args"][@"shareUrl"];
    message.mediaObject = voice;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = [AppDelegate getExtendWithPluginName:@"weibo"][@"redirect_url"];
    authRequest.scope = [AppDelegate getExtendWithPluginName:@"weibo"][@"scope"];
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbtoken];

    [WeiboSDK sendRequest:request];
}

#pragma mark - WBHttpRequestDelegate

/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    NSString *stringBack = nil;
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if ((int)response.statusCode == WeiboSDKResponseStatusCodeSuccess)
        {
            // 授权成功
            self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
            self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
            self.wbRefreshToken = [(WBAuthorizeResponse *)response refreshToken];

            NSDictionary *dicBack = @{@"status" : @0,
                                      @"token" : [(WBAuthorizeResponse *)response accessToken],
                                      @"uid" : [(WBAuthorizeResponse *)response userID],
                                      @"expiresTime" : [ToolsFunction stringFromDate:[(WBAuthorizeResponse *)response expirationDate]]};

            stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
        } else if ((int)response.statusCode == WeiboSDKResponseStatusCodeAuthDeny)
        {
            // 授权失败
            NSDictionary *dicRequestUserInfo = [(WBAuthorizeResponse *)response requestUserInfo];
            
            NSDictionary *dicBack = @{@"status" : @2,
                                      @"code" : dicRequestUserInfo[@"error_code"],
                                      @"msg" : dicRequestUserInfo[@"error_description"]};
            stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
            
        } else if ((int)response.statusCode == WeiboSDKResponseStatusCodeUserCancel)
        {
            // 取消授权
            NSDictionary *dicBack = @{@"status" : @1,
                                      @"msg" : @"取消授权"};
            stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
        }
    } else if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        if ((int)response.statusCode == WeiboSDKResponseStatusCodeSuccess)
        {
            // 分享成功
            NSDictionary *dicBack = @{@"status" : @0,
                                      @"msg" : @"分享成功"};
            stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
            
        } else if ((int)response.statusCode == WeiboSDKResponseStatusCodeUserCancel)
        {
            // 取消分享
            NSDictionary *dicBack = @{@"status" : @1,
                                      @"msg" : @"取消分享"};
            stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
            
        } else if ((int)response.statusCode == WeiboSDKResponseStatusCodeSentFail)
        {
            // 分享失败
            NSDictionary *dicBack = @{@"status" : @2,
                                      @"msg" : @"分享失败"};
            stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
            
        } else {
            NSDictionary *dicBack = @{@"status" : @(-1),
                                      @"msg" : @"其他"};
            stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
        }
    }
    [self performSelectorOnMainThread:@selector(mainThreadOperateWithParamsString:) withObject:stringBack waitUntilDone:NO];
}

#pragma mark - Custom Method

// 返回js操作
- (void)mainThreadOperateWithParamsString:(NSString *)paramsString
{
    [[AppDelegate shareAppDelegate].excuteWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);",[[NSUserDefaults standardUserDefaults] valueForKey:@"cbid"], paramsString, paramsString]];
}


#pragma mark -- ytfApplicationDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     [WeiboSDK registerApp:[AppDelegate getExtendWithPluginName:@"weibo"][@"app_key"]];
    return true;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (NSString *)transformStringToJSJsonWithJsonString:(NSString *)jsonString
{
    
    NSString * callBackFinalData =  [jsonString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\\\n"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\\r" withString:@"\\\r"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    //  callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    // callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
    
    
    return callBackFinalData;
}

@end
