/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFWeChatModule Plugin.
 * =============================================================================
 */

#import "YTFWeChatModule.h"
#import "AppDelegate.h"
#import "ToolsFunction.h"
#import "WXApiRequestHandler.h"
#import "Definition.h"
// 微信
#define kAppWeChatAppID     @"wx77805b4964a182e0"
#define kAppWeChatSecret    @"cffe6b710216e7d59dc691d931d4a3e1"

@interface YTFWeChatModule ()<WXApiDelegate>
{
    UIWebView * excuteWebView;//当前webView
}
@property (nonatomic, copy) NSString *accessTokenCode; // 获取token的code
@property (nonatomic, copy) NSString *access_token; // 用户 token
@property (nonatomic, copy) NSString *openId; //
@property (nonatomic, copy) NSString *unionid; //
@property (nonatomic, copy) NSString *refreshToken; // 授权过期 重新获取的token

@end

@implementation YTFWeChatModule

+ (YTFWeChatModule *)shareInstance {
    static YTFWeChatModule *LoginShare = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        LoginShare = [[self alloc] init];
    });
    return LoginShare;
}


/**
 *  是否安装微信
 *
 *  @param paramsDictionary JS参数字典
 */
- (NSNumber *)isInstalled:(NSDictionary *)paramsDictionary
{

    NSNumber *result = nil;

    if ([WXApi isWXAppInstalled])
    {
        result = [NSNumber numberWithInt:YES];
    } else {
        result = [NSNumber numberWithInt:NO];
    }
      
    return result;
}

/**
 *  授权登录
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)auth:(NSDictionary *)paramsDictionary
{
    /*
     {
     cbId = auth5;
     target = "<BaseWebView: 0x7f9972863d80; baseClass = UIWebView; frame = (0 38; 375 567); layer = <CALayer: 0x7f997040a5e0>>";
     }
     */

    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    excuteWebView = paramsDictionary[@"target"];
    [[AppDelegate shareAppDelegate] addAppDelegateHandle:self];
    
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"123" ;
    
    if ([WXApi isWXAppInstalled])
    {
        [WXApi sendReq:req];
    } else {
        //第三方向微信终端发送一个SendAuthReq消息结构
        // FIXME:  插件中除了设置代理  其他地方不要用shareAppDelegate 做事情
        [WXApi sendAuthReq:req viewController:(UIViewController *)[AppDelegate shareAppDelegate].baseViewController delegate:self];
    }
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
     scene: 'timeline',
     text: '我分享的文本'
     };
     cbId = shareText6;
     target = "<BaseWebView: 0x7f9972863d80; baseClass = UIWebView; frame = (0 38; 375 567); layer = <CALayer: 0x7f997040a5e0>>";
     }
     */
    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    excuteWebView = paramsDictionary[@"target"];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = paramsDictionary[@"args"][@"text"];
    req.bText = YES;
    req.scene = [paramsDictionary[@"args"][@"scene"] intValue];
    [WXApi sendReq:req];
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
     isTimeline = 0;
     path = "https://pay.weixin.qq.com/wiki/doc/api/img/logo.png";
     };
     cbId = shareImage7;
     target = "<BaseWebView: 0x7f9972863d80; baseClass = UIWebView; frame = (0 38; 375 567); layer = <CALayer: 0x7f997040a5e0>>";
     }
     */
    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    excuteWebView = paramsDictionary[@"target"];
    
    WXMediaMessage *message = [WXMediaMessage message];
    WXImageObject *imageobject = [WXImageObject object];
    NSString *filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imageUrl"]];
    imageobject.imageData = [NSData dataWithContentsOfFile:filePath];
    message.mediaObject = imageobject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [paramsDictionary[@"args"][@"scene"] intValue];
    [WXApi sendReq:req];
}

