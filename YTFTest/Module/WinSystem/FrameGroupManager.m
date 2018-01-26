/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFramework framegroup operation file.
 * =============================================================================
 */

#import "FrameGroupManager.h"
#import "Definition.h"
#import "AppDelegate.h"
#import "BaseWebView.h"
#import "InteractiveManager.h"
#import "NetworkManager.h"
#import "PathProtocolManager.h"
#import "PanGeusterDelegateClass.h"
#import "YTFConfigManager.h"
#import "PathProtocolManager.h"
#import "BaseViewController.h"
#import "WindowInfoManager.h"
#import "YTFAnimationManager.h"
#import "RC4DecryModule.h"
#import "Masonry.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



//声明全局类型数组
extern NSInteger const SomeTypes[];
//声明全局类型字符串函数
extern NSString * const SomeTypeIdentifier(NSInteger Key);
//定义类型数组
UIDeviceOrientation const SubCityCategoryTypes[] = {
    UIDeviceOrientationUnknown,
    UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
    UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
    UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
    UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
    UIDeviceOrientationFaceUp,              // Device oriented flat, face up
    UIDeviceOrientationFaceDown             // Device oriented flat, face down
};
//定义字符串函数
NSString * const UIDeviceOrientationTypeIdentifier(NSInteger Key){
    switch (Key) {
        case UIDeviceOrientationUnknown:
            return @"UIDeviceOrientationUnknown";
        case UIDeviceOrientationPortrait:
            return @"UIDeviceOrientationPortrait";
        case UIDeviceOrientationPortraitUpsideDown:
            return @"UIDeviceOrientationPortraitUpsideDown";
        case UIDeviceOrientationLandscapeLeft:
            return @"UIDeviceOrientationLandscapeLeft";
        case UIDeviceOrientationLandscapeRight:
            return @"UIDeviceOrientationLandscapeRight";
        case UIDeviceOrientationFaceUp:
            return @"UIDeviceOrientationFaceUp";
        case UIDeviceOrientationFaceDown:
            return @"UIDeviceOrientationFaceDown";
        default:
            return @"";
    }
}


typedef void(^SelectedGroupFrameBlock)(int frameIndex, UIWebView *webView);

@interface FrameGroupManager ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    NSUInteger groupFrameIndex;//frame 的个数
    UIPanGestureRecognizer * groupSideWinPan;//group侧滑手势
    PanGeusterDelegateClass * panDelegateObj;//实现手势坐标逻辑的类
    BaseWebView * firstWeb;//加在Sc最左边的 web
    BaseWebView * lastWeb;// 加在 sc 最右边的 web
}

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, assign) int markForIn_scrollDeleg;//计数器 来控制 某方法只走一次
@property (nonatomic, weak) BaseWebView *subWebView;//当前 win的上一层 win
@property (nonatomic, weak) BaseWebView *excWebView;//接收framegroup 的webView 为本类全局变量
@property (nonatomic, copy) SelectedGroupFrameBlock selectedFrameIndexBlock;

@property (nonatomic, assign) int num;//frame 的个数
@property (nonatomic, assign) int number;//滑动参数
@property (nonatomic, assign) int preload; // 预加载页面
@property (nonatomic, assign) int selectedIndex; // 选中的Index

@property (nonatomic, weak) NSDictionary *groupDicArgs; // 创建group的dicArgs；

@property(nonatomic,assign) CGFloat rightMar; // 右侧margin
@property(nonatomic,assign) CGFloat bottomMar; // 底部margin

@end

@implementation FrameGroupManager

// 单例
+ (instancetype)shareManager
{
    static FrameGroupManager *frameGroupModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        frameGroupModel = [[self alloc] init];
        frameGroupModel.frameGroupScrollViewDictionary = [NSMutableDictionary new];
        frameGroupModel.htmlParamDictionary = [NSMutableDictionary new];
        frameGroupModel.frameGroupNamesArray = [NSMutableArray new];
        frameGroupModel.frameGroupConfigsArray = [NSMutableArray new];
        frameGroupModel.frameGroupCbIdsArray = [NSMutableArray new];
        frameGroupModel.originXFrameArray = [NSMutableArray new];
        frameGroupModel.reuseDictionary = [NSMutableDictionary new];
        frameGroupModel.preloadDictionary = [NSMutableDictionary new];
        frameGroupModel.preload = 1;
        frameGroupModel.selectedIndex = 0;
        frameGroupModel.appDelegate = [AppDelegate shareAppDelegate];
        frameGroupModel.markForIn_scrollDeleg = 0;
        frameGroupModel.rightMar = 0.0;
        frameGroupModel.bottomMar = 0.0;
    });
    
    return frameGroupModel;
}

- (instancetype)init
{
    if (self == [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preloadNotification:) name:PreloadNotification object:nil];
    }
    
    return self;
}

- (void)preloadNotification:(NSNotification *)noti
{
    // 当前group所有webView
    NSArray <BaseWebView *>*arrayWeb = [self.preloadDictionary objectForKey:noti.object[@"frameGroupName"]];
    
    [NSThread sleepForTimeInterval:0.5];
    
    NSInteger index = [noti.object[@"index"] integerValue];
    
    if (labs([self.groupDicArgs[@"index"] integerValue] - index) == self.preload)
    {
        return;
    }
    
    if (index + 1 == arrayWeb.count)
    {
        return;
    } else {
        BaseWebView *rightWeb = arrayWeb[index + 1];
        
        if (rightWeb.isLoad == false)
        {
            rightWeb.isLoad = true;
            [self preloadWebViewWithUrl:[rightWeb.webViewUrl absoluteString]  webView:rightWeb];
        }
    }
    
    if (index - 1 < 0)
    {
        return;
    } else {
        BaseWebView *leftWeb = arrayWeb[index - 1];
        
        if (leftWeb.isLoad == false)
        {
            leftWeb.isLoad = true;
            [self preloadWebViewWithUrl:[leftWeb.webViewUrl absoluteString]  webView:leftWeb];
        }
    }
}

