/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic userinterface manager.
 * =============================================================================
 */

#import "UIControlManager.h"
#import "AppDelegate.h"
#import "Definition.h"
#import "UIImage+YTFGIF.h"
#import "BaseViewController.h"
#import "MBProgressHUD.h"
#import "PathProtocolManager.h"
#import "UIScrollView+MJRefresh.h"
#import "YTFConfigManager.h"
#import "WindowInfoManager.h"
#import "YTFAnimationManager.h"
#import "YTFSDImageCache.h"
#import "FrameManager.h"
#import "NetworkManager.h"
#import "ToolsFunction.h"
#import "UIImageView+YTFWebCache.h"
#import "AppSingleton.h"
#import "Masonry.h"

@interface UIControlManager ()

@property (nonatomic, strong) NSString *setPullCbId; // 刷新 方法cbid
@property (nonatomic, strong) NSString *setUpPullCbId; // 上拉加载 方法cbid
@property (nonatomic, strong) NSString *setAlertCbId; // alert 方法cbid

@property (nonatomic, strong) NSString *textFieldContent; // prompt输入内容
@property (nonatomic, strong) NSString *selectButtonIndex; // 选择的按钮索引

@property (nonatomic, weak) BaseWebView *customWebView;


@end

@implementation UIControlManager

- (instancetype)init
{
    if (self == [super init])
    {
        
    }
    
    return self;
}

#pragma mark - Refresh


/**
 *  上拉加载
 *
 *  @param webView JSContext
 */
- (void)setPullUpRefreshWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfWebUISetPullUpLoading"] = ^() {
        
        /*
              isShow:true,
         　　　imgUrl:"widget/image/aa.png",
         　　　bgColor:"rgba(255,255,255,255)",
         　　　textColor:"rgba(109, 128, 153, 255)",
         　　　textDown:"上拉可以刷新...",
         　　　textUp:"松开可以刷新...",
         　　　textLoading:"加载中...",
         　　　textUpdateTime:"2016.10.12",
         　　　isShowUpdateTime:true
         */
        
        _setUpPullCbId = [ToolsFunction JSContextCBID];
        _customWebView = weakwebView;
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        // 默认
        if (dicArgs[@"imgUrl"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakwebView.scrollView.mj_footer = [weakself setGifImageFooterWithArgsDictionary:dicArgs];
            });
            
        } else {
            // 默认
            dispatch_async(dispatch_get_main_queue(), ^{
                weakwebView.scrollView.mj_footer = [weakself setNormalFooterWithArgsDictionary:dicArgs webView:weakwebView];
            });
        }
        
        if ([dicArgs[@"isShow"] boolValue] == true)
        {
            weakwebView.scrollView.mj_footer.hidden = false;
        } else {
            weakwebView.scrollView.mj_footer.hidden = true;
        }
    };
}

/**
 *  设置上拉加载组建为刷新状态
 *
 *  @param webView JSContext
 */
- (void)pullUpRefreshLoadingWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfWebUIPullUpOpenLoading"] = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakwebView.scrollView.mj_footer beginRefreshing];
        });
    };
}

/**
 *  通知上拉加载数据加载完毕，回复到默认状态，下拉刷新结束
 *
 *  @param webView JSContext
 */
- (void)pullUpRefreshDoneWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfWebUIPullUpCloseLoading"] = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[YTFSDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
            [[YTFSDImageCache sharedImageCache] clearMemory];
            [weakwebView.scrollView.mj_footer endRefreshing];
        });
        
        weakwebView.scrollView.mj_footer.endRefreshingCompletionBlock = ^(){
            [weakself performSelectorOnMainThread:@selector(mainThreadPullUpRefreshDoneWithWebView:) withObject:_customWebView waitUntilDone:NO];
        };
    };
}

/**
 *  下拉刷新
 *
 *  @param webView JSContext
 */
- (void)setPullRefreshWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfWebUISetPullDownRefresh"] = ^() {
        /*
         JSContextCBID = webUISetPullRefresh1 
         {
         bgColor
         imgUrl = "../images/default_ptr_rotate.png";
         isShow = 1;
         isShowUpdateTime = 1;
         textColor = "#FF0191F7";
         textDown = "\U4e0b\U62c9\U53ef\U4ee5\U5237\U65b0";
         textLoading = "\U52a0\U8f7d\U4e2d";
         textUp = "\U677e\U5f00\U53ef\U4ee5\U5237\U65b0";
         textUpdateTime = "5\U5e74\U524d";
         }
         */
        
        _setPullCbId = [ToolsFunction JSContextCBID];
        _customWebView = weakwebView;
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        // 设置header  scrollView 本身没有 mj_header 属性 因为mj 做了类扩展 而在 #import "MJRefresh.h" 间接引入了那个类扩展文件 所以这里能引用
        if (dicArgs[@"imgUrl"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
               weakwebView.scrollView.mj_header = [weakself setGifImageHeaderWithArgsDictionary:dicArgs];
            });
            
        } else {
            // 默认
            dispatch_async(dispatch_get_main_queue(), ^{
                weakwebView.scrollView.mj_header = [weakself setNormalHeaderWithArgsDictionary:dicArgs webView:weakwebView];
            });
        }
        
        if ([dicArgs[@"isShow"] boolValue] == true)
        {
            weakwebView.scrollView.mj_header.hidden = false;
        } else {
            weakwebView.scrollView.mj_header.hidden = true;
        }
    };
}
/**
 *  设置下拉刷新组建为刷新状态
 *
 *  @param webView JSContext
 */
- (void)pullRefreshLoadingWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfWebUIPullDownOpenRefresh"] = ^() {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakwebView.scrollView.mj_header beginRefreshing];
        });
    };
}

/**
 *  通知下拉刷新数据加载完毕，回复到默认状态，下拉刷新结束
 *
 *  @param webView JSContext
 */
- (void)pullRefreshDoneWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfWebUIPullDownCloseRefresh"] = ^() {//

        dispatch_async(dispatch_get_main_queue(), ^{
            [[YTFSDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
            [[YTFSDImageCache sharedImageCache] clearMemory];
            [weakwebView.scrollView.mj_header endRefreshing];
        });
        
        weakwebView.scrollView.mj_header.endRefreshingCompletionBlock = ^(){
            [weakself performSelectorOnMainThread:@selector(mainThreadPullRefreshDoneWithWebView:) withObject:_customWebView waitUntilDone:NO];
        };
    };
}


