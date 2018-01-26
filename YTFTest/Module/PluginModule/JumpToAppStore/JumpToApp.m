/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    JumpToApp.
 * =============================================================================
 */

#import "JumpToApp.h"

@interface JumpToApp ()
{
    NSString *    targetCbid;
    id     jumpToAppWebView;

}
@end
@implementation JumpToApp

/**
 判断该app 是否已经安装到用户手机
 
 @param args js参数
 
 @return 同步返回判断结果
 */
- (NSDictionary *)targetAppIsInstall:(NSDictionary *)args{
  
    targetCbid                   = args[@"cbId"];
    jumpToAppWebView             = args[@"target"];
    NSDictionary * prodInfoDic   = args[@"args"];
    
        // 2.判断手机中是否安装了对应程序
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",prodInfoDic[@"URLScheme"]]]]) {
        // 3. 打开应用程序App-B
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/gb/app/yi-dong-cai-bian/id391945719?mt=8"]];
        
        return @{@"status":@1};
    } else {
         // NSLog(@"没有安装");
        return @{@"status":@0};
    }
    
}


/**
 打开AppStore
 
 @param args js参数
 */
- (void)openAppStore:(NSDictionary *)args{

    /*
   URL =  tms-apps://itunes.apple.com/gb/app/yi-dong-cai-bian/id391945719?mt=8
     */
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/gb/app/yi-dong-cai-bian/id391945719?mt=8"]];

}
@end