- (void)dealloc
{
    self.closeWinFrameArray = nil;
    self.originXFrameArray = nil;
    self.frameGroupScrollViewDictionary = nil;
    self.htmlParamDictionary = nil;
    self.frameGroupNamesArray = nil;
    self.frameGroupConfigsArray = nil;
    self.frameGroupCbIdsArray = nil;
    self.reuseDictionary = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  打开framegroup
 *
 *  @param webView
 */
- (void)openFrameGroupWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfframeGroupOpen"] = ^() {
        [ToolsFunction hideCustomProgress];
        _excWebView = weakwebView;
        weakself.groupDicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        // 记录初始 index 为了让连续点击同一个frame时，不重复回调的问题
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[weakself.groupDicArgs[@"index"] intValue]] forKey:weakself.groupDicArgs[@"frameGroupName"]];
        
        weakself.preload = weakself.groupDicArgs[@"preload"] == nil ? weakself.preload : [weakself.groupDicArgs[@"preload"] intValue];
        
        weakself.selectedIndex = [weakself.groupDicArgs[@"index"] intValue];

        [weakself.frameGroupConfigsArray addObject:weakself.groupDicArgs];
        
        NSString *stringCbid = [[JSContext currentArguments][0] toDictionary][@"cbId"];
         groupFrameIndex = ((NSArray *)weakself.groupDicArgs[@"frames"]).count;
        weakself.num = (int)((NSArray *)weakself.groupDicArgs[@"frames"]).count;
        
        weakwebView.frameGroupName = weakself.groupDicArgs[@"frameGroupName"];
        
        NSArray *arrayFrames = weakself.groupDicArgs[@"frames"];
        
        BOOL isReuse = false;

        if (arrayFrames.count > 1 &&
            [((NSDictionary *)arrayFrames[0])[@"htmlUrl"] isEqualToString:((NSDictionary *)arrayFrames[1])[@"htmlUrl"]])
        {
            isReuse = true;
        } else {
            isReuse = false;
        }
        
        [weakself.reuseDictionary setValue:[NSString stringWithFormat:@"%d", isReuse] forKey:weakself.groupDicArgs[@"frameGroupName"]];

        
       
        if (weakself.frameGroupScrollViewDictionary[weakself.groupDicArgs[@"frameGroupName"]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.appDelegate.baseViewController.view.subviews.lastObject bringSubviewToFront:weakself.frameGroupScrollViewDictionary[weakself.groupDicArgs[@"frameGroupName"]]];
            });
            return;
        }
        
        if (weakself.groupDicArgs[@"frameGroupName"]) {
            [weakself.frameGroupNamesArray addObject:weakself.groupDicArgs[@"frameGroupName"]];
            [weakself.frameGroupCbIdsArray addObject:stringCbid];
        }

        // 初始化 sc
        UIScrollView *scrollBase = [weakself baseScrollView:weakself.groupDicArgs];
        BaseWebView *frameWebView = nil;
        // 配置页面属性
        [weakself attrConfigFrameGroupJSparam:weakself.groupDicArgs];
        
        // scrollview 展示
        [weakwebView addSubview:scrollBase];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGFloat offsetX = weakself.groupDicArgs[@"xywh"][@"x"] == nil ? 0 : [weakself.groupDicArgs[@"xywh"][@"x"] floatValue];
            CGFloat offsetY = weakself.groupDicArgs[@"xywh"][@"y"] == nil ? 0 : [weakself.groupDicArgs[@"xywh"][@"y"] floatValue];
            
            CGFloat offsetW = 0;
            CGFloat offsetH = 0;
            
            if (weakself.groupDicArgs[@"xywh"][@"w"] && [weakself.groupDicArgs[@"xywh"][@"w"] isKindOfClass:[NSString class]] && [weakself.groupDicArgs[@"xywh"][@"w"] isEqualToString:@"auto"])
            {
                offsetW = ScreenWidth - offsetX;
            } else {
                offsetW = [weakself.groupDicArgs[@"xywh"][@"w"] floatValue];
            }
            
            if (weakself.groupDicArgs[@"xywh"][@"h"] && [weakself.groupDicArgs[@"xywh"][@"h"] isKindOfClass:[NSString class]] && [weakself.groupDicArgs[@"xywh"][@"h"] isEqualToString:@"auto"])
            {
                offsetH = ScreenHeight - offsetY;
            } else {
                offsetH = [weakself.groupDicArgs[@"xywh"][@"h"] floatValue];
            }
            
            CGFloat marginLeft = weakself.groupDicArgs[@"xywh"][@"marginLeft"] == nil ? 0 : [weakself.groupDicArgs[@"xywh"][@"marginLeft"] floatValue];
            CGFloat marginTop = weakself.groupDicArgs[@"xywh"][@"marginTop"] == nil ? 0 : [weakself.groupDicArgs[@"xywh"][@"marginTop"] floatValue];
            CGFloat marginBottom = weakself.groupDicArgs[@"xywh"][@"marginBottom"] == nil ? 0 : [weakself.groupDicArgs[@"xywh"][@"marginBottom"] floatValue];
            CGFloat marginRight = weakself.groupDicArgs[@"xywh"][@"marginRight"] == nil ? 0 : [weakself.groupDicArgs[@"xywh"][@"marginRight"] floatValue];
            
            [scrollBase mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(weakwebView).with.offset(marginTop + offsetY);
                make.left.equalTo(weakwebView).with.offset(marginLeft + offsetX);
                
                if (offsetW != 0)
                {
                    make.right.equalTo(weakwebView).with.offset(-(ScreenWidth - marginLeft - marginRight - offsetX - offsetW));
                    self.rightMar = -(ScreenWidth - marginLeft - marginRight - offsetX - offsetW);
                } else {
                    make.right.equalTo(weakwebView).with.offset(-marginRight);
                    self.rightMar = -marginRight;
                }

                if (offsetH != 0)
                {
                    if ([[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"])
                    {
                        make.bottom.equalTo(weakwebView).with.offset(-(ScreenHeight - marginTop - marginBottom - offsetY - offsetH - AppStatusBarHeight));
                        self.bottomMar = -(ScreenHeight - marginTop - marginBottom - offsetY - offsetH - AppStatusBarHeight);
                    } else {
                        make.bottom.equalTo(weakwebView).with.offset(-(ScreenHeight - marginTop - marginBottom - offsetY - offsetH));
                        self.bottomMar = -(ScreenHeight - marginTop - marginBottom - offsetY - offsetH);
                    }
                } else {
                    make.bottom.equalTo(weakwebView).with.offset(-marginBottom);
                    self.bottomMar = -marginBottom;
                }
            }];
            
            //scrollview里放个View
            UIView *container = [[UIView alloc] init];
            [scrollBase addSubview:container];
            [container mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(scrollBase);
                make.height.equalTo(scrollBase);
            }];
            
            // 创建子frame 并设置是否可循环滚动
            [weakself configGroupIsLoop:frameWebView dicArgs:weakself.groupDicArgs container:container];
        });
        
         weakwebView.scrollView.bounces = false;

        groupSideWinPan = [[UIPanGestureRecognizer alloc] initWithTarget:weakself action:@selector(groupPan:)];
        groupSideWinPan.delegate = weakself;
        
        panDelegateObj =[PanGeusterDelegateClass shareInshance]; //[[PanGeusterDelegateClass alloc]init];
        [ToolsFunction getCurrentVC];
        [panDelegateObj getSideWebView];
        
        if (((BaseWebView *)weakwebView).isDrawerWin)
        {
            [scrollBase addGestureRecognizer:groupSideWinPan];
        }

        // 选择index的block回调 变更index active 状态
        weakself.selectedFrameIndexBlock = ^(int frameIndex, UIWebView *blockWebView)
        {
            NSString *stringJson = [[ToolsFunction dictionaryToJsonString:@{@"index":[NSNumber numberWithInt:frameIndex]}] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [blockWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@',null,false);", [weakself.frameGroupCbIdsArray lastObject], stringJson]];
         };
     };
}