#pragma mark - Alert

/**
 *  弹出框
 *
 *  @param webView JSContext
 */
- (void)alertWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfwebUIAlert"] = ^() {
    
        _setAlertCbId = [ToolsFunction JSContextCBID];
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        /*
         {
         buttons =     (
         "\U786e\U5b9a"
         );
         msg = "\U6d4b\U8bd5\U5185\U5bb9";
         title = "\U63d0\U793a\U6846";
         }
         */
        
        UIAlertController *vwcAlert = [UIAlertController alertControllerWithTitle:dicArgs[@"title"] message:dicArgs[@"msg"] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:((NSArray *)dicArgs[@"buttons"])[0] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            _selectButtonIndex = [NSString stringWithFormat:@"1"];
            [weakself performSelectorOnMainThread:@selector(mainThreadSelectAlertButtonWithWebView:) withObject:weakwebView waitUntilDone:NO];
        }];
        [vwcAlert addAction:okAction];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[AppDelegate shareAppDelegate].baseViewController presentViewController:vwcAlert animated:true completion:nil];
        });
    };
}

/**
 *  弹出带两个或者三个按钮的confirm对话框
 *
 *  @param webView JSContext
 */
- (void)confirmWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfwebUIConfirm"] = ^()
    {
        _setAlertCbId = [ToolsFunction JSContextCBID];
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        /*
         {
         buttons =     (
         "\U786e\U5b9a",
         "\U5ffd\U7565",
         "\U53d6\U6d88"
         );
         msg = "\U6d4b\U8bd5\U5185\U5bb9";
         title = "\U63d0\U793a\U6846";
         }
         */
        
        UIAlertController *vwcAlert = [UIAlertController alertControllerWithTitle:dicArgs[@"title"] message:dicArgs[@"msg"] preferredStyle:UIAlertControllerStyleAlert];
        
        if (((NSArray *)dicArgs[@"buttons"]).count > 0)
        {
            for (int i = 0; i < ((NSArray *)dicArgs[@"buttons"]).count; i++)
            {
                if ([((NSArray *)dicArgs[@"buttons"])[i] isEqualToString:@"取消"])
                {
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                    {
                        _selectButtonIndex = [NSString stringWithFormat:@"%d", i+1];
                        [weakself performSelectorOnMainThread:@selector(mainThreadSelectAlertButtonWithWebView:) withObject:weakwebView waitUntilDone:NO];
                    }];
                    [vwcAlert addAction:cancelAction];
                } else {
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:((NSArray *)dicArgs[@"buttons"])[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                    {
                        _selectButtonIndex = [NSString stringWithFormat:@"%d", i+1];
                        [weakself performSelectorOnMainThread:@selector(mainThreadSelectAlertButtonWithWebView:) withObject:weakwebView waitUntilDone:NO];
                    }];
                    [vwcAlert addAction:okAction];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AppDelegate shareAppDelegate].baseViewController presentViewController:vwcAlert animated:true completion:nil];
        });
    };
}

/**
 *  弹出带两个或三个按钮和输入框的对话框
 *
 *  @param webView JSContext
 */
- (void)promptWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfwebUIPrompt"] = ^() {
    
        _setAlertCbId = [ToolsFunction JSContextCBID];
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        /*
         {
         buttons =     (
         "\U786e\U5b9a",
         "\U5ffd\U7565",
         "\U53d6\U6d88"
         );
         msg = "\U6d4b\U8bd5\U5185\U5bb9";
         text = "\U8bf7\U8f93\U5165......";
         title = "\U63d0\U793a\U6846";
         type = number;
         }
         */
        UIAlertController *vwcAlert = [UIAlertController alertControllerWithTitle:dicArgs[@"title"] message:dicArgs[@"msg"] preferredStyle:UIAlertControllerStyleAlert];
        
        if (((NSArray *)dicArgs[@"buttons"]).count > 0)
        {
            for (int i = 0; i < ((NSArray *)dicArgs[@"buttons"]).count; i++)
            {
                if ([((NSArray *)dicArgs[@"buttons"])[i] isEqualToString:@"取消"])
                {
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                    {
                        _selectButtonIndex = [NSString stringWithFormat:@"%d", i+1];
                        [weakself performSelectorOnMainThread:@selector(mainThreadSelectAlertButtonWithWebView:) withObject:weakwebView waitUntilDone:NO];
                    }];
                    [vwcAlert addAction:cancelAction];
                } else {
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:((NSArray *)dicArgs[@"buttons"])[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                    {
                        _selectButtonIndex = [NSString stringWithFormat:@"%d", i+1];
                        
                        if (vwcAlert.textFields[0].text)
                        {
                            _textFieldContent = vwcAlert.textFields[0].text;
                        }
                        
                        [weakself performSelectorOnMainThread:@selector(mainThreadSelectAlertButtonWithWebView:) withObject:weakwebView waitUntilDone:NO];
                    }];
                     [vwcAlert addAction:okAction];
                }
            }
        }
        
        /*
         text：文本形式
         password：密码形式
         number：数字形式
         email：邮件形式
         url：网页地址形式
         */
        [vwcAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
        {
            textField.placeholder = dicArgs[@"text"];
            if ([dicArgs[@"type"] isEqualToString:@"text"])
            {
                textField.keyboardType = UIKeyboardTypeDefault;
            } else if ([dicArgs[@"type"] isEqualToString:@"password"])
            {
                textField.keyboardType = UIKeyboardTypeASCIICapable;
                textField.secureTextEntry = true;
            } else if ([dicArgs[@"type"] isEqualToString:@"number"])
            {
                textField.keyboardType = UIKeyboardTypeNumberPad;
            } else if ([dicArgs[@"type"] isEqualToString:@"email"])
            {
                textField.keyboardType = UIKeyboardTypeEmailAddress;
            } else if ([dicArgs[@"type"] isEqualToString:@"url"])
            {
                textField.keyboardType = UIKeyboardTypeURL;
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AppDelegate shareAppDelegate].baseViewController presentViewController:vwcAlert animated:true completion:nil];
        });
    };
}


#pragma mark - Gif

/**
 *  显示进度提示框
 *
 *  @param webView JSContext
 */
