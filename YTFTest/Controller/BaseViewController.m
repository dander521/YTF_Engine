/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic viewController.
 * =============================================================================
 */

#import "BaseViewController.h"
#import "Definition.h"
#import "WindowManager.h"
#import "FrameManager.h"
#import "FrameGroupManager.h"
#import "DrawerWinManager.h"
#import "AppDelegate.h"
#import "NetworkManager.h"
#import "DeviceInfoManager.h"
#import "WindowInfoManager.h"
#import "YTFSDImageCache.h"
#import "SRWebSocket.h"
#import "SlipCloseWinGuesterManager.h"
#import "Masonry.h"
#import "RC4DecryModule.h"

@interface BaseViewController ()<SRWebSocketDelegate>
{
    id jsonArrayObject; //  json文件读出的 json数组
    NSString *moduleStringes;//模块字符串  用来注入
    NSString *lastModule;// 模块注入最终的字符串
    NSString *methodsName;
    NSString *tempMethodsName;
    SRWebSocket *_webSocket;
}

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation BaseViewController

- (instancetype)init
{
    if (self == [super init])
    {
        self.appDelegate = [AppDelegate shareAppDelegate];
        
        // 初始化路径
        [ToolsFunction createDirectoryWithPath:FilePathCustomMap];
        [ToolsFunction createDirectoryWithPath:FilePathCustomAssets];
        [ToolsFunction createDirectoryWithPath:FilePathCustomFS];
        [ToolsFunction createDirectoryWithPath:FilePathCustomWidget];
        [ToolsFunction createDirectoryWithPath:FilePathCustomDownload];
        [ToolsFunction createDirectoryWithPath:FilePathCustomHotFix];
        [ToolsFunction createDirectoryWithPath:FilePathCustomCache];
     
    }
    
    return self;
}

#pragma mark -- Navigation
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
     // 设置导航栏隐藏  否则win上部不能点击
    [self.navigationController setNavigationBarHidden:YES animated:TRUE];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    // 不在此处设置 无法从下一级视图控制器侧滑返回上一级视图控制器
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
}

#pragma mark -- Business Logic
- (void)viewDidLoad
{
    [super viewDidLoad];
    // 读取本地 JSON文件
    [self readJsonFile];
    // 创建index win
    [self openIndexWin];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeViewController:) name:AssistiveTouchNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pluginChangeDelegate:) name:NotificationWhenModuleDealloc object:nil];
    //插件的一些设置
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleViewGuestureNotific:) name:ModuleViewSlipBackGuestureNotific object:nil];
   // [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleViewOpenDrawerGuestureNotific:) name:ModuleiewOpenDrawerGuestureNotific object:nil];

#ifdef Loader
    DLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"LaunchLoader"] );
    if (LoaderJudget) {
        _webSocket.delegate = nil;
        
        [_webSocket close];
        
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%@/websocket", [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEHost], [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEPort]]]]];
        
        _webSocket.delegate = self;
        [_webSocket open];
    }
    
#else
#endif
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    [[YTFSDImageCache sharedImageCache] cleanDisk];
    [[YTFSDImageCache sharedImageCache] clearDisk];
    [[YTFSDImageCache sharedImageCache] clearMemory];
}

- (void)dealloc
{
    
}