/**
 *  关闭framegroup
 *
 *  @param webView
 */
- (void)closeFrameGroupWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfframeGroupClose"] = ^() {
        [ToolsFunction hideCustomProgress];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.frameGroupScrollViewDictionary[[weakself.frameGroupNamesArray lastObject]] removeFromSuperview];
        });
        [weakself.frameGroupNamesArray removeLastObject];
        [weakself.frameGroupConfigsArray removeLastObject];
        [weakself.frameGroupCbIdsArray removeLastObject];
        
        [weakself.closeWinFrameArray removeAllObjects];
        [weakself.originXFrameArray removeAllObjects];
    };
}

/**
 *  设置framegroup index
 *
 *  @param webView
 */
- (void)setFrameGroupIndexWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytffframeGroupSetIndex"] = ^()
    {
        [ToolsFunction hideCustomProgress];
        // 避免用户 连续点击同一个frame时，重复回调的问题
        NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
        NSNumber * getCurrentIndex = [[NSUserDefaults standardUserDefaults] objectForKey:weakwebView.frameGroupName];
        // 此刻点击的 index 和 上一次的 index 不同时  才回调信息给JS 并滑动
        if (![[NSNumber numberWithInt:[dicArgs[@"index"] intValue]] isEqualToNumber: getCurrentIndex]) {

            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[dicArgs[@"index"] intValue]] forKey:weakwebView.frameGroupName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![[YTFConfigManager shareConfigManager] configisLoopWithJSParam:[weakself.frameGroupConfigsArray lastObject][@"isLoop"]]){
                    ((UIScrollView *)weakself.frameGroupScrollViewDictionary[[weakself.frameGroupNamesArray lastObject]]).contentOffset=CGPointMake(((UIScrollView *)weakself.frameGroupScrollViewDictionary[[weakself.frameGroupNamesArray lastObject]]).frame.size.width*([dicArgs[@"index"] intValue]), 0);
                } else {
                    ((UIScrollView *)weakself.frameGroupScrollViewDictionary[[weakself.frameGroupNamesArray lastObject]]).contentOffset=CGPointMake(((UIScrollView *)weakself.frameGroupScrollViewDictionary[[weakself.frameGroupNamesArray lastObject]]).frame.size.width*([dicArgs[@"index"] intValue] + 1), 0);
                }
            });
            
            weakself.selectedIndex = [dicArgs[@"index"] intValue];
            
            weakself.selectedFrameIndexBlock([dicArgs[@"index"] intValue], weakwebView);
        }

        UIScrollView *scrollViewGroup = nil;
        
        if (dicArgs[@"frameGroupName"])
        {
            scrollViewGroup = [weakself.frameGroupScrollViewDictionary objectForKey:dicArgs[@"frameGroupName"]];
        } else {
            scrollViewGroup = [weakself.frameGroupScrollViewDictionary objectForKey:((BaseWebView *)[AppDelegate shareAppDelegate].baseViewController.view.subviews.lastObject).frameGroupName];
        }
        
        NSDictionary *dicConfig = [weakself.frameGroupConfigsArray lastObject];
        NSMutableArray *arraySubWeb = [NSMutableArray new];
        UIView *container = nil;
        
        for (UIView *subView in scrollViewGroup.subviews)
        {
            if ([subView isMemberOfClass:[UIView class]])
            {
                container = subView;
            }
        }
        for (BaseWebView *baseView in container.subviews)
        {
            if ([baseView isMemberOfClass:[BaseWebView class]])
            {
                [arraySubWeb addObject:baseView];
            }
        }

        if ([dicConfig[@"frames"] firstObject] == nil)
        {
            return;
        }
        NSMutableArray *arrayFrames = [NSMutableArray arrayWithArray:dicConfig[@"frames"]];
        // 处理创建的scrollView数量
        if ([[YTFConfigManager shareConfigManager] configisLoopWithJSParam:dicConfig[@"isLoop"]])
        {
            [arrayFrames insertObject:[dicConfig[@"frames"] lastObject] atIndex:0];
            [arrayFrames addObject:[dicConfig[@"frames"] firstObject]];
        }
        
        if (dicArgs[@"frameGroupName"] || ((BaseWebView *)[AppDelegate shareAppDelegate].baseViewController.view.subviews.lastObject).frameGroupName)
        {
            BaseWebView *viewSelect = arraySubWeb[[dicArgs[@"index"] intValue]];
            
            // 未加载
            if (!viewSelect.isLoad)
            {
                // 加载自己
                NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:[arrayFrames objectAtIndex:[dicArgs[@"index"] intValue]][@"htmlUrl"] excuteWebView:weakwebView];
                [weakself preloadWebViewWithUrl:absoluteString webView:viewSelect];
                viewSelect.isLoad = true;
                viewSelect.webViewUrl = [NSURL URLWithString:absoluteString];
            } else {
                // 已加载
                // preload 加载左右
                if (weakself.preload == 0)
                {
                    return;
                }
            }
            
            // preload > 1
            for (int a = 1; a <= weakself.preload; a++)
            {
                // 加载左侧
                if ([dicArgs[@"index"] intValue] - a >= 0)
                {
                    BaseWebView *viewSelectLeft = arraySubWeb[[dicArgs[@"index"] intValue] - a];
                    if (!viewSelectLeft.isLoad)
                    {
                        NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:[arrayFrames objectAtIndex:[dicArgs[@"index"] intValue] - a][@"htmlUrl"] excuteWebView:weakwebView];
                        [weakself preloadWebViewWithUrl:absoluteString webView:viewSelectLeft];
                        viewSelectLeft.isLoad = true;
                        viewSelectLeft.webViewUrl = [NSURL URLWithString:absoluteString];
                    }
                }
                
                // 加载右侧
                if ([dicArgs[@"index"] intValue] + a < arrayFrames.count)
                {
                    BaseWebView *viewSelectRight = arraySubWeb[[dicArgs[@"index"] intValue] + a];
                    if (!viewSelectRight.isLoad)
                    {
                        NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:[arrayFrames objectAtIndex:[dicArgs[@"index"] intValue] + a][@"htmlUrl"] excuteWebView:weakwebView];
                        [weakself preloadWebViewWithUrl:absoluteString webView:viewSelectRight];
                        viewSelectRight.isLoad = true;
                        viewSelectRight.webViewUrl = [NSURL URLWithString:absoluteString];
                    }
                }
            }
        }
    };
}

