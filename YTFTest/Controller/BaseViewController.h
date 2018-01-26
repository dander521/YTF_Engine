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

#import <UIKit/UIKit.h>
#import "BaseWebView.h"

@interface BaseViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) BaseWebView *indexWebView; // 程序入口
@property (nonatomic, strong) UIView *popView; // popView

@end


