/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic webView.
 * =============================================================================
 */

#import "BaseWebView.h"
#import "WindowManager.h"
#import "DrawerWinManager.h"
#import "FrameManager.h"
#import "FrameGroupManager.h"
#import "InteractiveManager.h"
#import "NetworkManager.h"
#import "UIControlManager.h"
#import "MessageNotificationManager.h"
#import "Definition.h"
#import "MediaManager.h"
#import "PanGeusterDelegateClass.h"
#import "AppDelegate.h"
#import "YTFConfigManager.h"
#import "LaunchManager.h"
#import "BridgeCenter.h"
#import "ToolsFunction.h"
#import "ErrorManager.h"
#import "WindowInfoManager.h"
#import "DeviceInfoManager.h"
#import "BaseViewController.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "SlipCloseWinGuesterManager.h"
#import "RC4DecryModule.h"
#import "Masonry.h"

@interface BaseWebView ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, weak) BaseWebView *currentWin;
@property (nonatomic, weak) BaseWebView * closeSlipInWebView;//接收Slip是作用在  win 上 还是 frame 上
@property (nonatomic, strong) UIControlManager *controlManager;
@property (nonatomic, strong) NetworkManager *networkManager;

@end

@implementation BaseWebView

{
    UIPanGestureRecognizer * sideWinPan;//侧滑手势
    UIPanGestureRecognizer * closeWinPan;//侧滑手势
    UIPanGestureRecognizer * groupSideWinPan;//group侧滑手势
    PanGeusterDelegateClass * panDelegateObj;//实现手势坐标逻辑的类
    BaseWebView * sideWebView;//拿到sideWin
}

#pragma mark - Initialize