/**
 *  设置framegroup属性
 *
 *  @param webView
 */
- (void)setFrameGroupAttributeWithWebView:(BaseWebView *)webView
{
    RCWeakSelf(self);
//    RCWeakSelf(webView);
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfframeGroupSetAttr"] = ^() {
       
        NSDictionary *dicArgs = [ToolsFunction JSContextArgsDictionary];
        
        if (dicArgs[@"frameGroupName"]==nil)
        {
            [weakself attrConfigFrameGroupJSparam:dicArgs];
        }
        
        UIView *container = nil;
        
        for (UIView *subView in weakself.appDelegate.baseViewController.view.subviews.lastObject.subviews)
        {
            if ([subView isMemberOfClass:[UIView class]])
            {
                container = subView;
            }
        }
        
        for (BaseWebView *targetFrameWebView in container.subviews)
        {
            if ([targetFrameWebView isMemberOfClass:[BaseWebView class]] && [targetFrameWebView.frameGroupName isEqualToString:dicArgs[@"frameGroupName"]]) {
                [weakself attrConfigFrameGroupJSparam:dicArgs];
            }
        }
    };
}

#pragma mark-- scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
      CGPoint offset = scrollView.contentOffset;
    
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded){
        self.markForIn_scrollDeleg = 0;
    }
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStatePossible){
        self.markForIn_scrollDeleg = 0;
    }
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        self.markForIn_scrollDeleg = 0;
    }
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {

        // group只有在 #1 isScroll == NO #2 isScroll == YES && isScrollSlip == YES  这两种情况下才会有slipWin手势 如果只有isScroll == YES则无slipWin手势
        if ((_number == 0) && (offset.x < -68)  && ((BaseWebView *)scrollView.superview).isDrawerWin == NO  && ((BaseWebView *)scrollView.superview).isSlipCloseWin == YES && (self.groupDicArgs[@"isScroll"] == [NSNumber numberWithBool:1]) && (self.groupDicArgs[@"isScrollSlip"] == [NSNumber numberWithBool:1])) {
            
        self.markForIn_scrollDeleg ++;
            
        if ( self.markForIn_scrollDeleg== 1) {
        
        self.subWebView = [ToolsFunction getSubBaseWebView:((BaseWebView *)(scrollView).superview)];
        [[FrameGroupManager shareManager].frameGroupScrollViewDictionary removeObjectForKey:((BaseWebView *)(scrollView).superview).frameGroupName];
        [[FrameGroupManager shareManager].frameGroupNamesArray removeLastObject];
        [[FrameGroupManager shareManager].frameGroupConfigsArray removeLastObject];
        [[FrameGroupManager shareManager].frameGroupCbIdsArray removeLastObject];
        

             dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.35 animations:^{
                    
                    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:((BaseWebView *)(scrollView).superview).bounds];
                    ((BaseWebView *)(scrollView).superview).layer.masksToBounds = NO;
                    ((BaseWebView *)(scrollView).superview).layer.shadowColor = [UIColor blackColor].CGColor;
                    ((BaseWebView *)(scrollView).superview).layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
                    ((BaseWebView *)(scrollView).superview).layer.shadowOpacity = 0.5f;
                    ((BaseWebView *)(scrollView).superview).layer.shadowPath = shadowPath.CGPath;
                    ((BaseWebView *)(scrollView).superview).frame = CGRectMake(
                                                                               ((BaseWebView *)(scrollView).superview).frame.origin.x + 50,
                                                                               ((BaseWebView *)(scrollView).superview).frame.origin.y,
                                                                               ((BaseWebView *)(scrollView).superview).frame.size.width,
                                                                               ((BaseWebView *)(scrollView).superview).frame.size.height);
                     self.subWebView.frame = CGRectMake(0,
                                                       self.subWebView.frame.origin.y,
                                                       self.subWebView.frame.size.width,
                                                       self.subWebView.frame.size.height);
                } completion:^(BOOL finished) {
                     self.subWebView.frame = CGRectMake(0,
                                                       self.subWebView.frame.origin.y,
                                                       self.subWebView.frame.size.width,
                                                       self.subWebView.frame.size.height);
                        [(BaseWebView *)(scrollView).superview removeFromSuperview];
                }];
            });
        }
      }
    }
}