- (void)showProgressWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfShowProgress"] = ^() {
        
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        /*
         {
         bgColor = "#55333333";
         bottomText = "\U52a0\U8f7d\U4e2d\U00b7\U00b7\U00b7";
         gifSize =     {
         h = 63;
         w = 63;
         };
         imgUrl = "assets/widget/images/loading.gif";
         modal = 0;
         xywh =     {
         h = 120;
         w = 120;
         };
         }
         */
        
        for (UIView *subView in [AppDelegate shareAppDelegate].baseViewController.view.subviews)
        {
            if (subView.tag == Gif_View_Tag)
            {
                return;
            }
        }
        [FrameManager shareManager].progView = [[UIView alloc] init];
        [FrameManager shareManager].progView.tag = Gif_View_Tag;

        // 模态 全屏
        [FrameManager shareManager].progView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [[FrameManager shareManager].progView setUserInteractionEnabled:false];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [FrameManager shareManager].progView.backgroundColor = [ToolsFunction hexStringToColor:dicArgs[@"bgColor"]];
            
            UIImageView *imageViewGif = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [dicArgs[@"gifSize"][@"h"] floatValue], [dicArgs[@"gifSize"][@"h"] floatValue])];
            
            NSString *absolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicArgs[@"imgUrl"] excuteWebView:weakwebView];
            //判空处理
            if (absolutePath) {
                NSData *dataGif = [NSData dataWithContentsOfFile:absolutePath];
                imageViewGif.image = [UIImage sd_animatedGIFWithData:dataGif];
                imageViewGif.center = [FrameManager shareManager].progView.center;
                
                UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [dicArgs[@"xywh"][@"w"] floatValue], 20.0)];
                labelText.text = dicArgs[@"bottomText"];
                labelText.textAlignment = NSTextAlignmentCenter;
                labelText.center = CGPointMake(imageViewGif.center.x, CGRectGetMaxY(imageViewGif.frame) + 12.0);
                
                [[FrameManager shareManager].progView addSubview:imageViewGif];
                [[FrameManager shareManager].progView addSubview:labelText];
                
                [FrameManager shareManager].progView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
                
                [[AppDelegate shareAppDelegate].baseViewController.view addSubview:[FrameManager shareManager].progView];
                }
        });
    };
}

/**
 *  隐藏进度提示框
 *
 *  @param webView JSContext
 */
- (void)hideProgressWithWebView:(BaseWebView *)webView
{

    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfwebUIHideProgress"] = ^() {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [[YTFSDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
            [[YTFSDImageCache sharedImageCache] clearMemory];
            for (UIView *subView in [AppDelegate shareAppDelegate].baseViewController.view.subviews)
            {
                if (subView.tag == Gif_View_Tag)
                {
                    [[FrameManager shareManager].progView removeFromSuperview];
                }
            }
        });
    };
}

/**
 *  显示进度提示框
 *
 *  @param webView JSContext
 */
- (void)showCustomProgressWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfShowCustomProgress"] = ^() {
        
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        /*
         {
         modal:
         
         bgColor = "#ffffffff";
         
         bottomText = "\U52a0\U8f7d\U4e2d";
         bottomTextColor = "#ff999999";
         bottomTextSize:
         imgUrl = blue;
         
         gifSize:{
         　　w:50,     //宽度
         　　h:50      //高度
         }
         xywh:{
         　　w:100,     //宽度
         　　h:100      //高度
         }
         
         topText:
         topTextSize:
         topTextColor:
         }
         */

        for (UIView *subView in [AppDelegate shareAppDelegate].baseViewController.view.subviews)
        {
            if (subView.tag == Gif_View_Tag)
            {
                return;
            }
        }
        
        [FrameManager shareManager].progView = [[UIView alloc] init];
        [FrameManager shareManager].progView.tag = Gif_View_Tag;
        [FrameManager shareManager].progView.userInteractionEnabled = false;
        
        [FrameManager shareManager].progView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        
        UIView *viewSub = [[UIView alloc] init];
        viewSub.layer.cornerRadius = 10.0;
        viewSub.layer.masksToBounds = true;
        
        if (dicArgs[@"xywh"])
        {
            viewSub.frame = CGRectMake(0, 0, [dicArgs[@"xywh"][@"w"] floatValue], [dicArgs[@"xywh"][@"h"] floatValue]);
        } else {
            viewSub.frame = CGRectMake(0, 0, 100.0, 100.0);
        }
        
        if (dicArgs[@"modal"] && [dicArgs[@"modal"] boolValue] == false)
        {
            [AppDelegate shareAppDelegate].baseViewController.view.userInteractionEnabled = true;
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (dicArgs[@"bgColor"])
            {
                viewSub.backgroundColor = [ToolsFunction hexStringToColor:dicArgs[@"bgColor"]];
//                viewSub.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:0.0 blue:0.0 alpha:0.5];
            } else {
                viewSub.backgroundColor = [ToolsFunction hexStringToColor:@"#00FFFFFF"];
            }
            
            CGRect rect = CGRectZero;
            if (dicArgs[@"gifSize"])
            {
                rect = CGRectMake(0, 0, [dicArgs[@"gifSize"][@"w"] floatValue], [dicArgs[@"gifSize"][@"w"] floatValue]);
            } else {
                rect = CGRectMake(0, 0, 40.0, 40.0);
            }
            UIImageView *imageViewGif = [[UIImageView alloc] initWithFrame:rect];
            
            NSString *absolutePath = nil;
            if ([dicArgs[@"imgUrl"] hasPrefix:@"widget://"])
            {
                absolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicArgs[@"imgUrl"] excuteWebView:weakwebView];
            } else {
                if (dicArgs[@"imgUrl"] == nil)
                {
                    absolutePath = [[NSBundle mainBundle] pathForResource:@"ytf_loading_blue.gif" ofType:nil];
                } else {
                    absolutePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"ytf_loading_%@.gif", dicArgs[@"imgUrl"]] ofType:nil];
                }
            }
            