/**
 *  初始化webView
 *
 *  @param frame    frame
 *  @param url      url
 *  @param isWindow win
 *
 *  @return
 */
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url isWindow:(BOOL)isWindow
{
    if (self == [super init])
    {
        self.paramObject = [[WebViewParamObject alloc] init];
        self.networkManager = [[NetworkManager alloc] init];
        self.controlManager = [[UIControlManager alloc] init];
        self.messageNotificationManager = [[MessageNotificationManager alloc] init];
        self.scrollBottomHeight = 0.0;
        self.isDrawerWin   = false;
        self.isRemoteWeb   = false;
        self.isGroupFrame  = false;
        self.isDrawerSide  = false;
        self.drawerWinName = nil;
        self.webViewUrl    = [NSURL URLWithString:url];

        if (url!= nil)
        {
#ifdef DecryMode
            if (url && [url hasPrefix:@"http"])
            {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                [self loadRequest: request];
            } else if (url)
            {
                // 截取相对路径
                NSString *reletivePath = [url substringFromIndex:[FilePathAppResources length]];
                NSString *hotFixPath = [FilePathCustomHotFix stringByAppendingPathComponent:reletivePath];
                NSData *secretData = nil;
                
                if ([ToolsFunction isFileExistAtPath:hotFixPath])
                {
                    secretData = [NSData dataWithContentsOfFile:hotFixPath];
                } else {
                    secretData = [NSData dataWithContentsOfFile:url];
                }
                
                NSString *decryString = [RC4DecryModule decry_RC4WithByteArray:(Byte *)[secretData bytes] key:DecryKey fileData:secretData];
                [self loadHTMLString:decryString baseURL:[NSURL URLWithString:url]];
            }
#else
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [self loadRequest:request];
#endif
        }
    }
    if (isWindow)
    {
        self.scrollView.bounces = false;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
     // 初始化 JS 执行环境
    [self configJavaScriptExcuteEnvironment];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientChange:(NSNotification *)notification
{
    /*
     UIDeviceOrientationUnknown,            0
     UIDeviceOrientationPortrait,           1  // 正常竖直屏幕                        #
     UIDeviceOrientationPortraitUpsideDown, 2  // 倒立的竖直屏幕
     UIDeviceOrientationLandscapeLeft,      3  // button on the right               #
     UIDeviceOrientationLandscapeRight,     4  // home button on the left           #
     UIDeviceOrientationFaceUp,             5  // Device oriented flat, face up
     UIDeviceOrientationFaceDown            6  // Device oriented flat, face down
     */
    
    UIDeviceOrientation orient =  ((UIDevice *)notification.object).orientation;
    
    if (orient == UIDeviceOrientationPortraitUpsideDown ||
        orient == UIDeviceOrientationFaceUp ||
        orient == UIDeviceOrientationFaceDown ||
        orient == UIDeviceOrientationUnknown) {
        return;
    }
    
    // sidewin 更新布局
    if (_isDrawerSide == false || self == nil)
    {
        return;
    }
    
    if (![[AppDelegate shareAppDelegate].baseViewController.view.subviews containsObject:self])
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            if ([[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
            {
                make.top.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(AppStatusBarHeight);
            } else {
                make.top.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(0);
            }
            
            make.bottom.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(0);
            make.right.equalTo([AppDelegate shareAppDelegate].baseViewController.view).with.offset(-ScreenWidth);
            make.width.mas_equalTo(SideWinWidth);
        }];
    });
    
    BaseWebView *sideWebViewdraw = nil;
    BaseWebView *mainWebViewdraw = nil;
    for (BaseWebView *baseWebView in [AppDelegate shareAppDelegate].baseViewController.view.subviews) {
        
        mainWebViewdraw = [[AppDelegate shareAppDelegate].baseViewController.view.subviews lastObject];
        
        if ([mainWebViewdraw isKindOfClass:[BaseWebView class]] && [baseWebView.drawerWinName isEqualToString:mainWebViewdraw.drawerWinName] && baseWebView!=mainWebViewdraw) {
            sideWebViewdraw = baseWebView;
        }
    }
    
    if ([mainWebViewdraw isKindOfClass:[BaseWebView class]] && mainWebViewdraw.isDrawerOpen)
    {
        [[PanGeusterDelegateClass shareInshance] hideLeftView:mainWebViewdraw sideWebView:sideWebViewdraw];
    }
}


#pragma mark - Setter

- (void)setIsSideWinPanGuester:(BOOL)isSideWinPanGuester
{
    if (isSideWinPanGuester)
    {
        //添加 sideWin滑动手势
        [self addSideWinPanGuester];
    }
}

- (void)setIsSlipCloseWin:(BOOL)isSlipCloseWin{
    if (isSlipCloseWin) {
        _isSlipCloseWin = isSlipCloseWin;
        [self addCloseWinPanGuester];
    }
}


#pragma mark - Custom Method

/**
 *  设置抽屉webView名字
 *
 *  @param baseWebViewsArray 抽屉的webView
 *  @param drawerName        抽屉名
 */
+ (void)configDrawerBaseWebView:(NSArray <BaseWebView *>*)baseWebViewsArray drawerName:(NSString *)drawerName
{
    if ([baseWebViewsArray count] != 2)
    {
        return;
    }
    
    baseWebViewsArray[0].isDrawerWin = true;
    baseWebViewsArray[0].isDrawerOpen = false;
    baseWebViewsArray[0].drawerWinName = drawerName;
    baseWebViewsArray[1].isDrawerWin = true;
    baseWebViewsArray[1].isDrawerOpen = false;
    baseWebViewsArray[1].drawerWinName = drawerName;
    
}

/**
 *  初始化 JS 执行环境
 */
- (void)configJavaScriptExcuteEnvironment
{
    // Window
    [[WindowManager shareManager] openWinWithWebView:self];
    [[WindowManager shareManager] closeWinWithWebView:self];
    [[WindowManager shareManager] closeToWinWithWebView:self];
    [[WindowManager shareManager] appCloseWithWebView:self];

    // Drawer
    [[DrawerWinManager shareManager] openDrawerWinWithWebView:self];
    [[DrawerWinManager shareManager] closeDrawerWinWithWebView:self];
    [[DrawerWinManager shareManager] openDrawerWithWebView:self];
    [[DrawerWinManager shareManager] closeDrawerWithWebView:self];
    [[DrawerWinManager shareManager] lockDrawerWinWithWebView:self];
    [[DrawerWinManager shareManager] unlockDrawerWinWithWebView:self];
    

    // Frame
    [[FrameManager shareManager] openFrameWithWebView:self];
    [[FrameManager shareManager] closeFrameWithWebView:self];
    [[FrameManager shareManager] activeFrameWithWebView:self];
    [[FrameManager shareManager] disActiveFrameWithWebView:self];
    [[FrameManager shareManager] setFrameAttributeWithWebView:self];


    // Framegroup
    [[FrameGroupManager shareManager] openFrameGroupWithWebView:self];
    [[FrameGroupManager shareManager] closeFrameGroupWithWebView:self];
    [[FrameGroupManager shareManager] setFrameGroupIndexWithWebView:self];
    [[FrameGroupManager shareManager] setFrameGroupAttributeWithWebView:self];


    // Interactive
    [[InteractiveManager shareManager] JSExcuteJS:self];
    [[InteractiveManager shareManager] JSExcuteNative:self];


    // Network
    [self.networkManager ajaxHttpRequestWithWebView:self];
    [self.networkManager ajaxDownloadFilesWithWebView:self];
    [self.networkManager ajaxCancelDownloadWithWebView:self];
        

    // Event
    [self.messageNotificationManager addEventListenerWithWebView:self];
    [self.messageNotificationManager postEventListenerWithWebView:self];
    [self.messageNotificationManager removeEventListenerWithWebView:self];
    
    

    // UI
    [self.controlManager setPullUpRefreshWithWebView:self];

    [self.controlManager pullUpRefreshLoadingWithWebView:self];
    [self.controlManager pullUpRefreshDoneWithWebView:self];
    [self.controlManager setPullRefreshWithWebView:self];
    [self.controlManager pullRefreshLoadingWithWebView:self];
    [self.controlManager pullRefreshDoneWithWebView:self];

    [self.controlManager alertWithWebView:self];
    [self.controlManager confirmWithWebView:self];
    [self.controlManager promptWithWebView:self];
    [self.controlManager showProgressWithWebView:self];
    [self.controlManager hideProgressWithWebView:self];
    [self.controlManager showCustomProgressWithWebView:self];
    [self.controlManager hideCustomProgressWithWebView:self];

    [self.controlManager toastWithWebView:self];
    [self.controlManager popViewWithWebView:self];
    [self.controlManager hidePopViewWithWebView:self];

    [self.controlManager config3DTouchListener:self];
    [self.controlManager config3DTouchMenu:self];
    

    // Media
    [[MediaManager shareManager] mediaGetPicture:self];
    
    // Lanuch
    [[LaunchManager shareManager] removeLaunchWithWebView:self];
    
    // Plugin  Bridge
    [[BridgeCenter shareManager]ytfNativeBridget:self];
    [[BridgeCenter shareManager]ytfRequireNativeMethod:self];
    
    // Error
    [[ErrorManager shareManager] errorMessageWithWebView:self];
    
    [[DeviceInfoManager shareManager] getNetStatus:self];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 判断scrollView 是否滑动到底部
    //当前可见视图相对于frame的偏移量，经过实际测试，发现向上滑动contentOffset.y的值不断增加。
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    //实际内容的高度，如上图所示包含虚线区域
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    CGFloat currentOffset = offset.y + bounds.size.height - inset.bottom;
    CGFloat maximumOffset = size.height;
    
    CGPoint point = [scrollView.panGestureRecognizer translationInView:self];
    
    if (point.y>0) {
    //向下滑动

    }else{
    //上拉加载 滑动到底部了
        if((maximumOffset - currentOffset) <= self.scrollBottomHeight)
        {
            [self performSelector:@selector(postScrollToBottomNotification) withObject:nil afterDelay:0.05];
        }
    }
}

- (void)postScrollToBottomNotification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(postScrollToBottomNotification) object:nil];
  
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationWebViewScrollToBottom object:self];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    // 处理键盘弹出 页面是否移动问题
    if ([[YTFConfigManager shareConfigManager].softKeyboardMode isEqualToString:@"resize"])
    {
        return nil;
    }
    return scrollView.subviews.firstObject;
}