#pragma mark - scrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    RCWeakSelf(self);
    RCWeakSelf(scrollView);

    int num1 = scrollView.contentOffset.x/scrollView.frame.size.width;
    if(num1==0)
    {
        _number= _num;
    }
    else if(num1==_num+1)
    {
        _number=1;
    } else {
     _number=num1;
    }
     if (![[YTFConfigManager shareConfigManager] configisLoopWithJSParam:[weakself.frameGroupConfigsArray lastObject][@"isLoop"]]){
       
         if(num1==0)
         {
            _number= 0;
         }
     } else {
        ((UIScrollView *)weakself.frameGroupScrollViewDictionary[[weakself.frameGroupNamesArray lastObject]]).contentOffset=CGPointMake(((UIScrollView *)weakself.frameGroupScrollViewDictionary[[weakself.frameGroupNamesArray lastObject]]).frame.size.width*_number, 0);
         _number = _number - 1;
    }
    
    weakself.selectedIndex = _number;
    // 回调index 给JS
    weakself.selectedFrameIndexBlock(_number, (UIWebView *)weakscrollView.superview);
    
    NSDictionary *dicConfig = [weakself.frameGroupConfigsArray lastObject];
    NSMutableArray *arraySubWeb = [NSMutableArray new];
    UIView *container = nil;
    
    for (UIView *subView in scrollView.subviews)
    {
        if ([subView isMemberOfClass:[UIView class]])
        {
            container = subView;
        }
    }
    
    for (BaseWebView *baseView in container.subviews)
    {
        if ([baseView isMemberOfClass:[BaseWebView class]])
        {
            [arraySubWeb addObject:baseView];
        }
    }
    
    if ([dicConfig[@"frames"] firstObject] == nil)
    {
        return;
    }
    NSMutableArray *arrayFrames = [NSMutableArray arrayWithArray:dicConfig[@"frames"]];
    // 处理创建的scrollView数量
    if ([[YTFConfigManager shareConfigManager] configisLoopWithJSParam:dicConfig[@"isLoop"]])
    {
        [arrayFrames insertObject:[dicConfig[@"frames"] lastObject] atIndex:0];
        [arrayFrames addObject:[dicConfig[@"frames"] firstObject]];
    }
    
    BaseWebView *viewSelect = arraySubWeb[_number];
    
    // 未加载
    if (!viewSelect.isLoad)
    {
        // 加载自己
        NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:[arrayFrames objectAtIndex:_number][@"htmlUrl"] excuteWebView:weakself.appDelegate.baseViewController.view.subviews.lastObject];
        [weakself preloadWebViewWithUrl:absoluteString webView:viewSelect];
        viewSelect.isLoad = true;
        viewSelect.webViewUrl = [NSURL URLWithString:absoluteString];
        
        
    } else {
        // 已加载
        // preload 加载左右
        if (weakself.preload == 0)
        {
            return;
        }
    }
    
    // preload > 1
    for (int a = 1; a <= weakself.preload; a++)
    {
        // 加载左侧
        if (_number - a >= 0)
        {
            BaseWebView *viewSelectLeft = arraySubWeb[_number - a];
            if (!viewSelectLeft.isLoad)
            {
                NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:[arrayFrames objectAtIndex:_number - a][@"htmlUrl"] excuteWebView:weakself.appDelegate.baseViewController.view.subviews.lastObject];
                [weakself preloadWebViewWithUrl:absoluteString webView:viewSelectLeft];
                viewSelectLeft.isLoad = true;
                viewSelectLeft.webViewUrl = [NSURL URLWithString:absoluteString];
            }
        }
        
        // 加载右侧
        if (_number + a < arrayFrames.count)
        {
            BaseWebView *viewSelectRight = arraySubWeb[_number + a];
            if (!viewSelectRight.isLoad)
            {
                NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:[arrayFrames objectAtIndex:_number + a][@"htmlUrl"] excuteWebView:weakself.appDelegate.baseViewController.view.subviews.lastObject];
                [weakself preloadWebViewWithUrl:absoluteString webView:viewSelectRight];
                viewSelectRight.isLoad = true;
                viewSelectRight.webViewUrl = [NSURL URLWithString:absoluteString];
            }
        }
    }
}

/**
 *  创建 sc
 *
 *  @param frameDictionary frames
 */

- (UIScrollView *)baseScrollView:(NSDictionary *)frameDictionary
{
    RCWeakSelf(self);
    
    UIScrollView *scrollViewFrameGroup  = weakself.frameGroupScrollViewDictionary[frameDictionary[@"frameGroupName"]];
    if (!scrollViewFrameGroup)
    {
        scrollViewFrameGroup = [[UIScrollView alloc] init];

        scrollViewFrameGroup.backgroundColor=[UIColor clearColor];
        scrollViewFrameGroup.bounces=YES;
        scrollViewFrameGroup.showsHorizontalScrollIndicator=NO;
        scrollViewFrameGroup.showsVerticalScrollIndicator=NO;
        scrollViewFrameGroup.delegate=weakself;
        scrollViewFrameGroup.pagingEnabled = YES;  //一定要设置 否则无滑动分页效果
        
        [weakself.frameGroupScrollViewDictionary setValue:scrollViewFrameGroup forKey:frameDictionary[@"frameGroupName"]];
    }
    
    
    NSDictionary * firstFrameUrl = [[frameDictionary[@"frames"] reverseObjectEnumerator].allObjects firstObject];
    NSString *absolutePathFirst = [[PathProtocolManager shareManager] getWebViewUrlWithString:firstFrameUrl[@"htmlUrl"] excuteWebView:_excWebView];
    firstWeb = [[BaseWebView alloc]initWithFrame:CGRectMake(0, 0,scrollViewFrameGroup.frame.size.width, scrollViewFrameGroup.frame.size.height)];
#ifdef DecryMode
    NSString *decryStringFirst = [RC4DecryModule decry_RC4WithByteArray:(Byte *)[[NSData dataWithContentsOfFile:absolutePathFirst] bytes] key:DecryKey fileData:[NSData dataWithContentsOfFile:absolutePathFirst]];
    [firstWeb loadHTMLString:decryStringFirst baseURL:[NSURL URLWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/assets/widget/"]]];
#else
//    NSString *newHTMLString =
//    [absolutePathFirst stringByAppendingString:
//     @"<script language=\"javascript\">document.ontouchstart =function(){document.location=\"myweb:touch:start\";};document.ontouchend =function(){document.location=\"myweb:touch:end\";};document.ontouchmove =function(){document.location=\"myweb:touch:move\";}</script>"];
    [firstWeb loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initFileURLWithPath:absolutePathFirst]]];
    firstWeb.isLoad = true;
#endif
    NSDictionary * lastFrameUrl = [[frameDictionary[@"frames"] reverseObjectEnumerator].allObjects lastObject];
    NSString *absolutePathLast = [[PathProtocolManager shareManager] getWebViewUrlWithString:lastFrameUrl[@"htmlUrl"] excuteWebView:_excWebView];
    lastWeb = [[BaseWebView alloc]initWithFrame:CGRectMake(scrollViewFrameGroup.frame.size.width*(weakself.num+1), 0, scrollViewFrameGroup.frame.size.width, scrollViewFrameGroup.frame.size.height)];
    lastWeb.isLoad = true;
    
#ifdef DecryMode
    NSString *decryStringLast = [RC4DecryModule decry_RC4WithByteArray:(Byte *)[[NSData dataWithContentsOfFile:absolutePathLast] bytes] key:DecryKey fileData:[NSData dataWithContentsOfFile:absolutePathLast]];
    [firstWeb loadHTMLString:decryStringLast baseURL:[NSURL URLWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/assets/widget/"]]];
#else
    [lastWeb loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initFileURLWithPath:absolutePathLast]]];
#endif
    
    return scrollViewFrameGroup;
 }