#ifdef Loader
            if(LoaderJudget){
            if ([[absolutePath lastPathComponent] isEqualToString:@"ytf_loading_blue.gif"])
            {
                [weakself configCustomProgressViewWithImageView:imageViewGif path:absolutePath paramDic:dicArgs middleView:viewSub];
            } else {
                if ([ToolsFunction isFileExistAtPath:[NSString stringWithFormat:@"%@/loader/%@loading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]]])
                {
                    [weakself configCustomProgressViewWithImageView:imageViewGif path:[NSString stringWithFormat:@"%@/loader/%@loading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]] paramDic:dicArgs middleView:viewSub];
                } else {
                    YTFAFHTTPSessionManager *manager =[NetworkManager sharedHTTPSession];
                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:absolutePath]];
                    NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                        
                        NSString *fullPath = [NSString stringWithFormat:@"%@/loader/%@loading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]];
                        [ToolsFunction createDirectoryWithPath:[[NSString stringWithFormat:@"%@/loader/%@loading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]] stringByDeletingLastPathComponent]];
                        return [NSURL fileURLWithPath:fullPath];
                        
                    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (error)
                            {
                                DLog(@"%@", error);
                            } else {
                                [weakself configCustomProgressViewWithImageView:imageViewGif path:[NSString stringWithFormat:@"%@/loader/%@loading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]] paramDic:dicArgs middleView:viewSub];
                            }
                            
                        });
                        
                    }];
                    // 3.执行Task
                    [download resume];
                }
            }
                
            }else{
            
            [weakself configCustomProgressViewWithImageView:imageViewGif path:absolutePath paramDic:dicArgs middleView:viewSub];
            }
#else
            [weakself configCustomProgressViewWithImageView:imageViewGif path:absolutePath paramDic:dicArgs middleView:viewSub];
#endif
            
        });
    };
}

- (void)configCustomProgressViewWithImageView:(UIImageView *)imageViewGif path:(NSString *)absolutePath paramDic:(NSDictionary *)dicArgs middleView:(UIView *)middleView
{
    NSData *dataGif = [NSData dataWithContentsOfFile:absolutePath];
    imageViewGif.image = [UIImage sd_animatedGIFWithData:dataGif];
    imageViewGif.center = middleView.center;
    
    UILabel *labelTextTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20.0)];
    labelTextTop.text = dicArgs[@"topText"] ? dicArgs[@"topText"] : @"";
    labelTextTop.font = dicArgs[@"topTextSize"] ? [UIFont systemFontOfSize:[dicArgs[@"topTextSize"] floatValue]] : [UIFont systemFontOfSize:12.0];
    labelTextTop.textColor = dicArgs[@"topTextColor"] ? [ToolsFunction hexStringToColor:dicArgs[@"topTextColor"]] : [ToolsFunction hexStringToColor:@"#CCCCCC"];
    labelTextTop.textAlignment = NSTextAlignmentCenter;
    labelTextTop.center = CGPointMake(imageViewGif.center.x, CGRectGetMinY(imageViewGif.frame) - 10.0);
    
    UILabel *labelTextBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20.0)];
    labelTextBottom.text = dicArgs[@"bottomText"] ? dicArgs[@"bottomText"] : @"";
    labelTextBottom.font = dicArgs[@"bottomTextSize"] ? [UIFont systemFontOfSize:[dicArgs[@"bottomTextSize"] floatValue]] : [UIFont systemFontOfSize:12.0];
    labelTextBottom.textColor = dicArgs[@"bottomTextColor"] ? [ToolsFunction hexStringToColor:dicArgs[@"bottomTextColor"]] : [ToolsFunction hexStringToColor:@"#CCCCCC"];
    labelTextBottom.textAlignment = NSTextAlignmentCenter;
    labelTextBottom.center = CGPointMake(imageViewGif.center.x, CGRectGetMaxY(imageViewGif.frame) + 10.0);
    
    [middleView addSubview:imageViewGif];
    [middleView addSubview:labelTextBottom];
    [middleView addSubview:labelTextTop];
    
    middleView.center = [FrameManager shareManager].progView.center;
    [FrameManager shareManager].progView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    
    [[FrameManager shareManager].progView addSubview:middleView];
    [[AppDelegate shareAppDelegate].baseViewController.view addSubview:[FrameManager shareManager].progView];
    
    if (!dicArgs[@"modal"] || (dicArgs[@"modal"] && [dicArgs[@"modal"] boolValue] == true))
    {
        [AppDelegate shareAppDelegate].baseViewController.view.userInteractionEnabled = false;
    }
}


/**
 *  隐藏进度提示框
 *
 *  @param webView JSContext
 */
- (void)hideCustomProgressWithWebView:(BaseWebView *)webView
{
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfHideCustomProgress"] = ^() {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[YTFSDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
            [[YTFSDImageCache sharedImageCache] clearMemory];
            for (UIView *subView in [AppDelegate shareAppDelegate].baseViewController.view.subviews)
            {
                if (subView.tag == Gif_View_Tag)
                {
                    [subView removeFromSuperview];
                    [AppDelegate shareAppDelegate].baseViewController.view.userInteractionEnabled = true;
                }
            }
        });
    };
}

#pragma mark - Toast

/**
 *  自动关闭的提示框toast
 *
 *  @param webView JSContext
 */
- (void)toastWithWebView:(BaseWebView *)webView
{
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfToast"] = ^()
    {
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        /*
         {
         duration = 2000;
         global = 0;
         location = middle;
         msg = "\U6d4b\U8bd5\U5f39\U7a97";
         }
         */

        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[AppDelegate shareAppDelegate].baseViewController.view animated:YES];
            
            // Set the annular determinate mode to show task progress.
            hud.mode = MBProgressHUDModeText;
            hud.label.text = dicArgs[@"msg"];

            [hud hideAnimated:YES afterDelay:1.f];
        });
    };
}

#pragma mark - PopView

/**
 *  显示pop弹窗
 *
 *  @param webView JSContext
 */
