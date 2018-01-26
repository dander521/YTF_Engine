/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         LiWei<15002887901@163.com>
 *  @created        2016-9-7
 *  @description    YTFJPushModule Plugin.
 * =============================================================================
 */



#import "YTFJPushModule.h"
#import "AppDelegate.h"
#import "JPUSHService.h"
#import "ToolsFunction.h"
#import "Definition.h"
static NSString * jpushAppkey = @"00ff598f681dd492e3e09a64";

@implementation YTFJPushModule


///**
// *  启动推送
// *
// *  @param args JS传入的参数
// */
//- (void)ytfStartJPush:(NSDictionary *)args;{
//    // 参数解析
//    startCbid       = args[@"cbId"];
//    jPushWebView             = args[@"target"];
//    // 设置 ApplicationDelegate  代理对象
//    [AppDelegate shareAppDelegate].ytfApplicationDelegate = self;
//    
//}
//

/**
 *  设置消息监听
 *
 *  @param args JS传入的参数
 */
- (void)setListener:(NSDictionary *)args{
    // 参数解析
    setListenerCbid       = args[@"cbId"];
    jPushWebView          = args[@"target"];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    
  //  NSLog(@"+++++++++++++++++ ytfSetListener +++++++++++++++++++++");

}


/**
 *  移除消息监听
 *
 *  @param args JS传入的参数
 */
- (void)removeListener:(NSDictionary *)args{


    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
   // NSLog(@"+++++++++++++++++ ytfRmListener +++++++++++++++++++++");
 }


/**
 *  清除极光推送发送到状态栏的通知
 *
 *  @param args JS传入的参数
 */
- (void)removeMessage:(NSDictionary *)args{

    self.clearAllMsg = YES;
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:self.clearAllMsg]forKey:@"clearAllMsg"];
    
 //   NSLog(@"+++++++++++++++++ ytfRmMessage +++++++++++++++++++++");

}

/**
 *  停止推送
 *
 *  @param args JS传入的参数
 */
- (void)stopPush:(NSDictionary *)args{

    //  需要当前应用的 bundleID
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID&&path=com.yuantuan.YTFEngine"]];

}

/**
 *  重启推送
 *
 *  @param args JS传入的参数
 */
- (void)resumePush:(NSDictionary *)args{

  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID&&path=com.yuantuan.YTFEngine"]];

}

/**
 *  判断当前APP是否允许推送
 *
 *  @param args JS传入的参数
 */
- (void)isPushStopped:(NSDictionary *)args{

    NSString * allowCbid       = args[@"cbId"];
    jPushWebView                    = args[@"target"];
    
    NSDictionary *dictionarg;
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]  == UIUserNotificationTypeNone) { //判断用户是否打开通知开关
        dictionarg = @{@"status" :@1};
        
    }else{
         dictionarg = @{@"status" :@0};
     }
    NSString * testString = [ToolsFunction dicToJavaScriptString:dictionarg];
    [jPushWebView stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"YTFcb.on('%@','%@','%@',false);",allowCbid,testString,testString]];

}

/**
 *  获取一个唯一的该设备的标识RegistrationID
 *
 *  @param args JS传入的参数
 */
- (void)getRegistrationId:(NSDictionary *)args{


    NSString * registerIDCbid       = args[@"cbId"];
    jPushWebView                    = args[@"target"];
    NSString * registerID = [JPUSHService registrationID];
    
    NSDictionary *  dictionarg = @{@"id" :registerID};

    NSString * testString = [ToolsFunction dicToJavaScriptString:dictionarg];
    
    [jPushWebView stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"YTFcb.on('%@','%@','%@',false);",registerIDCbid,testString,testString]];

}


#pragma mark -- ytfApplicationDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return true;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{


    [JPUSHService registerDeviceToken:deviceToken];
    if (deviceToken) {
       //启动推送成功的回调
        NSDictionary *dictionarg = @{@"status" :@"1"};
        NSString * testString = [ToolsFunction dicToJavaScriptString:dictionarg];
        [jPushWebView stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"YTFcb.on('%@','%@','%@',false);",startCbid,testString,testString]];
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application{

    NSNumber * clearNum = [[NSUserDefaults standardUserDefaults]objectForKey:@"clearAllMsg"];
    if (clearNum) {
         [application setApplicationIconBadgeNumber:0];
    }
    
      self.clearAllMsg = NO;
}

/**
 *  NSNotification
 *
 *  @param notification 在前台收到消息的监听事件
 */
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *jpID         = [userInfo valueForKey:@"id"];
    NSString *jptitle      = [userInfo valueForKey:@"title"];
    NSString *jpcontent    = [userInfo valueForKey:@"content"];
    NSDictionary *jpextra  = [userInfo valueForKey:@"extras"];
    
    if (jpID==nil) {
        jpID =@"";
    }
    if (jptitle==nil) {
        jptitle =@"";
    }
    if (jpextra==nil) {
        jpextra =@{@"":@""};
    }
    //前台回去消息的回调回调
    NSDictionary *dictionarg = @{@"id" :jpID,@"title":jptitle,@"content":jpcontent,@"extra":jpextra};
    NSString * testString = [ToolsFunction dicToJavaScriptString:dictionarg];

    [self performSelectorOnMainThread:@selector(jsPushCallBack:) withObject:testString waitUntilDone:NO];
    
}


- (void)jsPushCallBack:(NSString *)testString{

    [jPushWebView stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"YTFcb.on('%@','%@','%@',false);",setListenerCbid,testString,testString]];


}

- (void)dealloc{

    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationWhenModuleDealloc object:nil];
}

@end