/**
 *  新建的webView 属性配置
 *
 *  @param frameWebView 当前frameWebView
 *  @param dicArgs      js 传递的数据
 */
- (void)attrConfigFrameGroupJSparam:(NSDictionary *)dicArgs
{
    RCWeakSelf(self);
    
    UIScrollView *scrollViewFrameGroup = weakself.frameGroupScrollViewDictionary[dicArgs[@"frameGroupName"]];
    
    
    //FIXME:长按scroll上的frame时会响应页面滑动。原因就是少了此属性的设置，此属性原来是有的，但是12月5日被我删除，未回忆起原因
    scrollViewFrameGroup.scrollEnabled = [[YTFConfigManager shareConfigManager] configisScrollWithJSParam:dicArgs[@"isScroll"]];

    if (weakself.frameGroupScrollViewDictionary[dicArgs[@"frameGroupName"]])
    {
        scrollViewFrameGroup = weakself.frameGroupScrollViewDictionary[dicArgs[@"frameGroupName"]];
    } else {
        scrollViewFrameGroup = weakself.frameGroupScrollViewDictionary[[weakself.frameGroupNamesArray lastObject]];
    }
    
    // backgroud
    if (dicArgs[@"background"]) {
        scrollViewFrameGroup.backgroundColor = [ToolsFunction hexStringToColor:[[YTFConfigManager shareConfigManager] configFrameGroupBackgroundColorWithJSParam:dicArgs[@"background"]]];
    }
    
    
    // ishidden
    if (dicArgs[@"ishidden"])
    {
        scrollViewFrameGroup.hidden = true;
    } else
    {
        scrollViewFrameGroup.hidden = false;
    }
    if (dicArgs[@"xywh"])
    {
        CGFloat scHeight = [dicArgs[@"xywh"][@"h"] floatValue];
        scrollViewFrameGroup.frame = CGRectMake([dicArgs[@"xywh"][@"x"] floatValue], [dicArgs[@"xywh"][@"y"] floatValue], [dicArgs[@"xywh"][@"w"] floatValue], scHeight);
    }
}

/**
 *  新建的webView 属性配置
 *
 *  @param frameWebView 当前frameWebView
 *  @param dicArgs      js 传递的数据
 */
- (void)attrConfigFrame:(BaseWebView *)frameWebView JSparam:(NSDictionary *)dicArgs
{
    
    RCWeakSelf(self);
    RCWeakSelf(frameWebView);
    // 配置页面弹动
    if (dicArgs[@"isBounces"])
    {
        frameWebView.scrollView.bounces = [[YTFConfigManager shareConfigManager] configFrameBounceWithJSParam:dicArgs[@"isBounces"]];
    }
    
    // backgroud 配置
    if (dicArgs[@"background"])
    {
        frameWebView.backgroundColor = [ToolsFunction hexStringToColor:[[YTFConfigManager shareConfigManager] configFrameBackgroundColorWithJSParam:dicArgs[@"background"]]];
    }
    
    // isEdit 配置
    if (dicArgs[@"isEdit"]){
        weakframeWebView.isEdit = [dicArgs[@"isEdit"] boolValue];//禁止长按编辑
    }
    
    // isHScrollBar 是否显示水平滚动条  配置
    if (dicArgs[@"isHScrollBar"])
    {
        [weakself hideisHScrollBar:frameWebView boolValue:[[YTFConfigManager shareConfigManager] configHorizonScrollBarWithJSParam:dicArgs[@"isHScrollBar"]]];
    }
    
    // isVScrollBar 是否显示垂直滚动条  配置
    if (dicArgs[@"isVScrollBar"])
    {
        [weakself hideisVScrollBar:frameWebView boolValue:[[YTFConfigManager shareConfigManager] configVeticalScrollBarWithJSParam:dicArgs[@"isVScrollBar"]]];
    }
    
    // isScale 页面是否缩放 配置
    if (dicArgs[@"isScale"])
    {
        frameWebView.scalesPageToFit = [[YTFConfigManager shareConfigManager] configWebViewScaleWithJSParam:dicArgs[@"isScale"]];
    }
    
    // isReload  页面已经打开时，是否重新加载页面
    if (dicArgs[@"isReload"] && [[YTFConfigManager shareConfigManager] configisReloadWithJSParam:dicArgs[@"isReload"]])
    {
        [frameWebView reload];
    }
    
    // isHidden
    if (dicArgs[@"ishidden"])
    {
        [frameWebView.superview sendSubviewToBack:frameWebView];
    } else {
        [frameWebView.superview bringSubviewToFront:frameWebView];
    }
    
    // softInputMode
    if (dicArgs[@"softInputMode"])
    {
        [YTFConfigManager shareConfigManager].softKeyboardMode = dicArgs[@"softInputMode"];
    }
    
//    // Frame  配置
//    [weakself setFrame:frameWebView dicArgs:dicArgs];
    
    // 滑动手势 配置
    BaseWebView *fatherWeb = (BaseWebView *)frameWebView.superview;
    if (fatherWeb.drawerWinName)
    {
        frameWebView.isSideWinPanGuester = YES;
        frameWebView.leftEdge = fatherWeb.leftEdge;
        frameWebView.leftZone = fatherWeb.leftZone;
        frameWebView.leftScale = fatherWeb.leftScale;
    }
}