- (void)closeViewController:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AssistiveTouchNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationWhenModuleDealloc  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    [[FrameGroupManager shareManager].frameGroupScrollViewDictionary removeAllObjects];
    [[FrameGroupManager shareManager].frameGroupNamesArray removeLastObject];
    [[FrameGroupManager shareManager].frameGroupConfigsArray removeLastObject];
    [[FrameGroupManager shareManager].frameGroupCbIdsArray removeLastObject];
    [[FrameGroupManager shareManager].closeWinFrameArray removeAllObjects];
    [[FrameGroupManager shareManager].originXFrameArray removeAllObjects];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LoaderIDEAppId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].baseViewController = nil;
    [self dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - Custom Method

// 打开win
- (void)openIndexWin
{

#ifdef Loader
    if (!LoaderJudget) {
        //  执行与 undef Loader 的操作
        [self customWidgetTest];
    }
#else
         // 初始化 index.html入口文件
         [self customWidgetTest];
#endif

    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat statusBarHeight = 20;
        if (![[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
        {
            statusBarHeight = 0;
        }
        [self.indexWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(statusBarHeight);
            make.bottom.equalTo(self.view).with.offset(0);
            make.left.equalTo(self.view).with.offset(0);
            make.right.equalTo(self.view).with.offset(0);
        }];
    });
}

- (void)readJsonFile
{
    // 测试读取 json文件
    //格式化成json数据
    if ([[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"module"ofType:@"json"]])
    {
        jsonArrayObject =  [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"module"ofType:@"json"]] options:NSJSONReadingMutableLeaves error:nil];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

    if (((BaseWebView *)webView).isRemoteWeb == true)
    {
        [ToolsFunction hideCustomProgress];
    }
    
    if ([[FrameGroupManager shareManager].htmlParamDictionary allValues].count > 0)
    {
        NSArray *arrayWebView = [[FrameGroupManager shareManager].htmlParamDictionary allValues];
        
        for (UIWebView *web in arrayWebView)
        {
            if (webView == web)
            {
                for (NSString *key in [[FrameGroupManager shareManager].htmlParamDictionary allKeys])
                {
                    if (web == [[FrameGroupManager shareManager].htmlParamDictionary objectForKey:key])
                    {
                        NSRange range = [key rangeOfString:@"-"];
                        NSString * frameGroupHtmlParam = [key substringFromIndex:range.location + 1];
                        [WindowInfoManager shareManager].htmlParam = frameGroupHtmlParam;
                        
                        break;
                    }
                }
            }
        }
    }
    
    if (((BaseWebView *)webView).frameGroupName && [[FrameGroupManager shareManager].reuseDictionary[((BaseWebView *)webView).frameGroupName] boolValue] == true)
    {
        [self performSelector:@selector(insertModuleStringWithWebView:) withObject:webView afterDelay:0.0];
    } else {
        [self performSelector:@selector(insertModuleStringWithWebView:) withObject:webView afterDelay:0.3];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"error = %@", error);

    NSString *errorHtml = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:@"assets/widget/error" ofType:@"html"]])
    {
        errorHtml = [[NSBundle mainBundle] pathForResource:@"assets/widget/error" ofType:@"html"];
    } else {
        errorHtml = [[NSBundle mainBundle] pathForResource:@"assets/error" ofType:@"html"];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:errorHtml]];
    [webView loadRequest:request];
}