/**
 *  分享音乐
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareMusic:(NSDictionary *)paramsDictionary
{
    /*
     {
     args =     {
     description = "\U8fd9\U662f\U97f3\U4e50\U4e13\U8f91\U7684\U7b80\U8ff0\U3002\U3002\U3002\U3002\U3002\U3002";
     isTimeline = 0;
     path = "http://staff2.ustc.edu.cn/~wdw/softdown/index.asp/0042515_05.ANDY.mp3";
     title = "\U8fd9\U662f\U5206\U4eab\U97f3\U4e50";
     };
     cbId = shareMusic8;
     target = "<BaseWebView: 0x7f9972863d80; baseClass = UIWebView; frame = (0 38; 375 567); layer = <CALayer: 0x7f997040a5e0>>";
     }
     */
    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    excuteWebView = paramsDictionary[@"target"];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = paramsDictionary[@"args"][@"title"];
    message.description = paramsDictionary[@"args"][@"description"];
    [message setThumbImage:[UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imageUrl"]]]];
    
    WXMusicObject *musicobject = [WXMusicObject object];
    musicobject.musicUrl = paramsDictionary[@"args"][@"path"];
    musicobject.musicLowBandUrl = musicobject.musicUrl;
    musicobject.musicDataUrl = paramsDictionary[@"args"][@"path"];
    musicobject.musicLowBandDataUrl = musicobject.musicDataUrl;
    message.mediaObject = musicobject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [paramsDictionary[@"args"][@"scene"] intValue];
    [WXApi sendReq:req];
}

/**
 *  分享视频
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareVideo:(NSDictionary *)paramsDictionary
{
    /*
     {
     args =     {
     description = "\U8fd9\U662f\U97f3\U4e50\U4e13\U8f91\U7684\U7b80\U8ff0\U3002\U3002\U3002\U3002\U3002\U3002";
     isTimeline = 0;
     title = "\U8fd9\U662f\U5206\U4eab\U97f3\U4e50";
     url = "http://www.baidu.com";
     };
     cbId = shareVideo9;
     target = "<BaseWebView: 0x7f9972863d80; baseClass = UIWebView; frame = (0 38; 375 567); layer = <CALayer: 0x7f997040a5e0>>";
     }
     */
    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    excuteWebView = paramsDictionary[@"target"];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = paramsDictionary[@"args"][@"title"];
    message.description = paramsDictionary[@"args"][@"description"];
    [message setThumbImage:[UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imageUrl"]]]];
    
    WXVideoObject *videoobject = [WXVideoObject object];
    videoobject.videoUrl = paramsDictionary[@"args"][@"path"];
    videoobject.videoLowBandUrl = videoobject.videoUrl;
    message.mediaObject = videoobject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [paramsDictionary[@"args"][@"scene"] intValue];
    [WXApi sendReq:req];
}

/**
 *  分享网页
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareWebPage:(NSDictionary *)paramsDictionary
{
    /*
     {
     title:title,
     description:descript,
     isTimeline:false,
     path:urls,
     imageUrl:photo
     };
     cbId = shareWebPage10;
     target = "<BaseWebView: 0x7f9972863d80; baseClass = UIWebView; frame = (0 38; 375 567); layer = <CALayer: 0x7f997040a5e0>>";
     }
     */
    
    /**
     *  NSDictionary * shareInfoDic  =  args[@"args"];
     shareTitle                   =  shareInfoDic[@"title"];
     shareToFriend                =  shareInfoDic[@"shareToFriend"];

     */
    
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    excuteWebView = paramsDictionary[@"target"];
    [[AppDelegate shareAppDelegate] addAppDelegateHandle:self];
    WXMediaMessage *message = [WXMediaMessage message];
    message.title           = paramsDictionary[@"args"][@"title"];
    message.description     = paramsDictionary[@"args"][@"description"];
    [message setThumbImage:[UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imageUrl"]]]];
    
    WXWebpageObject *videoobject = [WXWebpageObject object];
    videoobject.webpageUrl = paramsDictionary[@"args"][@"path"];
    message.mediaObject = videoobject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    
    req.scene = [paramsDictionary[@"args"][@"scene"] intValue];
    req.message = message;
    [WXApi sendReq:req];

}


//  当前版本是否支持分享到朋友圈
- (NSNumber *)checkShareTimeline:(NSDictionary *)paramsDictionary{

    return @1;
}


/**
 *  获取token
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)getToken:(NSDictionary *)paramsDictionary
{
    /*
     {
     args =     {
     code = 011owsZo1dgl1v0BbJZo1pDrZo1owsZz;
     };
     cbId = getToken6;
     target = "<BaseWebView: 0x1446e3cc0; baseClass = UIWebView; frame = (0 38; 414 636); layer = <CALayer: 0x1446d62d0>>";
     }
     */
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    excuteWebView = paramsDictionary[@"target"];
    
    [self getAccessTokenWithCode:paramsDictionary[@"args"][@"code"]];
}

/**
 *  获取用户信息
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)getUserInfo:(NSDictionary *)paramsDictionary
{
    /*
     {
     args =     {
     "access_token" = "LObEED6huuSFz-_nqrvcLkWkj5Ojx3gFGm5-Rn_r5gYU5c79v51isPLoaT8bnkn0WkPF6HtqAazW9wETtv5ytsHBDxh6Z3fQYmfNmzNyBIc";
     openid = oD4LQwpc08lvJszVFVF8j38MsmS4;
     };
     cbId = getUserInfo7;
     target = "<BaseWebView: 0x15f289790; baseClass = UIWebView; frame = (0 38; 414 636); layer = <CALayer: 0x15f2893a0>>";
     }
     */
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    excuteWebView = paramsDictionary[@"target"];
    
    [self achieveUserInfoWithAccessToken:paramsDictionary[@"args"][@"access_token"] andOpenId:paramsDictionary[@"args"][@"openid"]];
}

/**
 *  重新获取token
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)refreshToken:(NSDictionary *)paramsDictionary
{
    /*
     {
     args =     {
     "refresh_token" = "8yt2xpXc_BJLUHeSGlTJ6HwjuDo63Cz3dEtqQKUyA97PhNeUpzeYkHJRXlp5AdKMeujCEa5vAyq5_6DJDSS3p3yaUBq2tlQYzUZOTo2N__A";
     };
     cbId = refreshToken7;
     target = "<BaseWebView: 0x160971a10; baseClass = UIWebView; frame = (0 38; 414 636); layer = <CALayer: 0x15f5d9580>>";
     }
     */
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    excuteWebView = paramsDictionary[@"target"];
    
    // AccessToken失效
    [self getAccessTokenWithRefreshToken:paramsDictionary[@"args"][@"refresh_token"]];
}

