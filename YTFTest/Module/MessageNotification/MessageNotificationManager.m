/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic notification event manager.
 * =============================================================================
 */

#import "MessageNotificationManager.h"
#import "Definition.h"
#import "YTFAFNetworking.h"
//#import "NotificationManager.h"

NSString *const NotificationWebViewScrollToBottom = @"AppWebViewScrollToBottom"; /**<webView滑到底部 */

@interface MessageNotificationManager ()

@property (nonatomic, strong) NSMutableDictionary *notificationDictionary; // 消息对应ciId Name <-> CbId
@property (nonatomic, strong) NSMutableArray *notificationNameArray; // 已经添加的通知 避免多次添加通知
@property (nonatomic, weak) BaseWebView *notificationWebView;

@end

@implementation MessageNotificationManager


- (instancetype)init
{
    if (self == [super init])
    {
        //
        self.notificationNameArray = [NSMutableArray new];
        self.notificationDictionary = [NSMutableDictionary new];
    }
    
    return self;
}

/**
 *  添加事件监听
 *
 *  @param webView JSContext
 */
- (void)addEventListenerWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfEventListenerAdd"] = ^() {
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        /* 网络状态
         {
         eventName = onOffLine;
         }
         */
        
        /* app激活
         {
         eventName = appActive;
         }
         */
        
        /* app后台运行
         {
         eventName = appBack;
         }
         */
        
        /*
         {
         eventName = event1;
         }
         */
        
        /*
         {
         eventName = event2;
         }
         */
        
        /* 滑动到底部监听
         {
         eventName = scrollToBottom;
         attr: {
         　scrollToBottomHeight: 30 //如：设置离底部30px时触发scrollToBottom事件
         }
         }
         */
        
        weakself.notificationWebView = weakwebView;

        // 激活
        if ([dicArgs[@"eventName"] isEqualToString:@"appActive"] && ![weakself.notificationNameArray containsObject:dicArgs[@"eventName"]])
        {
            [[NSNotificationCenter defaultCenter] addObserver:weakself selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
        
        // 后台
        if ([dicArgs[@"eventName"] isEqualToString:@"appBack"] && ![weakself.notificationNameArray containsObject:dicArgs[@"eventName"]])
        {
            [[NSNotificationCenter defaultCenter] addObserver:weakself selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
        
        // 网络状态
        if ([dicArgs[@"eventName"] isEqualToString:@"onOffLine"] && ![weakself.notificationNameArray containsObject:dicArgs[@"eventName"]])
        {
            [[NSNotificationCenter defaultCenter] addObserver:weakself selector:@selector(reachabilityStatus:) name:YTFAFNetworkingReachabilityDidChangeNotification object:nil];
            [[YTFAFNetworkReachabilityManager sharedManager] startMonitoring];
        }
        
        // webview 滑到底部
        if ([dicArgs[@"eventName"] isEqualToString:@"scrollToBottom"] && ![weakself.notificationNameArray containsObject:dicArgs[@"eventName"]])
        {
            [[NSNotificationCenter defaultCenter] addObserver:weakself selector:@selector(webViewScrollToBottom:) name:NotificationWebViewScrollToBottom object:nil];
            weakwebView.scrollBottomHeight = [dicArgs[@"attr"][@"scrollToBottomHeight"] doubleValue];
        } else if (![weakself.notificationNameArray containsObject:dicArgs[@"eventName"]])
        {
            // 自定义
            [[NSNotificationCenter defaultCenter] addObserver:weakself selector:@selector(customEvent:) name:dicArgs[@"eventName"] object:nil];
        }
        
        if (![weakself.notificationNameArray containsObject:dicArgs[@"eventName"]])
        {
            [weakself.notificationNameArray addObject:dicArgs[@"eventName"]];
        }

        [weakself.notificationDictionary setValue:[ToolsFunction JSContextCBID] forKey:dicArgs[@"eventName"]];
    };
}

/**
 *  发送事件监听
 *
 *  @param webView JSContext
 */
- (void)postEventListenerWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView)
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfEventSend"] = ^() {
    
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        /* 发送自定义事件1
         {
         attr =     {
         key1 = "\U53d1\U9001\U81ea\U5b9a\U4e49\U6d88\U606f\Uff1a";
         key2 = event1;
         };
         eventName = event1;
         }
         */
        
        /* 发送自定义事件2
         {
         attr =     {
         key1 = "\U53d1\U9001\U81ea\U5b9a\U4e49\U6d88\U606f\Uff1a";
         key2 = event2;
         };
         eventName = event2;
         }
         */
        
        [[NSNotificationCenter defaultCenter] postNotificationName:dicArgs[@"eventName"] object:dicArgs];
        
        NSDictionary *dic = @{@"event":@"post"};
        [weakwebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", [ToolsFunction JSContextCBID], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
    };
}

