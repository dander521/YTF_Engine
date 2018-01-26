/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    JumpToApp
 * =============================================================================
 */

#import "YTFModule.h"

@interface JumpToApp : YTFModule


/**
 判断该app 是否已经安装到用户手机

 @param args js参数

 @return 同步返回判断结果
 */
- (NSDictionary *)targetAppIsInstall:(NSDictionary *)args;


/**
 打开AppStore

 @param args js参数
 */
- (void)openAppStore:(NSDictionary *)args;
@end