- (void)moduleStringFunction
{
    NSString *tempModule=@"";
    lastModule=@"";
    for (id jsonArray in jsonArrayObject)
    {
        moduleStringes  = [NSString stringWithFormat:@"function %@ (nativeObj){this.name =  '%@'; this.nativeObj=nativeObj;",jsonArray[@"moduleName"],jsonArray[@"moduleName"]];
        //获取所有异步方法
        NSString * asyncLastMethods  = [self getAsyncMethods:jsonArray];
        //获取所有同步方法
        NSString * syncLastMethods  = [self getSycnMethods:jsonArray];
        
        if (asyncLastMethods) {
             moduleStringes = [moduleStringes stringByAppendingString:asyncLastMethods];
        }
        if (syncLastMethods) {
            moduleStringes = [moduleStringes stringByAppendingString:syncLastMethods];
        }
        
        moduleStringes = [moduleStringes stringByAppendingString:@"};"];
        
        if (tempModule.length!=0) {
            
                lastModule = [tempModule stringByAppendingString:moduleStringes];//最终拼接好的字符串
                tempModule = [tempModule stringByAppendingString:moduleStringes];
        }else{
                tempModule = moduleStringes;
        }
        
        // 只有一个模块时
        if ([jsonArrayObject count]==1) {
            
             lastModule = moduleStringes;
        }
        
        methodsName = nil;
        tempMethodsName= nil;
    }
}
// 获取同一模块下 所有的异步方法拼接的字符串
- (NSString *)getAsyncMethods:(id)jsonArray{
    
    tempMethodsName=@"";
    NSString *lastMethodsName=@"";
    for (NSString * tempMethod in jsonArray[@"methods"]) {
        
        methodsName = [NSString stringWithFormat:@"this.%@=function(){var op={};if(arguments && arguments.length){if(arguments.length  == 0){op.className = %@;op.methodName = '%@'; op.moduleName ='%@' ;op.nativeObj=this.nativeObj;  return  ytfNativeBridget(op);}else if(arguments.length  == 1 && typeof arguments[0]!='function' ){op.args=arguments[0];op.className = '%@';op.methodName = '%@'; op.moduleName ='%@' ;op.nativeObj=this.nativeObj; return  ytfNativeBridget(op);}else if(arguments.length  == 1 && typeof arguments[0]==='function' ){op.className = '%@';op.methodName = '%@'; op.moduleName =%@ ; op.nativeObj=this.nativeObj; op.cbId='%@'+YTFcb.id++;YTFcb.fn[op.cbId]=arguments[0];return  ytfNativeBridget(op);}else if(arguments.length  == 2 && typeof arguments[1]==='function' ){op.args=arguments[0];op.className = '%@';op.methodName = '%@'; op.moduleName ='%@' ;op.nativeObj=this.nativeObj;  op.cbId='%@'+YTFcb.id++;YTFcb.fn[op.cbId]=arguments[1];return  ytfNativeBridget(op);}}else{op.className = '%@';op.methodName = '%@'; op.moduleName ='%@' ;op.nativeObj=this.nativeObj; return  ytfNativeBridget(op);}}; ",tempMethod,jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"],jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"],jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"],tempMethod,jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"],tempMethod,jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"]];
        
        if (tempMethodsName.length!=0) {
            lastMethodsName = [tempMethodsName stringByAppendingString:methodsName];
            tempMethodsName = [tempMethodsName stringByAppendingString:methodsName];
        }else{
            tempMethodsName = methodsName;
        }
    }

    if ([jsonArray[@"methods"] count]==1) {
        
         return methodsName;
    }
    
    return lastMethodsName;
}

// 获取同一模块下 所有的同步方法拼接的字符串
- (NSString *)getSycnMethods:(id)jsonArray{

    NSString * syncMethodsName;
    NSString * syncTempMethodsName=@"";
    NSString * syncLastMethods=@"";
    for (NSString * tempMethod in jsonArray[@"syncMethods"])
    {
        syncMethodsName = [NSString stringWithFormat:@"this.%@=function(){var op={};if(arguments && arguments.length){if(arguments.length  == 0){op.className = %@;op.methodName = '%@'; op.moduleName ='%@' ;op.nativeObj=this.nativeObj;  return  ytfNativeBridget(op);}else if(arguments.length  == 1 && typeof arguments[0]!='function' ){op.args=arguments[0];op.className = '%@';op.methodName = '%@'; op.moduleName ='%@' ;op.nativeObj=this.nativeObj; return  ytfNativeBridget(op);}else if(arguments.length  == 1 && typeof arguments[0]==='function' ){op.className = '%@';op.methodName = '%@'; op.moduleName =%@ ; op.nativeObj=this.nativeObj; op.cbId='%@'+YTFcb.id++;YTFcb.fn[op.cbId]=arguments[0];return  ytfNativeBridget(op);}else if(arguments.length  == 2 && typeof arguments[1]==='function' ){op.args=arguments[0];op.className = '%@';op.methodName = '%@'; op.moduleName ='%@' ;op.nativeObj=this.nativeObj;  op.cbId='%@'+YTFcb.id++;YTFcb.fn[op.cbId]=arguments[1];return  ytfNativeBridget(op);}}else{op.className = '%@';op.methodName = '%@'; op.moduleName ='%@' ;op.nativeObj=this.nativeObj;  return  ytfNativeBridget(op);}}; ",tempMethod,jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"],jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"],jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"],tempMethod,jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"],tempMethod,jsonArray[@"class"],tempMethod,jsonArray[@"moduleName"]];
        
        if (syncTempMethodsName.length != 0)
        {
            syncLastMethods = [syncTempMethodsName stringByAppendingString:syncMethodsName];
            syncTempMethodsName = [syncTempMethodsName stringByAppendingString:syncMethodsName];
        } else
        {
            syncTempMethodsName = syncMethodsName;
        }
    }
    
    if ([jsonArray[@"syncMethods"] count] == 1)
    {
        return syncMethodsName;
    }
    
    return syncLastMethods;
}