- (void)popViewWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(webView);
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfWebUIShowPopupWindow"] = ^()
    {
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        /*
         popName:
         htmlUrl:
         rect:{
         　　x:-1,//可选，自定义X轴距离，当设定X值时，location属性将失效，但动画效果任然有效
         　　y:-1,//可选，自定义Y轴距离，当设定Y值时，location属性将失效，但动画效果任然有效
         　　w:0,//可选，宽度，默认为0，全屏宽度
         　　h:200,//可选，高度，默认200
         　　ax:0,//动画起始位置在X轴坐标
            ay:0,//动画起始位置在y轴坐标
         }
         parentBackground:
         childBackground:
         htmlParam:
         isBounces:
         isVScrollBar:
         isHScrollBar:
         isScale:
         isEdit:
         modal:
         animation:
         modalBackground:
         modalType:
         */
        
        if ([AppDelegate shareAppDelegate].baseViewController.popView == nil)
        {
            [AppDelegate shareAppDelegate].baseViewController.popView = [[UIView alloc] init];
        }
        
        if (dicArgs[@"htmlParam"])
        {
            [WindowInfoManager shareManager].htmlParam = [[ToolsFunction dictionaryToJsonString:dicArgs[@"htmlParam"]] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        if (dicArgs[@"modalBackground"] == nil)
        {
            [AppDelegate shareAppDelegate].baseViewController.popView.backgroundColor = [UIColor clearColor];
            
        } else {
            
            if ([dicArgs[@"modalBackground"] isEqualToString:@""])
            {
                [AppDelegate shareAppDelegate].baseViewController.popView.backgroundColor = [ToolsFunction hexStringToColor:@"#66000000"];
            } else {
                [AppDelegate shareAppDelegate].baseViewController.popView.backgroundColor = [ToolsFunction hexStringToColor:dicArgs[@"modalBackground"]];
            }
            
            if (dicArgs[@"modalType"] && [dicArgs[@"modalType"] boolValue] == true)
            {
                // 处理modal出来的全屏view
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:weakself action:@selector(removePopView:)];
                [[AppDelegate shareAppDelegate].baseViewController.popView addGestureRecognizer:tapGestureRecognizer];
            }
        }
        
        
        NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicArgs[@"htmlUrl"] excuteWebView:weakwebView];
        
        CGRect rect = CGRectZero;

        if (dicArgs[@"rect"][@"x"] || dicArgs[@"rect"][@"y"])
        {
            CGFloat x = [dicArgs[@"rect"][@"x"] floatValue];
            CGFloat y = [dicArgs[@"rect"][@"y"] floatValue];
            CGFloat width = [dicArgs[@"rect"][@"w"] floatValue];
            CGFloat height = [dicArgs[@"rect"][@"h"] floatValue];
            if (width == 0.0)
            {
                width = ScreenWidth;
            }
            if (height == 0.0)
            {
                height = 200.0;
            }
            rect = CGRectMake(x, y, width, height);
        } else {
            CGFloat width = dicArgs[@"rect"][@"w"] == nil ? 0.0 : [dicArgs[@"rect"][@"w"] floatValue];
            CGFloat height = [dicArgs[@"rect"][@"h"] floatValue];
            
            if (width == 0.0)
            {
                width = ScreenWidth;
            }
            
            if (height == 0.0)
            {
                height = 200.0;
            }
            
            if ([dicArgs[@"rect"][@"location"] isEqualToString:@"bottom"])
            {
                rect = CGRectMake((ScreenWidth - width)/2, ScreenHeight - height, width, height);
            } else if ([dicArgs[@"rect"][@"location"] isEqualToString:@"top"])
            {
                rect = CGRectMake((ScreenWidth - width)/2, height, width, height);
            } else if ([dicArgs[@"rect"][@"location"] isEqualToString:@"middle"])
            {
                rect = CGRectMake((ScreenWidth - width)/2, (ScreenHeight - height)/2, width, height);
            }
        }
        
        BaseWebView *popWebView = [[BaseWebView alloc] initWithFrame:rect url:absoluteString isWindow:false];
        popWebView.delegate = [AppDelegate shareAppDelegate].baseViewController;
        
        if (dicArgs[@"childBackground"])
        {
            popWebView.backgroundColor = [ToolsFunction hexStringToColor:dicArgs[@"childBackground"]];
            [popWebView setOpaque:NO];
        } else {
            popWebView.backgroundColor = [ToolsFunction hexStringToColor:@"#00000000"];
        }
        
        popWebView.scrollView.showsVerticalScrollIndicator = dicArgs[@"isVScrollBar"] == nil ? false : [dicArgs[@"isVScrollBar"] boolValue];
        popWebView.scrollView.showsHorizontalScrollIndicator = dicArgs[@"isHScrollBar"] == nil ? false : [dicArgs[@"isHScrollBar"] boolValue];
        popWebView.scalesPageToFit = dicArgs[@"isScale"] == nil ? false : [dicArgs[@"isScale"] boolValue];

        popWebView.isEdit = [dicArgs[@"isEdit"] boolValue];//禁止长按编辑
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (![[AppDelegate shareAppDelegate].baseViewController.view.subviews containsObject:[AppDelegate shareAppDelegate].baseViewController.popView])
            {

                [[AppDelegate shareAppDelegate].baseViewController.popView addSubview:popWebView];
                [[AppDelegate shareAppDelegate].baseViewController.view addSubview:[AppDelegate shareAppDelegate].baseViewController.popView];
                
                if (dicArgs[@"modalBackground"] == nil)
                {
                    [[AppDelegate shareAppDelegate].baseViewController.popView mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        make.top.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(rect.origin.y);
                        make.left.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(rect.origin.x);
                        make.width.mas_equalTo(rect.size.width);
                        make.height.mas_equalTo(rect.size.height);
                    }];
                    
                    [popWebView mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        make.top.equalTo([AppDelegate shareAppDelegate].baseViewController.popView).with.offset(0);
                        make.left.equalTo([AppDelegate shareAppDelegate].baseViewController.popView).with.offset(0);
                        make.width.mas_equalTo(rect.size.width);
                        make.height.mas_equalTo(rect.size.height);
                    }];
                } else {
                    [[AppDelegate shareAppDelegate].baseViewController.popView mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        make.top.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(0);
                        make.bottom.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(0);
                        make.left.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(0);
                        make.right.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(0);
                    }];
                    
                    [popWebView mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        make.top.equalTo([AppDelegate shareAppDelegate].baseViewController.popView).with.offset(rect.origin.y);
                        make.left.equalTo([AppDelegate shareAppDelegate].baseViewController.popView).with.offset(rect.origin.x);
                        make.width.mas_equalTo(rect.size.width);
                        make.height.mas_equalTo(rect.size.height);
                    }];
                }
            }
        });
    };
}

/**
 *  隐藏pop弹窗
 *
 *  @param webView JSContext
 */
- (void)hidePopViewWithWebView:(BaseWebView *)webView
{
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfWebUIHidePopupWindow"] = ^()
    {
        /*
         popName:
         */
        
        [[AppDelegate shareAppDelegate].baseViewController.popView removeFromSuperview];
        [AppDelegate shareAppDelegate].baseViewController.popView = nil;
    };
}