/**
 *  移除事件监听
 *
 *  @param webView JSContext
 */
- (void)removeEventListenerWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfeventListenerRm"] = ^() {
        
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        /* 取消网络状态变化监听
         {
         eventName = onOffLine;
         }
         */
        
        /* 取消app后台运行状态监听
         {
         eventName = appBack;
         }
         */
        
        weakself.notificationWebView = weakwebView;
        
        if ([weakself.notificationNameArray containsObject:dicArgs[@"eventName"]])
        {
            NSDictionary *dic = @{@"status":@"1"};
            [self.notificationWebView stringByEvaluatingJavaScriptFromString:
             [NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);",
              [ToolsFunction JSContextCBID],
              [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""],
              [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
        }
        
        if ([weakself.notificationNameArray containsObject:dicArgs[@"eventName"]])
        {
            [weakself.notificationNameArray removeObject:dicArgs[@"eventName"]];
            if ([dicArgs[@"eventName"] isEqualToString:@"appBack"])
            {
                [[NSNotificationCenter defaultCenter] removeObserver:weakself name:UIApplicationDidEnterBackgroundNotification object:nil];
            } else if ([dicArgs[@"eventName"] isEqualToString:@"appActive"])
            {
                [[NSNotificationCenter defaultCenter] removeObserver:weakself name:UIApplicationDidBecomeActiveNotification object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] removeObserver:weakself name:dicArgs[@"eventName"] object:nil];
            }
        }
    };
}


#pragma mark - Custom Method

- (void)appDidBecomeActive:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic = @{@"event":@"foreground"};
        [_notificationWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", self.notificationDictionary[@"appActive"], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
    });
}

- (void)appDidEnterBackground:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic = @{@"event":@"appBack"};
        [_notificationWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", self.notificationDictionary[@"scrollToBottom"], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
    });
}

- (void)reachabilityStatus:(NSNotification *)notification
{
    NSDictionary *dicNotiObject = [notification object];
    
    [[YTFAFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(YTFAFNetworkReachabilityStatus status)
    {
        switch (status)
        {
            case YTFAFNetworkReachabilityStatusNotReachable:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dic = @{@"connectionType" : @"offline"};
                    
                    [(BaseWebView *)dicNotiObject stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", self.notificationDictionary[@"onOffLine"], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
                });
                
                break;
            }
                
            case YTFAFNetworkReachabilityStatusReachableViaWiFi:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dic = @{@"connectionType" : @"wifi"};
                    
                    [(BaseWebView *)dicNotiObject stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", self.notificationDictionary[@"onOffLine"], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
                });
                
                break;
            }
                
            case YTFAFNetworkReachabilityStatusReachableViaWWAN:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dic = @{@"connectionType" : @"wwan"};
                    
                    [(BaseWebView *)dicNotiObject stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", self.notificationDictionary[@"onOffLine"], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
                });
                
                break;
            }
            default:
                
                break;
        }
    }];
}

- (void)webViewScrollToBottom:(NSNotification *)notification
{
    NSDictionary *dicNotiObject = [notification object];
    
    if (self == ((BaseWebView *)dicNotiObject).messageNotificationManager)
    {
        [self performSelectorOnMainThread:@selector(mainThreadNotificationWithDictionary:) withObject:dicNotiObject waitUntilDone:NO];
    }
}

- (void)customEvent:(NSNotification *)notification
{
    NSDictionary *dicNotiObject = [notification object];

    if (self == self.notificationWebView.messageNotificationManager)
    {
        [self.notificationWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", self.notificationDictionary[dicNotiObject[@"eventName"]], [[ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dictionaryToJsonString:@{}]] stringByReplacingOccurrencesOfString:@"\n" withString:@""], [[ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dictionaryToJsonString:@{}]] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
    }
}

- (void)mainThreadNotificationWithDictionary:(NSDictionary *)dictionary
{
    NSDictionary *dic = @{@"event":@"scrollToBottom"};
    [(BaseWebView *)dictionary stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',false);", self.notificationDictionary[@"scrollToBottom"], [[ToolsFunction dictionaryToJsonString:dic] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
}



@end