/**
 *  isLoop 属性配置  frames初始化  _sc属性的定制
 *
 *  @param frameWebView frameWebView
 *  @param dicArgs      JS 数据
 */
- (void)configGroupIsLoop:(BaseWebView *)frameWebView dicArgs:(NSDictionary *)dicArgs container:(UIView *)container
{
    RCWeakSelf(self);
    UIScrollView *scrollViewFrameGroup = weakself.frameGroupScrollViewDictionary[dicArgs[@"frameGroupName"]];
    
    if (!weakself.closeWinFrameArray) {
        weakself.closeWinFrameArray = [NSMutableArray array];
    }
    
    if ([dicArgs[@"frames"] firstObject] == nil)
    {
        return;
    }
    
    NSMutableArray *arrayPreload = [NSMutableArray new];
    NSUInteger currentIndex = [dicArgs[@"index"] integerValue];
    
    NSMutableArray *arrayFrames = [NSMutableArray arrayWithArray:dicArgs[@"frames"]];
    // 处理创建的scrollView数量
    if ([[YTFConfigManager shareConfigManager] configisLoopWithJSParam:dicArgs[@"isLoop"]])
    {
        [arrayFrames insertObject:[dicArgs[@"frames"] lastObject] atIndex:0];
        [arrayFrames addObject:[dicArgs[@"frames"] firstObject]];
        currentIndex = [dicArgs[@"index"] integerValue] + 1;
    }
    
    BaseWebView *lastLayoutView = nil;
    for (int index = 0; index < arrayFrames.count; index++)
    {
        NSDictionary *dicFrame = arrayFrames[index];
        
        BaseWebView *frameWebView2 = nil;
        NSString *absoluteString = [[PathProtocolManager shareManager] getWebViewUrlWithString:dicFrame[@"htmlUrl"] excuteWebView:_excWebView];
        
        if (index == currentIndex)
        {
            frameWebView2 = [[BaseWebView alloc] initWithFrame:CGRectMake(scrollViewFrameGroup.frame.size.width*index, 0, scrollViewFrameGroup.frame.size.width, scrollViewFrameGroup.frame.size.height) url:absoluteString isWindow:false];
            frameWebView2.isLoad = true;
        } else {
            frameWebView2 = [[BaseWebView alloc] initWithFrame:CGRectMake(scrollViewFrameGroup.frame.size.width*index, 0, scrollViewFrameGroup.frame.size.width, scrollViewFrameGroup.frame.size.height) url:nil isWindow:false];
            frameWebView2.isLoad = false;
        }
        
        [arrayPreload addObject:frameWebView2];
        
        [weakself attrConfigFrame:frameWebView2 JSparam:dicFrame];
        frameWebView2.isGroupFrame = true;
        frameWebView2.frameGroupName = dicArgs[@"frameGroupName"];
        frameWebView2.frameName = dicFrame[@"frameName"];
        frameWebView2.groupFrameIndex = index;
        frameWebView2.webViewUrl = [NSURL URLWithString:absoluteString];
        [weakself.closeWinFrameArray addObject:frameWebView2];

        frameWebView2.delegate = weakself.appDelegate.baseViewController;

        [container addSubview:frameWebView2];
            
        [frameWebView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(scrollViewFrameGroup);
            make.width.mas_equalTo(scrollViewFrameGroup.frame.size.width);
            make.height.mas_equalTo(scrollViewFrameGroup);
            
            if ( lastLayoutView )
            {
                make.left.mas_equalTo(lastLayoutView.mas_right);
            }
            else
            {
                make.left.mas_equalTo(scrollViewFrameGroup.mas_left);
            }
        }];
            
        lastLayoutView = frameWebView2;
        
        if (dicArgs[@"isScroll"] == [NSNumber numberWithBool:0])
        {
            if (((BaseWebView *)((UIScrollView *)frameWebView2.superview.superview).superview).isSlipCloseWin == YES )
            {
                // 判断父 是否为drawerWin
                if (!((BaseWebView *)((UIScrollView *)frameWebView2.superview.superview).superview).isDrawerWin )
                {
                    // 父视图为正常win
                    // 给第一个 frame添加 手势
                    frameWebView2.isSlipCloseWin = YES;
                }
            }
        }
        
        NSString *appendStringKey = [NSString stringWithFormat:@"%d-%@",index, [[ToolsFunction dictionaryToJsonString:[arrayFrames objectAtIndex:index][@"htmlParam"]] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        
        if ([arrayFrames objectAtIndex:index][@"htmlParam"])
        {
            [weakself.htmlParamDictionary setValue:frameWebView2 forKey:appendStringKey];
        }
    }
    
    [self.preloadDictionary setValue:arrayPreload forKey:dicArgs[@"frameGroupName"]];

    [weakself.frameGroupConfigsArray replaceObjectAtIndex:weakself.frameGroupConfigsArray.count - 1 withObject:dicArgs];
    [weakself.closeWinFrameArray removeAllObjects];
    [weakself attrConfigFrame:frameWebView JSparam:dicArgs];
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lastLayoutView.mas_right);
    }];
    
    scrollViewFrameGroup.contentSize = CGSizeMake(arrayFrames.count*scrollViewFrameGroup.frame.size.width, scrollViewFrameGroup.frame.size.height);
    
    scrollViewFrameGroup.contentOffset = CGPointMake(scrollViewFrameGroup.frame.size.width * currentIndex, 0);
}

/**
 *  隐藏水平滑动条
 *
 *  @param frameWebView 指定的WebView
 */
- (void)hideisHScrollBar:(BaseWebView *)frameWebView boolValue:(BOOL)ytBool
{
    frameWebView.scrollView.showsHorizontalScrollIndicator = ytBool;
}

/**
 *  隐藏垂直滑动条
 *
 *  @param frameWebView 指定的WebView
 */