#pragma mark - 3DTouch

/**
 添加3DTouch监听
 
 @param paramDictionary JS 参数
 */
- (void)config3DTouchListener:(BaseWebView *)webView
{
    /*
     {
     cbId：
     target：
     args：{
     type:                // 被点击的菜单的标识，字符串类型
     title:                //被点击的菜单标题，字符串类型
     subtitle:            //（可选项）被点击的菜单副标题，字符串类型
     userInfo:            //（可选项）自定义信息，JSON对象
     }
     
     }
     */

    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfConfig3DTouchListener"] = ^()
    {
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary];
        [AppSingleton shareManager].touchWebView = weakwebView;
        [AppSingleton shareManager].touchWebView.touchCbId = dicArgs[@"cbId"];
    };
}


/**
 设置3DTouch菜单
 
 @param paramDictionary JS 参数
 */
- (void)config3DTouchMenu:(BaseWebView *)webView
{
    /*
     cbId：
     target：
     args：
     [{
     type:'',                //菜单项的标识，字符串类型
     title:'',                //菜单标题，字符串类型
     subtitle:'',            //（可选项）菜单子标题，字符串类型
     icon:{                    //（可选项）菜单图标，JSON对象
     file:'',            //（可选项）图标文件路径，需放置在widget目录下，如widget/image/icon1.png。图标必须是单色的png格式图片，尺寸建议为105*105，若配置了该字段将忽略type字段。字符串类型
     type:0                //（可选项）使用系统提供的图标，请参考常量里面的“应用快捷菜单图标类型”。数字类型
     },
     userInfo:{                //（可选项）附加信息，JSON对象
     'key':'value'
     }
     }]
     */
    
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfConfig3DTouchMenu"] = ^()
    {
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary];
        
        NSArray *arrayArgs = dicArgs[@"args"][@"items"];
        if (!arrayArgs || arrayArgs.count == 0)
        {
            return;
        }
        
        NSMutableArray *arrayItems = [NSMutableArray array];
        
        for (NSDictionary *dicItem in arrayArgs)
        {
            if (dicItem[@"type"] == nil || dicItem[@"title"] == nil)
            {
                continue;
            } else {
                
                NSString *type = dicItem[@"type"];
                NSString *title = dicItem[@"title"];
                NSString *subtitle = dicItem[@"subtitle"];
                NSDictionary *userInfo = dicItem[@"userInfo"];
                
                UIApplicationShortcutIcon *icon = nil;
                
                if (dicItem[@"icon"][@"file"])
                {
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
                    {
                        NSString *iconName = [NSString stringWithFormat:@"assets/widget/%@", [dicItem[@"icon"][@"file"] substringFromIndex:9]];
                        
                        icon = [UIApplicationShortcutIcon iconWithTemplateImageName:iconName];
                    }
                } else if (dicItem[@"icon"][@"file"] == nil && dicItem[@"icon"][@"type"])
                {
                    if ([dicItem[@"icon"][@"type"] integerValue] >= 0 && [dicItem[@"icon"][@"type"] integerValue] <= 6)
                    {
                        icon = [UIApplicationShortcutIcon iconWithType:[dicItem[@"icon"][@"type"] integerValue]];
                    } else if ([dicItem[@"icon"][@"type"] integerValue] >= 7 &&
                               [dicItem[@"icon"][@"type"] integerValue] <= 28 &&
                               [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.1)
                    {
                        icon = [UIApplicationShortcutIcon iconWithType:[dicItem[@"icon"][@"type"] integerValue]];
                    }
                }
                
                UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc] initWithType:type
                                                                                   localizedTitle:title
                                                                                localizedSubtitle:subtitle
                                                                                             icon:icon
                                                                                         userInfo:userInfo];
                
                [arrayItems addObject:item];
            }
        }
        
        [[UIApplication sharedApplication] setShortcutItems:arrayItems];
    };
}


#pragma mark - Custom Method

// 默认
- (MJRefreshAutoNormalFooter *)setNormalFooterWithArgsDictionary:(NSDictionary *)argsDictionary webView:(BaseWebView *)webView
{
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    
    // 设置刷新头颜色
    if (argsDictionary[@"bgColor"])
    {
        footer.backgroundColor = [ToolsFunction hexStringToColor:argsDictionary[@"bgColor"]];
    } else {
        footer.backgroundColor = [ToolsFunction hexStringToColor:@"rgba(255.0, 255.0, 255.0, 1.0)"];
    }
    
    // 设置刷新头颜色
    if (argsDictionary[@"textColor"])
    {
        // 文字颜色
        footer.stateLabel.textColor = [ToolsFunction hexStringToColor:argsDictionary[@"textColor"]];
    } else {
        // 文字颜色
        footer.stateLabel.textColor = [ToolsFunction hexStringToColor:@"rgba(109, 128, 153, 1.0)"];
    }
    
    [footer setTitle:argsDictionary[@"textDown"] forState:MJRefreshStateIdle];
    
    [footer setTitle:argsDictionary[@"textUp"] forState:MJRefreshStatePulling];
    
    [footer setTitle:argsDictionary[@"textLoading"] forState:MJRefreshStateRefreshing];
    
    return footer;
}

