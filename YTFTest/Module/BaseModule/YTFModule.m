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

#import "YTFModule.h"
#import "BaseWebView.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "SlipCloseWinGuesterManager.h"
#import "UIView+SetAndGet.h"

@interface YTFModule ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, weak)  BaseWebView *targetWebView;

@end

@implementation YTFModule

/**
 在指定窗口上面添加视图
 
 @param view 视图，
 
 @param fixedOn 目标窗口名字，默认为主窗口名字
 
 @param fixed 视图是否固定，为NO时跟随目标窗口内容滚动而滚动
 
 @return 添加视图是否成功，若fixedOn对应子窗口未找到则返回失败   
 */
- (BOOL)addSubview:(UIView *)view fixedOn:(NSString *)fixedOn fixed:(BOOL)fixed{

    self.appDelegate = [AppDelegate shareAppDelegate];
    // fixedOn 目标窗口名字 为空时 默认为当前最上层的窗口
    if (fixedOn.length == 0) {
        for (BaseWebView *tempWeb in (self.appDelegate.baseViewController.view.subviews).lastObject.subviews){
            if ([tempWeb isMemberOfClass:[BaseWebView class]]){
                self.targetWebView = tempWeb;
                if (fixed) {
                     [view isFirstResponder];
                     view.userInteractionEnabled = YES;
                     self.targetWebView.moduleCustomView = view;
                     [self.targetWebView.scrollView addSubview:view];
                }else{
                    // view 不随着webView滚定，直接加在win的webView即可
                     [self.targetWebView addSubview:view];
                }
            }
        }
    }
    //根据传入的窗口名 找到对应窗口,判断名字是属于 win  还是属于 frame
    else{
        for (BaseWebView *tempWeb in (self.appDelegate.baseViewController.view.subviews)){            
            if ([tempWeb isMemberOfClass:[BaseWebView class]]
                && tempWeb.winName.length != 0
                && [tempWeb.frameName isEqualToString:fixedOn]){
                
                     self.targetWebView = tempWeb;
                     [self.targetWebView addSubview:view];
                
                }else{
        for (BaseWebView *frameWeb in tempWeb.subviews){
            if ([frameWeb isMemberOfClass:[BaseWebView class]]
                && frameWeb.frameName.length != 0
                && [frameWeb.frameName isEqualToString:fixedOn]){
                            
                      self.targetWebView = frameWeb;
                      [self.targetWebView addSubview:view];
                
                     }
                  }
               }
           }
       }
    return [self.targetWebView.subviews containsObject:view];
}

/**
 执行回调方法返回数据
 
 @param cbId 回调函数id
 
 @param dataDict 返回的数据
 
 @param errDict 错误信息
 
 @param doDelete 执行回调后是否删除回调函数对象
 */
- (void)sendCallBackDataWithCallbackBadge:(UIWebView *)currentWebView
                                     cbid:(NSString *)bCbid
                                 dataDict:(NSDictionary *)dataDict
                                  errDict:(NSDictionary *)errDict
                                 doDelete:(BOOL)doDelete{

    NSString * doDelString;
    if (doDelete) {
         doDelString = @"true";
    }else{
         doDelString = @"false";
    }
    
    NSString * backData = [ToolsFunction dicToJavaScriptString:dataDict];
    [currentWebView stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"YTFcb.on('%@','%@','%@');",bCbid,backData,doDelString]];
}

/**
 获取指定窗口对象
 
 @param name 窗口名字
 
 @return 窗口对象
 */
- (UIWebView *)getWebViewByName:(NSString *)name{

    BaseWebView *targetWebView;
    // 在win找webView
    for (BaseWebView *tempWeb in (self.appDelegate.baseViewController.view.subviews)){
        if ([tempWeb isMemberOfClass:[BaseWebView class]]){
            if ([tempWeb.winName isEqualToString:name]){
                targetWebView = tempWeb;
            }else{
    // 在win的frame找webView
    for (BaseWebView *tempFrame in (tempWeb.subviews)){
        if ([tempFrame isMemberOfClass:[BaseWebView class]] && tempFrame.frameName.length!=0){
            if ([tempFrame.frameName isEqualToString:name]){
               targetWebView = tempFrame;
              }
            }
          }
        }
      }
    }
    return targetWebView;
}

// getter
- (BaseViewController *)viewController{
    return [AppDelegate shareAppDelegate].baseViewController;
}


@end