#pragma mark - 添加 sideWin滑动手势

- (void)addSideWinPanGuester
{
    //添加手势
    sideWinPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(framePan:)];
    sideWinPan.delegate = self;
    [self addGestureRecognizer:sideWinPan];
    panDelegateObj =[PanGeusterDelegateClass shareInshance]; //[[PanGeusterDelegateClass alloc]init];
    panDelegateObj.currentVC = [ToolsFunction getCurrentVC];
    [panDelegateObj getSideWebView];

    self.appDelegate = [AppDelegate shareAppDelegate];
    BaseWebView *mainWeb;
    for (BaseWebView *tempWeb in (self.appDelegate.baseViewController.view.subviews)) {
        if ([tempWeb isMemberOfClass:[BaseWebView class]]) {
            mainWeb = tempWeb;
        }
    }
    for (BaseWebView *baseWebView in self.appDelegate.baseViewController.view.subviews)
    {
        if ([baseWebView isMemberOfClass:[BaseWebView class]]){
             if ([baseWebView.drawerWinName isEqualToString:mainWeb.drawerWinName] && baseWebView!=mainWeb) {
                sideWebView = baseWebView;
            }
        }
    }
}


/**
 添加侧滑关闭窗口 手势， 程序中 所有的 win是添加在  self.appDelegate.baseViewController.view 上的
 所有的 frame是添加在  win上的，不是在 self.appDelegate.baseViewController.view 上
 */