- (void)insertModuleStringWithWebView:(UIWebView *)webView
{
    // 将需要注入的字符串叠加
    NSString *allMyJsStr = @"";
    // 最终需要注入的js总字符串
    NSString *jsString = nil;
    
    NSDictionary *functionNameDictionary = @{@"winOpen" : @"ytfwinOpen",
                                             @"winClose" : @"ytfwinClose",
                                             @"winCloseToWin" : @"ytfCloseToWin",
                                             @"frameGroupOpen" : @"ytfframeGroupOpen",
                                             @"frameGroupClose" : @"ytfframeGroupClose",
                                             @"frameGroupSetIndex" : @"ytffframeGroupSetIndex",
                                             @"frameGroupSetAttr" : @"ytfframeGroupSetAttr",
                                             @"frameOpen" : @"ytfframeOpen",
                                             @"frameClose" : @"ytfframeClose",
                                             @"frameActive" : @"ytfframeActive",
                                             @"frameDisactive" : @"ytfframeDisactive",
                                             @"frameSetAttr" : @"ytfFrameSetAttr",
                                             @"drawerWinOpen" : @"ytfdrawerWinOpen",
                                             @"drawerOpen" : @"ytfDrawerOpen",
                                             @"drawerClose" : @"ytfDrawerClose",
                                             @"drawerWinClose" : @"ytfdrawerWinClose",
                                             @"ajax" : @"ytfajax",
                                             @"ajaxDownload" : @"ytfAjaxDownload",
                                             @"excNative" : @"ytfExcNative",
                                             @"excJs" : @"ytfExcJs",
                                             @"cancelDownload" : @"ytfCancelDownload",
                                             @"eventListenerAdd" : @"ytfEventListenerAdd",
                                             @"eventSend" : @"ytfEventSend",
                                             @"eventListenerRm" : @"ytfeventListenerRm",
                                             @"alert" : @"ytfwebUIAlert",
                                             @"confirm" : @"ytfwebUIConfirm",
                                             @"prompt" : @"ytfwebUIPrompt",
                                             @"showProgress" : @"ytfShowCustomProgress",
                                             @"hideProgress" : @"ytfHideCustomProgress",
                                             @"toast" : @"ytfToast",
                                             @"mediaGetPicture" : @"ytfMediaGetPicture",
                                             @"launchRemove" : @"ytfLaunchRemove",
                                             @"appClose" : @"ytfAppClose",
                                             @"webUISetPullRefresh" : @"ytfwebUISetPullRefresh",
                                             @"webUIPullRefreshDone" : @"ytfwebUIPullRefreshDone",
                                             @"webUIPullRefreshLoading" : @"ytfwebUIPullRefreshLoading",
                                             @"webUIPullRefreshListener" : @"ytfwebUIPullRefreshListener",
                                             @"webUIAlert" : @"ytfwebUIAlert",
                                             @"webUIConfirm" : @"ytfwebUIConfirm",
                                             @"webUIPrompt" : @"ytfwebUIPrompt",
                                             @"webUIShowProgress" : @"ytfShowProgress",
                                             @"webUIHideProgress" : @"ytfwebUIHideProgress",
                                             @"webUIToast" : @"ytfToast",
                                             @"webUISetPullDownRefresh" : @"ytfWebUISetPullDownRefresh",
                                             @"webUIPullDownOpenRefresh" : @"ytfWebUIPullDownOpenRefresh",
                                             @"webUIPullDownCloseRefresh" : @"ytfWebUIPullDownCloseRefresh",
                                             @"webUIShowPopupWindow" : @"ytfWebUIShowPopupWindow",
                                             @"webUIHidePopupWindow" : @"ytfWebUIHidePopupWindow",
                                             @"webUISetPullUpLoading" : @"ytfWebUISetPullUpLoading",
                                             @"webUIPullUpOpenLoading" : @"ytfWebUIPullUpOpenLoading",
                                             @"webUIPullUpCloseLoading" : @"ytfWebUIPullUpCloseLoading",
                                             @"setPullRefresh" : @"ytfwebUISetPullRefresh",
                                             @"pullRefreshDone" : @"ytfwebUIPullRefreshDone",
                                             @"pullRefreshLoading" : @"ytfwebUIPullRefreshLoading",
                                             @"pullRefreshListener" : @"ytfwebUIPullRefreshListener",
                                             @"alert" : @"ytfwebUIAlert",
                                             @"confirm" : @"ytfwebUIConfirm",
                                             @"prompt" : @"ytfwebUIPrompt",
                                             @"showProgress" : @"ytfShowProgress",
                                             @"hideProgress" : @"ytfwebUIHideProgress",
                                             @"toast" : @"ytfToast",
                                             @"setPullDownRefresh" : @"ytfWebUISetPullDownRefresh",
                                             @"pullDownOpenRefresh" : @"ytfWebUIPullDownOpenRefresh",
                                             @"pullDownCloseRefresh" : @"ytfWebUIPullDownCloseRefresh",
                                             @"showPopupWindow" : @"ytfWebUIShowPopupWindow",
                                             @"hidePopupWindow" : @"ytfWebUIHidePopupWindow",
                                             @"setPullUpLoading" : @"ytfWebUISetPullUpLoading",
                                             @"pullUpOpenLoading" : @"ytfWebUIPullUpOpenLoading",
                                             @"pullUpCloseLoading" : @"ytfWebUIPullUpCloseLoading",
                                             @"config3DTouchMenu" : @"ytfConfig3DTouchMenu",
                                             @"config3DTouchListener" : @"ytfConfig3DTouchListener",
                                             @"getNetStatus" : @"ytfGetNetStatus"};
    
    NSArray *nativeFunctionArr = [functionNameDictionary allValues];
    NSArray *jsFunctionArr = [functionNameDictionary allKeys];
    
    for (int index = 0; index < jsFunctionArr.count; index++)
    {
        NSString *addObject = [NSString stringWithFormat:@"  "" %@:function(){var op={};if(arguments.length===1){if(typeof arguments[0]==='function'){op.cbId='%@'+YTFcb.id++;YTFcb.fn[op.cbId]=arguments[0]}else{op.args=arguments[0]}}else{if(arguments.length===2){op.args=arguments[0];op.cbId='%p---' + '%@'+YTFcb.id++;YTFcb.fn[op.cbId]=arguments[1]}};return %@ (op);},",jsFunctionArr[index],jsFunctionArr[index], webView,jsFunctionArr[index],nativeFunctionArr[index]];
        allMyJsStr = [allMyJsStr stringByAppendingString:addObject];
    }

    // 模块方法
    allMyJsStr = [allMyJsStr stringByAppendingString:[NSString stringWithFormat:@"require : function() {var op = {};op.moduleName= arguments[0]; var arg = arguments[0];  var nativeObj = ytfRequireNative(op);if(nativeObj==null)return null; var strTmp ='new ' + arg + '(nativeObj)' ;var obj = eval('('+strTmp+')'); return obj;},"]];
    
    // HtmlParam 转换json对象
    allMyJsStr = [allMyJsStr stringByAppendingString:[NSString stringWithFormat:@"getHtmlParam : function() {var htmlParamStr = YTF.htmlParam;try{return JSON.parse(htmlParamStr);}catch(e){return htmlParamStr;}},"]];
 
    //拼接 模块 Module
    [self moduleStringFunction];
    
    NSString *constant = [NSString new];
    // 设备信息
    NSArray *arrayDeviceInfo = [DeviceInfoManager deviceInfoArray];
    // 窗口信息 注入htmlParam
    NSArray *arrayWindowInfo = [WindowInfoManager windowInfoArray];
    
    NSMutableArray *arrayInsertJS = [NSMutableArray new];
    [arrayInsertJS addObjectsFromArray:arrayDeviceInfo];
    [arrayInsertJS addObjectsFromArray:arrayWindowInfo];
    
    for (int index = 0; index <arrayInsertJS.count; index ++) {
        constant = [constant stringByAppendingString:[NSString stringWithFormat:@"%@:'%@',",[arrayInsertJS[index] allKeys][0],[arrayInsertJS[index] allValues][0]]];
    }
    
    allMyJsStr = [allMyJsStr stringByAppendingString:constant];
    
    jsString = [NSString stringWithFormat:@"javascript:window.onerror=fnErrorTrap;function fnErrorTrap(sMsg,sUrl,sLine){var errObj={}; errObj.sMsg = sMsg;errObj.sUrl = sUrl; errObj.sLine = sLine;ytfError(errObj);}window.YTFcb={fn:{},id:1,on:function(cbId,ret,err,del){var retObj=null;var errObj=null; if('' != ret) {try{retObj = JSON.parse(ret);}catch(e){retObj=ret}}if('' != err) {errObj = JSON.parse(err);}this.fn[cbId]&&this.fn[cbId](retObj,errObj);if(del){delete this.fn[cbId]}},gc:function(cbId){delete this.fn[cbId]}};%@ window.YTF={%@};if(window.ytfready){YTF.htmlParam=YTF.getHtmlParam();window.ytfready()};",lastModule,allMyJsStr];
    
    [webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // 配置Webview的 idEdit属性
    if (((BaseWebView *)webView).isEdit == false)
    {
        [webView stringByEvaluatingJavaScriptFromString:Default_isEditConfuse];
    } else {
        [webView stringByEvaluatingJavaScriptFromString:Default_isEditAllow];
    }
    
    if (((BaseWebView *)webView).isGroupFrame)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PreloadNotification object:@{@"frameGroupName" : ((BaseWebView *)webView).frameGroupName,
                                                                                                @"index" : [NSString stringWithFormat:@"%lu", (unsigned long)((BaseWebView *)webView).groupFrameIndex]}];
    }
    
    
    
    //DLog(@"2 webView = %p", webView);
}


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
          NSString *requestString = [[request URL] absoluteString];
          NSArray *components = [requestString componentsSeparatedByString:@":"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"myweb"]) {
          if([(NSString *)[components objectAtIndex:1] isEqualToString:@"touch"])
  {
               }
        return NO;
    }
    return YES;
}