/**
 *  微信支付
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)pay:(NSDictionary *)paramsDictionary
{
    /*
     {
     args =     {
     body = "APP pay test";
     "mch_id" = 1385412502;
     "notify_url" = "http://121.40.35.3/notify";
     "total_fee" = 1;
     };
     cbId = pay6;
     target = "<BaseWebView: 0x126a00620; baseClass = UIWebView; frame = (0 38; 414 636); layer = <CALayer: 0x126a595f0>>";
     
     
     "notify_url":"http://121.40.35.3/notify",
     "app_id":"wx77805b4964a182e0",
     "secret":"cffe6b710216e7d59dc691d931d4a3e1",
     "mch_id":"1385412502"
     }
     */
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[AppDelegate shareAppDelegate] addAppDelegateHandle:self];
 
    excuteWebView = paramsDictionary[@"target"];

    // 发起支付
    [WXApiRequestHandler jumpToWxPayWithTotalFee:paramsDictionary[@"args"][@"total_fee"]
                                      merchantId:[AppDelegate getExtendWithPluginName:@"weixin"][@"mch_id"]
                                       notifyUrl:[AppDelegate getExtendWithPluginName:@"weixin"][@"notify_url"]
                                         bodyDes:paramsDictionary[@"args"][@"body"]];
   
}

- (void)dealloc{

    
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationWhenModuleDealloc object:nil];

}

#pragma mark - WXApiDelegate