- (void)hideisVScrollBar:(BaseWebView *)frameWebView boolValue:(BOOL)ytBool
{
    frameWebView.scrollView.showsVerticalScrollIndicator = ytBool;
}

#pragma mark - 实现滑动手势
- (void)groupPan:(UIPanGestureRecognizer *)pan
{
    RCWeakSelf(self);
    BaseWebView *  sideWebView;
    BaseWebView *mainWeb = weakself.appDelegate.baseViewController.view.subviews.lastObject;
    for (BaseWebView *baseWebView in weakself.appDelegate.baseViewController.view.subviews)
    {
        if ([baseWebView.drawerWinName isEqualToString:mainWeb.drawerWinName] && baseWebView!=mainWeb) {
           sideWebView = baseWebView;
        }
    }
    [panDelegateObj groupSidePanGuester:_excWebView sideWin:sideWebView guester:pan leftEdge:[[YTFConfigManager shareConfigManager] configLeftEdge:_excWebView.leftEdge] leftZone:[[YTFConfigManager shareConfigManager] configLeftZone:_excWebView.leftZone] leftScale:_excWebView.leftScale];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
     RCWeakSelf(self);
    //  此处设置 group的滑动翻页属性
    if ([weakself.groupDicArgs[@"isScroll"] boolValue] == NO) {
        
        return NO;
    }else{
    
        return YES;
    }
}

-(BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    
    if ([view isKindOfClass:[UIImageView class]])
    {
        return NO;
    }
    
    return YES;
}

- (void)preloadWebViewWithUrl:(NSString *)url webView:(UIWebView *)webView
{
    if (!url)
    {
        return;
    }
#ifdef DecryMode
    if ([url hasPrefix:@"http"])
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [webView loadRequest:request];
    } else {
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
        [webView loadHTMLString:decryString baseURL:[NSURL URLWithString:url]];
    }
#else
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [webView loadRequest:request];
#endif
}


#pragma mark - Notification Method

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
    
    UIDeviceOrientation  orient =  ((UIDevice *)notification.object).orientation;
    
    NSString * orientString  =   UIDeviceOrientationTypeIdentifier(orient);
    if (orient == UIDeviceOrientationPortraitUpsideDown ||
        orient == UIDeviceOrientationFaceUp ||
        orient == UIDeviceOrientationFaceDown ||
        orient == UIDeviceOrientationUnknown) {
        return;
    }
    
  
    
    NSString * lastOrientString =  [[NSUserDefaults standardUserDefaults]objectForKey:@"lastOrientString"];
   
    
    UIScrollView *scrollViewFrameGroup = self.frameGroupScrollViewDictionary[self.groupDicArgs[@"frameGroupName"]];
    
    UIView *container = nil;
    for (UIView *subView in scrollViewFrameGroup.subviews)
    {
        container = subView;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat offsetX = self.groupDicArgs[@"xywh"][@"x"] == nil ? 0 : [self.groupDicArgs[@"xywh"][@"x"] floatValue];
        CGFloat offsetY = self.groupDicArgs[@"xywh"][@"y"] == nil ? 0 : [self.groupDicArgs[@"xywh"][@"y"] floatValue];
        
        CGFloat offsetW = 0;
        CGFloat offsetH = 0;
        
        if (self.groupDicArgs[@"xywh"][@"w"] && [self.groupDicArgs[@"xywh"][@"w"] isKindOfClass:[NSString class]] && [self.groupDicArgs[@"xywh"][@"w"] isEqualToString:@"auto"])
        {
            offsetW = ScreenWidth - offsetX;
        } else {
            offsetW = [self.groupDicArgs[@"xywh"][@"w"] floatValue];
        }
        
        if (self.groupDicArgs[@"xywh"][@"h"] && [self.groupDicArgs[@"xywh"][@"h"] isKindOfClass:[NSString class]] && [self.groupDicArgs[@"xywh"][@"h"] isEqualToString:@"auto"])
        {
            offsetH = ScreenHeight - offsetY;
        } else {
            offsetH = [self.groupDicArgs[@"xywh"][@"h"] floatValue];
        }
        
        CGFloat marginLeft = self.groupDicArgs[@"xywh"][@"marginLeft"] == nil ? 0 : [self.groupDicArgs[@"xywh"][@"marginLeft"] floatValue];
        CGFloat marginTop = self.groupDicArgs[@"xywh"][@"marginTop"] == nil ? 0 : [self.groupDicArgs[@"xywh"][@"marginTop"] floatValue];
        
        [scrollViewFrameGroup mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(scrollViewFrameGroup.superview).with.offset(marginTop + offsetY);
            make.left.equalTo(scrollViewFrameGroup.superview).with.offset(marginLeft + offsetX);
            make.right.equalTo(scrollViewFrameGroup.superview).with.offset(self.rightMar);
            make.bottom.equalTo(scrollViewFrameGroup.superview).with.offset(self.bottomMar);
        }];
        
        //scrollview里放个View
        [container mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(scrollViewFrameGroup);
            make.height.equalTo(scrollViewFrameGroup);
        }];
        
        for (BaseWebView *webView in container.subviews)
        {
            [webView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.and.bottom.equalTo(scrollViewFrameGroup);
                make.width.mas_equalTo(scrollViewFrameGroup.frame.size.width);
                make.height.mas_equalTo(scrollViewFrameGroup);
            }];
            
            if (webView == container.subviews.lastObject)
            {
                [container mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(webView.mas_right);
                }];
            }
        }
    });

    if (![lastOrientString isEqualToString:orientString]  && lastOrientString!= nil) {
      
        if ([[YTFConfigManager shareConfigManager] configisLoopWithJSParam:self.groupDicArgs[@"isLoop"]]  )
        {
            [scrollViewFrameGroup setContentOffset:CGPointMake((_number + 1) * scrollViewFrameGroup.frame.size.width, 0) animated:false];
        } else {
            [scrollViewFrameGroup setContentOffset:CGPointMake(_number * scrollViewFrameGroup.frame.size.width, 0) animated:false];
        }
    }
  

      [[NSUserDefaults standardUserDefaults]setObject: UIDeviceOrientationTypeIdentifier(orient) forKey:@"lastOrientString"];
}

@end