#pragma mark - Keyboard Animation

- (void)keyboardWillShow:(NSNotification *)notification
{
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // 获取info同上面的方法
    // 你的操作，如键盘移除，控制视图还原等
}


/**
 当插件销毁时 发送通知 更换代理

 @param notification
 */
- (void)pluginChangeDelegate:(NSNotification *)notification{
  
    [AppDelegate shareAppDelegate];

}

- (void)moduleViewGuestureNotific:(NSNotification *)notification{

    UIView * moduelVC = notification.userInfo[@"object"];
    [moduelVC addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moduleViewCloseWinPan:)]];

}

- (void)moduleViewOpenDrawerGuestureNotific:(NSNotification *)notification{

    UIView * moduelVC = notification.userInfo[@"object"];
    [moduelVC addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moduleViewOpenDrawerPan:)]];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  //  NSLog(@"UIViewController will rotate to Orientation: %ld", (long)toInterfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  //  NSLog(@"did rotated to new Orientation, view Information %@", self.view);
}

#pragma mark - ModuleView
- (void)moduleViewCloseWinPan:(UIPanGestureRecognizer *)slipClosePan{

    BaseWebView * targetWeb = (BaseWebView *)(((slipClosePan.view).superview));
    [[SlipCloseWinGuesterManager shareInstance] sideSlipCloseWinPanGuester:targetWeb
                                                                  isWinWebView:NO
                                                                  closeGuester:slipClosePan
                                                                  isModuleView:YES];
}

