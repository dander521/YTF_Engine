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

#import "AppDelegate.h"
#import "Definition.h"
#import "YTFConfigManager.h"
#import "CustomWebViewProtocol.h"
#import "BaseViewController.h"
#import "AppSingleton.h"
#import "PathProtocolManager.h"
#import "WidgetCollectionViewController.h"
#import "AssistiveTouch.h"
#import "LaunchManager.h"
#import "DeviceInfoManager.h"
#import "RC4DecryModule.h"
#import "Masonry.h"
#import "NetworkManager.h"

@interface AppDelegate ()
{
    //悬浮框
    AssistiveTouch * _Win;
}

@property (nonatomic, assign) id<UIApplicationDelegate>appDelegate;


@end

@implementation AppDelegate

+ (AppDelegate *)shareAppDelegate
{
    if ([[UIApplication sharedApplication].delegate isKindOfClass:[AppDelegate class]])
    {
        [AppSingleton shareManager].appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    } else {
        [UIApplication sharedApplication].delegate = [AppSingleton shareManager].appDelegate;
    }
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


/**
 *  实现UIApplicationDelegate方法来接收应用消息，例如推送
 *
 *  @param name 代理对象
 */
- (void)addAppDelegateHandle:(id <UIApplicationDelegate>)handle
{
    [UIApplication sharedApplication].delegate = handle;
}


// 加载
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.appDelegate = [UIApplication sharedApplication].delegate;

    self.window=[[UIWindow  alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
#ifdef Loader
    // 上架配置是否直接显示widget  还是显示Loader
    [self putAwayConfig:application launchOptions:launchOptions];
    
#else
    self.baseViewController = [[BaseViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:self.baseViewController];
    [self loaderJudgetCoustum:application launchOptions:launchOptions];
    
#endif
    
    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    return YES;
}

// JPush
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
   // [self.ytfApplicationDelegate ytfApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    return YES;
}

// no equiv. notification. return NO if the application can't open for some reason
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return  YES; //[self.ytfApplicationDelegate ytfApplication:app openURL:url options:options];
}

/** 处理shortcutItem */
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if (shortcutItem.type)
    {
        NSString *jsonString = [ToolsFunction dicToJavaScriptString:@{@"type" : shortcutItem.type}];
        [self performSelectorOnMainThread:@selector(mainThreadMethod:) withObject:jsonString waitUntilDone:NO];
    }
};

- (void)mainThreadMethod:(NSString *)jsonString
{
    [[AppSingleton shareManager].touchWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", [AppSingleton shareManager].touchWebView.touchCbId, jsonString,jsonString]];
}


#pragma mark - Copy JS Files

// 拷贝资源到沙盒
- (void)copyJSFilesToAppSandBox
{
    [ToolsFunction copyFilesWithResourcePath:FilePathAppResourcesWidget destinationPath:FilePathCustomWidget];
}

#pragma mark - Custom Method

// 处理需要在 app入口做处理的 模块
- (void)setAppLaunchInMoudle:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 测试读取 json文件
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"module"ofType:@"json"];
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    
    NSMutableArray * jsonArrayObject;
    if (jdata) {
        
        jsonArrayObject =  [NSJSONSerialization JSONObjectWithData:jdata options:NSJSONReadingMutableLeaves error:nil];
    }
    for (id jsonArray in jsonArrayObject){

        if ([jsonArray[@"doAppLaunch"] isEqualToString:@"YES"]) {
            // 控制器类对象 字符串转类！
            Class targetViewControllerClass = NSClassFromString(jsonArray[@"class"]);
            // 创建对象

            id targetViewController = [[targetViewControllerClass alloc] init];
            [targetViewController application:application didFinishLaunchingWithOptions:launchOptions];
        }
    }
}

/**
 *  获取插件的config配置信息
 *
 *  @param name 插件名
 *
 *  @return 插件的信息字典
 */