- (void)addCloseWinPanGuester{
    
        closeWinPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(closeWinPan:)];
        closeWinPan.delegate = self;
        [self addGestureRecognizer:closeWinPan];
        panDelegateObj = [[PanGeusterDelegateClass alloc]init];
}


/**
 实现滑动手势

 @param pan
 */
- (void)framePan:(UIPanGestureRecognizer *)pan
{
    [panDelegateObj frameSidePanGuester:(BaseWebView*)self.superview sideWin:sideWebView
                                guester:pan
                               leftEdge:[[YTFConfigManager shareConfigManager] configLeftEdge:self.leftEdge]
                               leftZone:[[YTFConfigManager shareConfigManager] configLeftZone:self.leftZone]
                              leftScale:self.leftScale];
}


/**
 添加 sideSlip 侧滑关闭窗口

 @param slipClosePan
 */
- (void)closeWinPan:(UIPanGestureRecognizer *)slipClosePan{
    UIEvent * event     = [[UIEvent alloc]init];
    CGPoint location    = [slipClosePan locationInView:slipClosePan.view];
    UIView * customView = [slipClosePan.view hitTest:location withEvent:event];
    

        if ( ![NSStringFromClass([customView class]) hasPrefix:@"UIWebBrowserView"] && customView != nil) {
        //是子视图  则不响应手势
            return;
        }else{
        //DLog(@"父 视图 ");
        }
    if (((BaseWebView *)(slipClosePan.view)).frameName.length  == 0) {
        // 在  win 上滑动
        [[SlipCloseWinGuesterManager shareInstance] sideSlipCloseWinPanGuester:self.currentWin
                                      isWinWebView:YES
                                      closeGuester:closeWinPan
                                      isModuleView:NO];
    }else{
        
        
        if ([(slipClosePan.view).superview.superview isMemberOfClass:[UIScrollView class]]) {
            
            [[SlipCloseWinGuesterManager shareInstance] sideSlipCloseWinPanGuester:((slipClosePan.view).superview.superview)
                                                                      isWinWebView:NO
                                                                      closeGuester:closeWinPan
                                                                      isModuleView:NO];
        }else{
        
            [[SlipCloseWinGuesterManager shareInstance] sideSlipCloseWinPanGuester:slipClosePan.view
                                                                      isWinWebView:NO
                                                                      closeGuester:closeWinPan
                                                                      isModuleView:NO];
        
        }
  }
}

@end
