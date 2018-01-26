/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Error message manager.
 * =============================================================================
 */

#import "ErrorManager.h"
#import "Definition.h"
#import "YTFConfigManager.h"

@implementation ErrorManager

// 单例
+ (instancetype)shareManager
{
    static ErrorManager *errorManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        errorManager = [[self alloc] init];
    });
    
    return errorManager;
}

/**
 *  JS错误信息
 *
 *  @param webView
 */
- (void)errorMessageWithWebView:(BaseWebView *)webView
{
    [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfError"] = ^(NSDictionary *paramDictionary)
    {
        /*
         {
         sLine = 25;
         sMsg = "ReferenceError: Can't find variable: openYtfmap54";
         sUrl = "file:///var/containers/Bundle/Application/D4DA1597-45DD-4EA1-B29B-EBED51F0F5F6/YTFTest.app/assets/widget/index.html";
         }
         */
        
        NSString *stringAssets = @"assets/";
        
        NSRange range = [paramDictionary[@"sUrl"] rangeOfString:stringAssets];
        
        NSString *stringResult = paramDictionary[@"sUrl"];
        if (range.length != 0)
        {
            stringResult = [stringResult substringFromIndex:range.location];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([YTFConfigManager shareConfigManager].isDebugMode)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JS错误信息" message:[NSString stringWithFormat:@"错误文件：%@\n错误行数：%@\n错误描述：%@", stringResult, paramDictionary[@"sLine"], paramDictionary[@"sMsg"]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        });
    };
}

@end