-(void)onReq:(BaseReq*)req
{
    DLog(@"------");
}

-(void)onResp:(BaseResp*)resp
{
    NSString *stringBack  = nil;
    NSDictionary *dicBack = nil;
    // 微信登录
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == WXSuccess) {
            SendAuthResp *aresp = (SendAuthResp *)resp;
            self.accessTokenCode = aresp.code;
            dicBack = @{@"status" : @0,
                        @"code" : aresp.code};
        } else
        {
            dicBack = @{@"status" : [NSNumber numberWithInt:resp.errCode]};
        }
    }
    
    // 微信分享/收藏
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *aresp = (SendMessageToWXResp *)resp;
        DLog(@"-------%d",aresp.errCode);
        if (aresp.errCode == WXSuccess)
        {//错误码0 表示回调成功
            dicBack = @{@"status" : @0};
        } else {
            dicBack = @{@"status" : [NSNumber numberWithInt:resp.errCode]};
        }
    }
    
    if([resp isKindOfClass:[PayResp class]])
    {
        if (resp.errCode == WXSuccess)
        {
            dicBack = @{@"status" : @0};
        } else {
            dicBack = @{@"status" : [NSNumber numberWithInt:resp.errCode]};
        }
    }
    
    stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
    // 避免线程卡顿
    [self performSelector:@selector(weChatCallBackevaluateJavaScriptMethodWithJsonString:) withObject:stringBack afterDelay:NO];
 
}


/**
 支付或者分享结果的回调

 @param stringBack
 */
- (void)weChatCallBackevaluateJavaScriptMethodWithJsonString:(NSString * )stringBack{

    [excuteWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",[[NSUserDefaults standardUserDefaults] valueForKey:@"cbid"], stringBack]];
}

/**
 *  获取access_token
 *
 *  @param code code description
 */
- (void)getAccessTokenWithCode:(NSString *)code
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kAppWeChatAppID,kAppWeChatSecret,code];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "5Zu7luI-7p3x2Vpe5x-bb7EK4CuDkvfoZkTpNTev5ysY_ER98n6jJP_VGykO5r4fNAPwFMf3tEgcGpVHJl6OjxaLuPWVEhIEUU0aciDTbkw";
                 "expires_in" = 7200;
                 openid = oD4LQwpc08lvJszVFVF8j38MsmS4;
                 "refresh_token" = "SSGRU9-ZeEHVtnbcbEuses3k1uDI5r64l_0ykOh4hg_TMw23YSOYO0a43bJBxnERNGxOwbrIq5ImbhcZCnpUauiIWIarqleG3PIm-9wtZak";
                 scope = "snsapi_userinfo";
                 unionid = oyUuww1l8VtlvcaSbAVhWYRfMXVU;
                 }
                 */
                NSString *stringBack = nil;
                NSDictionary *dicBack = nil;
                
                if ([dict objectForKey:@"errcode"])
                {
                    dicBack = @{@"code" : [dict objectForKey:@"errcode"]};
                }else{
                    
                    self.refreshToken = [dict objectForKey:@"refresh_token"];
                    self.access_token = [dict objectForKey:@"access_token"];
                    self.openId = [dict objectForKey:@"openid"];
                    self.unionid = [dict objectForKey:@"unionid"];
                    
                    dicBack = @{@"access_token" : [dict objectForKey:@"access_token"],
                                @"openid" : [dict objectForKey:@"openid"],
                                @"refresh_token" : [dict objectForKey:@"refresh_token"],
                                @"expires_in" : dict[@"expires_in"],
                                @"scope" : dict[@"scope"]};
                }
                
                stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
                
                [self performSelectorOnMainThread:@selector(mainThreadOperateWithParamsString:) withObject:stringBack waitUntilDone:NO];
            }
        });
    });
}

/**
 *  获取用户信息
 *
 *  @param accessToken access_token
 *  @param openId      openId description
 */