- (MJRefreshAutoGifFooter *)setGifImageFooterWithArgsDictionary:(NSDictionary *)argsDictionary
{
    /*
     imgUrl = "../images/default_ptr_rotate.png";
     isShow = 1;
     isShowUpdateTime = 1;
     textColor = "#FF0191F7";
     textDown = "\U4e0b\U62c9\U53ef\U4ee5\U5237\U65b0";
     textLoading = "\U52a0\U8f7d\U4e2d";
     textUp = "\U677e\U5f00\U53ef\U4ee5\U5237\U65b0";
     textUpdateTime = "5\U5e74\U524d";
     bgColor = rgba(187, 236, 153, 1.0);
     */
    MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    NSArray *arrayGifImage = [argsDictionary[@"imgUrl"] componentsSeparatedByString:@","];
    NSMutableArray *arrayImages = [NSMutableArray new];
    
    if (arrayGifImage.count != 0)
    {
        if (arrayGifImage.count == 1)
        {
            NSString *imageAbsolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:arrayGifImage[0] excuteWebView:_customWebView];
            
#ifdef Loader
            if (LoaderJudget) {
                
            
            
            if ([ToolsFunction isFileExistAtPath:[NSString stringWithFormat:@"%@/loader/%@footerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]]])
            {
                NSData *dataGif = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/loader/%@footerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]]];
                footer.gifView.image = [UIImage sd_animatedGIFWithData:dataGif];
            } else {
                YTFAFHTTPSessionManager *manager =[NetworkManager sharedHTTPSession];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageAbsolutePath]];
                NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    
                    NSString *fullPath = [NSString stringWithFormat:@"%@/loader/%@footerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]];
                    [ToolsFunction createDirectoryWithPath:[[NSString stringWithFormat:@"%@/loader/%@footerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]] stringByDeletingLastPathComponent]];
                    return [NSURL fileURLWithPath:fullPath];
                    
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (error)
                        {
                            DLog(@"%@", error);
                        } else {
                            
                            NSData *dataGif = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/loader/%@footerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]]];
                            footer.gifView.image = [UIImage sd_animatedGIFWithData:dataGif];
                        }
                        
                    });
                    
                }];
                // 3.执行Task
                [download resume];
            }
                
            }else{
            
                NSData *dataGif = [NSData dataWithContentsOfFile:imageAbsolutePath];
                footer.gifView.image = [UIImage sd_animatedGIFWithData:dataGif];
            
            }
#else
            NSData *dataGif = [NSData dataWithContentsOfFile:imageAbsolutePath];
            footer.gifView.image = [UIImage sd_animatedGIFWithData:dataGif];
#endif
        } else {
            for (int i = 0; i < arrayGifImage.count; i++)
            {
                NSString *imageAbsolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:arrayGifImage[i] excuteWebView:_customWebView];
                
                UIImage *imageGif = [UIImage imageWithContentsOfFile:imageAbsolutePath];
                if (imageGif)
                {
                    [arrayImages addObject:imageGif];
                }
            }
            
            // 设置开始、下拉状态的动画图片
            [footer setImages:@[arrayImages.firstObject] forState:MJRefreshStateIdle];
            [footer setImages:@[arrayImages.firstObject] forState:MJRefreshStatePulling];
            
            // 设置正在刷新状态的动画图片
            [footer setImages:arrayImages duration:1.0 forState:MJRefreshStateRefreshing];
        }
    }
    
    // 设置刷新头颜色
    if (argsDictionary[@"bgColor"])
    {
        footer.backgroundColor = [ToolsFunction hexStringToColor:argsDictionary[@"bgColor"]];
    } else {
        footer.backgroundColor = [ToolsFunction hexStringToColor:@"rgba(255.0, 255.0, 255.0, 1.0)"];
    }
    
    // 设置刷新头颜色
    if (argsDictionary[@"textColor"])
    {
        // 文字颜色
        footer.stateLabel.textColor = [ToolsFunction hexStringToColor:argsDictionary[@"textColor"]];
    } else {
        // 文字颜色
        footer.stateLabel.textColor = [ToolsFunction hexStringToColor:@"rgba(109, 128, 153, 1.0)"];
    }
    
    [footer setTitle:argsDictionary[@"textDown"] forState:MJRefreshStateIdle];
    
    [footer setTitle:argsDictionary[@"textUp"] forState:MJRefreshStatePulling];
    
    [footer setTitle:argsDictionary[@"textLoading"] forState:MJRefreshStateRefreshing];
    
    return footer;
}

// 默认
- (MJRefreshNormalHeader *)setNormalHeaderWithArgsDictionary:(NSDictionary *)argsDictionary webView:(BaseWebView *)webView
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）

    // 设置刷新头颜色
    if (argsDictionary[@"bgColor"])
    {
        header.backgroundColor = [ToolsFunction hexStringToColor:argsDictionary[@"bgColor"]];
    } else {
        header.backgroundColor = [ToolsFunction hexStringToColor:@"rgba(255.0, 255.0, 255.0, 1.0)"];
    }
    
    // 设置刷新头颜色
    if (argsDictionary[@"textColor"])
    {
        // 文字颜色
        header.stateLabel.textColor = [ToolsFunction hexStringToColor:argsDictionary[@"textColor"]];
        header.lastUpdatedTimeLabel.textColor = [ToolsFunction hexStringToColor:argsDictionary[@"textColor"]];
    } else {
        // 文字颜色
        header.stateLabel.textColor = [ToolsFunction hexStringToColor:@"rgba(109, 128, 153, 1.0)"];
        header.lastUpdatedTimeLabel.textColor = [ToolsFunction hexStringToColor:@"rgba(109, 128, 153, 1.0)"];
    }
    
    [header setTitle:argsDictionary[@"textDown"] forState:MJRefreshStateIdle];
    
    [header setTitle:argsDictionary[@"textUp"] forState:MJRefreshStatePulling];
    
    [header setTitle:argsDictionary[@"textLoading"] forState:MJRefreshStateRefreshing];
    
    header.lastUpdatedTimeLabel.text = argsDictionary[@"textUpdateTime"];
    
    header.lastUpdatedTimeLabel.hidden = ![argsDictionary[@"isShowUpdateTime"] boolValue];
    
    return header;
}