+ (NSDictionary *)getExtendWithPluginName:(NSString *)name
{
#ifdef Loader
    NSDictionary *dicConfig;
    if (LoaderJudget) {
        dicConfig = [YTFConfigManager shareConfigManager].extendDictionary;
    }else{
#ifdef DecryMode
        
        NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"assets/widget/config.json" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:configFilePath];
        
        if (data == nil)
        {
            return nil;
        }
        
        NSData *decryData = [RC4DecryModule dataDecry_RC4WithByteArray:(Byte *)[data bytes] key:DecryKey fileData:data];
        NSDictionary *dicJson = [NSJSONSerialization JSONObjectWithData:decryData options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dicConfig = dicJson[@"extend"];
#else
        
        NSDictionary *dicConfig = [ToolsFunction JsonFileToDictionaryWithFileRelativePath:@"assets/widget/config.json"][@"extend"];
        
        if (dicConfig && [dicConfig isKindOfClass:[NSDictionary class]] && name)
        {
            return [dicConfig objectForKey:name];
        }
#endif

    }
#else
    
#ifdef DecryMode
    
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"assets/widget/config.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:configFilePath];
    
    if (data == nil)
    {
        return nil;
    }
    
    NSData *decryData = [RC4DecryModule dataDecry_RC4WithByteArray:(Byte *)[data bytes] key:DecryKey fileData:data];
    NSDictionary *dicJson = [NSJSONSerialization JSONObjectWithData:decryData options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *dicConfig = dicJson[@"extend"];
#else
    
    NSDictionary *dicConfig = [ToolsFunction JsonFileToDictionaryWithFileRelativePath:@"assets/widget/config.json"][@"extend"];
#endif
#endif
    
    if (dicConfig && [dicConfig isKindOfClass:[NSDictionary class]] && name)
    {
        return [dicConfig objectForKey:name];
    }
    return nil;
}

/**
 通过相对路径获取绝对路径
 
 @param relativePath 相对路径
 
 @return 绝对路径
 */
- (NSString *)getAbsolutePathWithRelativePath:(NSString *)relativePath
{
    if ([relativePath hasPrefix:@"fs"])
    {
        return [PathProtocolManager getWebViewUrlWithFSProtocolPath:relativePath];
    } else if ([relativePath hasPrefix:@"widget"])
    {
        return [PathProtocolManager getWebViewUrlWithWidgetProtocolPath:relativePath];
    } else{
        return relativePath;
    }
}

- (NSString *)getWidgetPath
{
    return FilePathCustomWidget;
}

- (NSString *)getFSPath
{
    return FilePathCustomFS;
}

// 设置自定义悬浮框坐标
-(void)setNew
{
    _Win = [[AssistiveTouch alloc] initWithFrame:CGRectMake(ScreenWidth - 80.0, ScreenHeight - 80.0, 60, 60)];
}


// 移除启动页
- (void)removeLanuch
{
    [[LaunchManager shareManager] removeLaunchImageView];
}

#pragma mark - 保存日志文件
- (void)redirectNSLogToDocumentFolder
{
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        return;    }
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"])
    { //在模拟器不保存到文件中
        return;
    }
    //获取Document目录下的Log文件夹，若没有则新建
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    DLog(@"logDirectory = %@", logDirectory);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.txt",dateStr];
    // freopen 重定向输出输出流，将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}


/**
 上架后请求服务器  根据返回的字段判断是直接显示带widget包的完整工程  还是显示成 Loader，（为了上架 绕开apple的审核）

 @param application application
 @param launchOptions launchOptions
 */
- (void)putAwayConfig:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions{
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:@"https://www.ytfcloud.com/debug-loader/ios"];
    //第二步，通过URL创建网络请求
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
   // NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSDictionary * recDic = [ToolsFunction responseConvertToDictionary:received];
    if ([recDic[@"status"] boolValue] == [[NSNumber numberWithBool:0] boolValue]) {
        [[NSUserDefaults standardUserDefaults]setObject:@0 forKey:@"LaunchLoader"];
       //  直接显示  widget
                        self.baseViewController = [[BaseViewController alloc] init];
                        self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:self.baseViewController];
                        [self loaderJudgetCoustum:application launchOptions:launchOptions];
    }else{
    //  显示成 Loader
        [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:@"LaunchLoader"];
                    WidgetCollectionViewController *vwcWidget = [[WidgetCollectionViewController alloc] init];
                        self.window.rootViewController = vwcWidget;
                        // 这句话很重要，要先将rootview加载完成之后在显示悬浮框，如没有这句话，将可能造成程序崩溃
                        [self performSelector:@selector(setNew) withObject:nil afterDelay:3];
        
                     [self loaderJudgetCoustum:application launchOptions:launchOptions];
    
    }
    
  }

- (void)loaderJudgetCoustum:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions{

    [self.window makeKeyAndVisible];
    [self.window addSubview:[[LaunchManager shareManager] showLaunchImageView]];
    
#ifdef Loader
    
if (LoaderJudget) {
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeLanuch) userInfo:nil repeats:NO];
    }else{
    
        if ([[YTFConfigManager shareConfigManager].autoLaunch boolValue])
        {
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeLanuch) userInfo:nil repeats:NO];
        }
    }
#else
    
    if ([[YTFConfigManager shareConfigManager].autoLaunch boolValue])
    {
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeLanuch) userInfo:nil repeats:NO];
    }
#endif
    
    // 注册webView拦截对象
    [NSURLProtocol registerClass:[CustomWebViewProtocol class]];
    
    // 处理需要在 app入口做处理的 模块
    [self setAppLaunchInMoudle:application didFinishLaunchingWithOptions:launchOptions];
}

@end