- (void)achieveUserInfoWithAccessToken:(NSString *)accessToken andOpenId:(NSString *)openId
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
 
                NSString *stringBack = nil;
                NSDictionary *dicBack = nil;
                if ([dict objectForKey:@"errcode"])
                {
                    dicBack = @{@"code" : [dict objectForKey:@"errcode"]};
                }else{
                    /*
                     {
                     city = "Xi'an";
                     country = CN;
                     headimgurl = "http://wx.qlogo.cn/mmopen/nvfCNqAnLCvAGHzHk3PIQnuk0SkmJm2DdGSRcmpo4SK6vhpgwc2Z5DsX1TRzERtuWbZryqqWDrqMq8UJbRjQLicALqrpnJML1/0";
                     language = "zh_CN";
                     nickname = "\U7a0b\U8363\U521a_FSD";
                     openid = oD4LQwpc08lvJszVFVF8j38MsmS4;
                     privilege =     (
                     );
                     province = Shaanxi;
                     sex = 1;
                     unionid = oyUuww1l8VtlvcaSbAVhWYRfMXVU;
                     }
                     */
                    dicBack = @{@"status" : @0,
                                @"openid" : dict[@"openid"],
                                @"nickname" : dict[@"nickname"],
                                @"sex" : dict[@"sex"],
                                @"headimgurl" : dict[@"headimgurl"],
                                @"privilege" : dict[@"privilege"],
                                @"unionid" : dict[@"unionid"]};
                }
                
                stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
                
                [self performSelectorOnMainThread:@selector(mainThreadOperateWithParamsString:) withObject:stringBack waitUntilDone:NO];
            }
        });
    });
}

/**
 *  刷新access_token
 *
 *  @param refreshToken refreshToken description
 */
- (void)getAccessTokenWithRefreshToken:(NSString *)refreshToken
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",kAppWeChatAppID,refreshToken];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                NSString *stringBack = nil;
                NSDictionary *dicBack = nil;

                if ([dict objectForKey:@"errcode"])
                {
                    dicBack = @{@"code" : [dict objectForKey:@"errcode"]};
                }else{
                    
                    /*
                     {
                     "access_token" = "kaZNa3ohTKfAvD0w2EhPgIpbIt_ZWTdLgfWMYmcRqr7v5WqO-By14KHy_dqNGP98deY5ENFxBsNEae5qMHWe4Xql7HF4jj9oND-LWLT-PHY";
                     "expires_in" = 7200;
                     openid = oD4LQwpc08lvJszVFVF8j38MsmS4;
                     "refresh_token" = "J2ty8_SOpfzj2qJoHVg2zk9AjBIk1n2afWC1HZFAiTIvA3vxtGSIl-UulKTdkng_AcU-v4AX6MBFSXyILIbiMqT6maPLFzGg3hDBLwNJLis";
                     scope = "snsapi_base,snsapi_userinfo,";
                     }
                     */
                    self.refreshToken = [dict objectForKey:@"refresh_token"];
                    self.access_token = [dict objectForKey:@"access_token"];
                    self.openId = [dict objectForKey:@"openid"];
                    
                    dicBack = @{@"access_token" : [dict objectForKey:@"access_token"],
                                @"openid" : [dict objectForKey:@"openid"],
                                @"refresh_token" : [dict objectForKey:@"refresh_token"],
                                @"expires_in" : dict[@"expires_in"],
                                @"scope" : dict[@"scope"]};
                }
                
                stringBack = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
                
                [self performSelectorOnMainThread:@selector(mainThreadOperateWithParamsString:) withObject:stringBack waitUntilDone:NO];
            }
        });
    });
}

#pragma mark - Custom Method

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


// 返回js操作
- (void)mainThreadOperateWithParamsString:(NSString *)paramsString
{
    [excuteWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",[[NSUserDefaults standardUserDefaults] valueForKey:@"cbid"], paramsString]];
}


#pragma mark -- ytfApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return [WXApi registerApp:[AppDelegate getExtendWithPluginName:@"weixin"][@"app_id"]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return [WXApi handleOpenURL:url delegate:self];
}


@end