- (void)moduleViewOpenDrawerPan:(UIPanGestureRecognizer *)openDrawerGuester{
    BaseWebView * targetWeb  = (BaseWebView *)(((openDrawerGuester.view).superview));
    UIView  *targetSuperView = targetWeb.superview;
    
    BaseWebView *  sideWebView;
    BaseWebView *mainWeb = self.appDelegate.baseViewController.view.subviews.lastObject;
    for (BaseWebView *baseWebView in self.appDelegate.baseViewController.view.subviews)
    {
        if ([baseWebView.drawerWinName isEqualToString:mainWeb.drawerWinName] && baseWebView!=mainWeb) {
            sideWebView = baseWebView;
        }
    }
    if ([targetSuperView isMemberOfClass:[UIScrollView class]]) {
        
        BaseWebView * winWeb = (BaseWebView *)(targetSuperView.superview);
        [[PanGeusterDelegateClass shareInshance] groupSidePanGuester:winWeb sideWin:sideWebView
                                                             guester:openDrawerGuester
                                                            leftEdge:[[YTFConfigManager shareConfigManager] configLeftEdge:winWeb.leftEdge]
                                                            leftZone:[[YTFConfigManager shareConfigManager] configLeftZone:winWeb.leftZone] leftScale:winWeb.leftScale];
        
    }else if ([targetSuperView isMemberOfClass:[BaseWebView class]]){
    
        [[PanGeusterDelegateClass shareInshance] frameSidePanGuester:((BaseWebView *)targetSuperView) sideWin:sideWebView
                                    guester:openDrawerGuester
                                   leftEdge:[[YTFConfigManager shareConfigManager] configLeftEdge:((BaseWebView *)targetSuperView).leftEdge]
                                   leftZone:[[YTFConfigManager shareConfigManager] configLeftZone:((BaseWebView *)targetSuperView).leftZone]
                                  leftScale:((BaseWebView *)targetSuperView).leftScale];
    }

    
}


