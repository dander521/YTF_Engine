/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Micro definition.
 * =============================================================================
 */


#import "JSUrlDefinition.h"
#import "ConfigDefinition.h"
#import "ToolsFunction.h"
#import "FilePathDefinition.h"
#import "DeviceDefinition.h"
#import "AppDelegate.h"

#ifndef Definition_h
#define Definition_h


#pragma mark - Decry

//#define Loader // 定义是否为appLoader模式 非loader请进行注释
//#define LoaderJudget     [[[NSUserDefaults standardUserDefaults]objectForKey:@"LaunchLoader"] isEqualToNumber:@1]

//#define DecryMode   // 加密模式
#define DecryKey @"3lwYydNTKe6Q~)M^tMMZ7DOR(&#B]_qpvMfS9(>aPH#yUW96jDT%1t9w#d2Rt9BeC?k%5S@c~!C%dn*Jn!AHCxwq}ydgoXeEHdEI>q%xn}P}s.WaTGOtXNdYq0%VWF!{_49Os58LyBO(oHylUdsu}upl3E3z3m*5eAK~MXe(nuNK+o0a)G_+kJK8BF1FwR2a{%l_7OVbj^?bDaU7}~Jp3u03BGCnhw)K~0VzlYBUidSD6z_ah^B>mdVbIf5fs7*2on0acO5E#Ny8un1>oXw&m]qeiRYta5~R*)?HCWSumYNXf3t3zpP7WeRo~]Qh992u#7MfJ6iQP#TcxE)Rwi02a3iYCRV]%FqEv8k(>f}KXbfm>@WKZT3{g1P(mSfBA*6lO2Gljt57Af?d#h@O7h#Rk*xu}6@QPa!l[QPLdPCDeS?!0!aK+stWy{i1}8u^maH~>jNovMsuJFQlD_?o?l6K)3+3rimgF?o5dYni5[EAH7kxbGh+PVZ&4(x5jqlj5"

#pragma mark - YTFAppInfo

#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
#define ScreenHeight        [UIScreen mainScreen].bounds.size.height
#define SideWinOriginX                  floor(-ScreenWidth*0.6)
#define SideWinWidth                    ceil(ScreenWidth*0.6)
#define AppStatusBarHeight              20.0
#define AppFrameWebViewTop              40.0
#define AppFrameWebViewBottom           60.0
#define WebViewAnimationTime            0.11
#define Gif_View_Tag    10000
#pragma mark - Log Method

//#define CustomWidgetTest // 自定义测试宏
#ifdef DEBUG
//#define DLog(format, ...) NSLog((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLog(format, ...) NSLog((@"[Function:%s]" format), __FUNCTION__, ##__VA_ARGS__);

#else
# define DLog(...);
#endif

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)



#pragma mark - Weak/Strong Object

#define RCWeakSelf(type)    __weak typeof(type) weak##type = type;
#define RCStrongSelf(type)  __strong typeof(type) type = weak##type;

#pragma mark - File MimeType

#define MimeTypeHtml    @"text/html"
#define MimeTypePng     @"image/png"
#define MimeTypeGif     @"image/gif"
#define MimeTypeJpg     @"image/jpeg"
#define MimeTypeCss     @"text/css"
#define MimeTypeJs      @"text/javascript"
#define MimeTypeTtf     @"application/octet-stream"
#pragma mark - Notification

#define PreloadNotification                 @"preloadNotification"
#define AssistiveTouchNotification         @"AssistiveTouchNotification"
#define NotificationWhenModuleDealloc      @"NotificationWhenModuleDealloc"
#define ModuleViewSlipBackGuestureNotific  @"ModuleViewGuestureNotific"         //  插件开发者自定义的view--滑动关闭窗口的属性的通知name
#define ModuleiewOpenDrawerGuestureNotific @"ModuleiewOpenDrawerGuestureNotific"//   侧滑打开Drawer

#endif /* Definition_h */