- (MJRefreshGifHeader *)setGifImageHeaderWithArgsDictionary:(NSDictionary *)argsDictionary
{
    /*
     imgUrl = "../images/default_ptr_rotate.png";
     isShow = 1;
     isShowUpdateTime = 1;
     textColor = "#FF0191F7";
     textDown = "\U4e0b\U62c9\U53ef\U4ee5\U5237\U65b0";
     textLoading = "\U52a0\U8f7d\U4e2d";
     textUp = "\U677e\U5f00\U53ef\U4ee5\U5237\U65b0";
     textUpdateTime = "5\U5e74\U524d";
     bgColor = rgba(187, 236, 153, 1.0);
     */
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    NSArray *arrayGifImage = [argsDictionary[@"imgUrl"] componentsSeparatedByString:@","];
    NSMutableArray *arrayImages = [NSMutableArray new];
    
    if (arrayGifImage.count != 0)
    {
        if (arrayGifImage.count == 1)
        {
            NSString *imageAbsolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:arrayGifImage[0] excuteWebView:_customWebView];
            
#ifdef Loader
            
 if (LoaderJudget) {
                
     
            if ([ToolsFunction isFileExistAtPath:[NSString stringWithFormat:@"%@/loader/%@headerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]]])
            {
                NSData *dataGif = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/loader/%@headerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]]];
                header.gifView.image = [UIImage sd_animatedGIFWithData:dataGif];
            } else {
                YTFAFHTTPSessionManager *manager =[NetworkManager sharedHTTPSession];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageAbsolutePath]];
                NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    
                    NSString *fullPath = [NSString stringWithFormat:@"%@/loader/%@headerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]];
                    [ToolsFunction createDirectoryWithPath:[[NSString stringWithFormat:@"%@/loader/%@headerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]] stringByDeletingLastPathComponent]];
                    return [NSURL fileURLWithPath:fullPath];
                    
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (error)
                        {
                            DLog(@"%@", error);
                        } else {
                            
                            NSData *dataGif = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/loader/%@headerloading.gif", FilePathAppCaches, [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEAppId]]];
                            header.gifView.image = [UIImage sd_animatedGIFWithData:dataGif];
                        }
                        
                    });
                    
                }];
                // 3.执行Task
                [download resume];
            }
 }else{
 
     NSData *dataGif = [NSData dataWithContentsOfFile:imageAbsolutePath];
     header.gifView.image = [UIImage sd_animatedGIFWithData:dataGif];
 
 }
#else
            NSData *dataGif = [NSData dataWithContentsOfFile:imageAbsolutePath];
            header.gifView.image = [UIImage sd_animatedGIFWithData:dataGif];
#endif
        } else {
            for (int i = 0; i < arrayGifImage.count; i++)
            {
                NSString *imageAbsolutePath = [[PathProtocolManager shareManager] getWebViewUrlWithString:arrayGifImage[i] excuteWebView:_customWebView];
                UIImage *imageGif = [UIImage imageWithContentsOfFile:imageAbsolutePath];
#ifdef Loader
                
#else
                
#endif
                
                
                if (imageGif)
                {
                    [arrayImages addObject:imageGif];
                }
            }
            
            // 设置开始、下拉状态的动画图片
            [header setImages:@[arrayImages.firstObject] forState:MJRefreshStateIdle];
            [header setImages:@[arrayImages.firstObject] forState:MJRefreshStatePulling];

            // 设置正在刷新状态的动画图片
            [header setImages:arrayImages duration:1.0 forState:MJRefreshStateRefreshing];
        }
    }
    
    // 设置刷新头颜色
    if (argsDictionary[@"bgColor"])
    {
        header.backgroundColor = [ToolsFunction hexStringToColor:argsDictionary[@"bgColor"]];
    } else {
        header.backgroundColor = [ToolsFunction hexStringToColor:@"rgba(255.0, 255.0, 255.0, 1.0)"];
    }
    
    // 设置刷新头颜色
    if (argsDictionary[@"textColor"])
    {
        // 文字颜色
        header.stateLabel.textColor = [ToolsFunction hexStringToColor:argsDictionary[@"textColor"]];
        header.lastUpdatedTimeLabel.textColor = [ToolsFunction hexStringToColor:argsDictionary[@"textColor"]];
    } else {
        // 文字颜色
        header.stateLabel.textColor = [ToolsFunction hexStringToColor:@"rgba(109, 128, 153, 1.0)"];
        header.lastUpdatedTimeLabel.textColor = [ToolsFunction hexStringToColor:@"rgba(109, 128, 153, 1.0)"];
    }
    
    [header setTitle:argsDictionary[@"textDown"] forState:MJRefreshStateIdle];
    
    [header setTitle:argsDictionary[@"textUp"] forState:MJRefreshStatePulling];
    
    [header setTitle:argsDictionary[@"textLoading"] forState:MJRefreshStateRefreshing];
    
    header.lastUpdatedTimeLabel.text = argsDictionary[@"textUpdateTime"];
    
    header.lastUpdatedTimeLabel.hidden = ![argsDictionary[@"isShowUpdateTime"] boolValue];
    
     
    
    return header;
}

- (void)loadNewData
{
    [self performSelectorOnMainThread:@selector(mainThreadPullRefreshLoadingWithWebView:) withObject:_customWebView waitUntilDone:NO];
}

- (void)loadMoreData
{
    [self performSelectorOnMainThread:@selector(mainThreadPullUpRefreshLoadingWithWebView:) withObject:_customWebView waitUntilDone:NO];
}

- (void)removeGifView:(UITapGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    [view removeFromSuperview];
}

- (void)removePopView:(UITapGestureRecognizer *)gestureRecognizer
{
    UIView *viewPop = gestureRecognizer.view;
    
    for (BaseWebView *webView in viewPop.subviews)
    {
        if ([webView isKindOfClass:[BaseWebView class]])
        {
            webView.delegate = nil;
            [webView removeFromSuperview];
        }
    }
    
    [viewPop removeFromSuperview];
}

- (void)mainThreadPullRefreshLoadingWithWebView:(UIWebView *)webView
{
    NSDictionary *dic = @{@"status" : @1};
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',null,false);",_setPullCbId, [ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dic]]]];

}

- (void)mainThreadPullRefreshDoneWithWebView:(BaseWebView *)webView
{
    NSDictionary *dic = @{@"status" : @0};//结束刷新 0 开始刷新 1
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',null,false);",_setPullCbId, [ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dic]]]];
}

- (void)mainThreadPullUpRefreshLoadingWithWebView:(BaseWebView *)webView
{
    NSDictionary *dic = @{@"status" : @1};
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);",_setUpPullCbId, [ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dic]], [ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dic]]]];
}

- (void)mainThreadPullUpRefreshDoneWithWebView:(BaseWebView *)webView
{
    NSDictionary *dic = @{@"status" : @0};//结束刷新 0 开始刷新 1
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);",_setUpPullCbId, [ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dic]], [ToolsFunction transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dic]]]];
}

- (void)mainThreadSelectAlertButtonWithWebView:(BaseWebView *)webView
{
    NSDictionary *dic = nil;
    if (_textFieldContent != nil)
    {
        dic = @{@"buttonIndex" : _selectButtonIndex,
                              @"text" : _textFieldContent};
    } else {
        dic = @{@"buttonIndex" : _selectButtonIndex};
    }
    NSString * testString = [ToolsFunction dicToJavaScriptString:dic];
    [webView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@',false);",_setAlertCbId,testString]];
    _textFieldContent = nil;
}


@end