/**
 初始化 index.html入口文件
 */
- (void)customWidgetTest{

#ifdef DecryMode

    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"assets/widget/config.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:configFilePath];
    
    if (data == nil)
    {
        return;
    }
    
    NSData *decryData = [RC4DecryModule dataDecry_RC4WithByteArray:(Byte *)[data bytes] key:DecryKey fileData:data];
    NSDictionary *dicJson = [NSJSONSerialization JSONObjectWithData:decryData options:NSJSONReadingMutableContainers error:nil];
    NSString *indexPathString =dicJson[@"indexSrc"];
    indexPathString = [NSString stringWithFormat:@"%@%@",IndexHtmlUrl,indexPathString];
#else
    
    // app 资源文件
    NSString *indexPathString = [ToolsFunction JsonFileToDictionaryWithFileRelativePath:@"assets/widget/config.json"][@"indexSrc"];
    indexPathString = [NSString stringWithFormat:@"%@%@",IndexHtmlUrl,indexPathString];
    
#endif
    
    self.indexWebView = [[BaseWebView alloc] initWithFrame:CGRectMake(0, AppStatusBarHeight, ScreenWidth, ScreenHeight - AppStatusBarHeight)
                                                       url:[[NSBundle mainBundle] pathForResource:indexPathString ofType:nil]
                                                  isWindow:true];
    
    self.indexWebView.winName = @"index";
    self.indexWebView.delegate = self;
    [self.view addSubview:self.indexWebView];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    DLog(@"webSocketDidOpen");
    
    NSString *stringSend = [NSString stringWithFormat:@"{'commanId':2,'appId':'%@'}", [[NSUserDefaults standardUserDefaults] objectForKey:@"appId"]];
    
    NSError *error;
    [_webSocket sendString:stringSend error:&error];
    DLog(@"error = %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    DLog(@"didFailWithError");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSData *dataJson = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dicJson = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:nil];
    [[YTFConfigManager shareConfigManager] setLoaderParam:dicJson];
    self.indexWebView = [[BaseWebView alloc] initWithFrame:CGRectMake(0, AppStatusBarHeight, ScreenWidth, ScreenHeight - AppStatusBarHeight)
                                                       url:[NSString stringWithFormat:@"http://%@:%@/%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEHost], [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEWebPort],[YTFConfigManager shareConfigManager].appId, [YTFConfigManager shareConfigManager].indexSrc]
                         
                                                  isWindow:true];
     self.indexWebView.delegate = self;
    [self.view addSubview:self.indexWebView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat statusBarHeight = 20;
        if (![[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
        {
            statusBarHeight = 0;
        }
        [self.indexWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(statusBarHeight);
            make.bottom.equalTo(self.view).with.offset(0);
            make.left.equalTo(self.view).with.offset(0);
            make.right.equalTo(self.view).with.offset(0);
        }];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    DLog(@"didCloseWithCode");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    DLog(@"didReceivePong");
}




@end
