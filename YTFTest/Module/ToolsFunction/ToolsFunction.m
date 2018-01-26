/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic function method.
 * =============================================================================
 */

#import "ToolsFunction.h"
#import "Definition.h"
#import <UIKit/UIKit.h>
#import "UIImage+YTFGIF.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>


@interface ToolsFunction ()

@property (nonatomic, weak) BaseWebView *subBaseWebView;


@end

@implementation ToolsFunction

/**
 统一的回调方法
 
 @param excEutWebView 当前的WebView
 @param cbID          方法的cbid
 @param successDic    成功的字典
 @param errorDic      失败错误的字典
 */
+ (void)callBackExcWebView:(BaseWebView *)excEutWebView
                      cbID:(NSString *)cbID
             successParams:(NSDictionary *)successDic
                  errorStr:(NSDictionary *)errorDic{
   
    // 由于需要调用一个实例方法  performSelector 所以需要一个对象
    static ToolsFunction * callBack = nil;
    static dispatch_once_t oncetoken;
    _dispatch_once(&oncetoken, ^{
        callBack = [[ToolsFunction alloc]init];
    });
    NSDictionary * tempMiddleDic;
    if (successDic!=nil && errorDic==nil) {
        tempMiddleDic = [NSDictionary dictionaryWithDictionary:successDic];
    }
    //  ret 转 json 字符串
     NSString * callBackFinalData =   [ToolsFunction retToJson:tempMiddleDic];
    // 将字符串拼接
    NSString * callBackString;
    if (successDic!=nil && errorDic==nil) {
          callBackString = [NSString stringWithFormat:@"YTFcb.on('%@','%@',null,false);",cbID,callBackFinalData];
    }
    
   // 执行CallBack
    NSArray * selectArray = [NSArray arrayWithObjects:callBackString,excEutWebView,nil];
    
    [callBack performSelector:@selector(jsMediaCallBack:) withObject:selectArray afterDelay:NO];


}



/**
 performSelector 执行回调

 @param array webview和id 的数组
 */
- (void)jsMediaCallBack:(NSArray *)array{
    
   [array[1] stringByEvaluatingJavaScriptFromString:array[0]];

}

/**
 字典转 json 字符串

 @param paramsDic 字典

 @return json 字符串
 */
+ (NSString *)retToJson:(NSDictionary *)paramsDic{
    
    NSString * callBackJsonStr = [ToolsFunction dictionaryToJsonString:paramsDic];
    NSString * callBackFinalData =  [callBackJsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"];
    callBackFinalData  = [callBackFinalData stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    return callBackFinalData;
}

/**
 *  Json文件通过相对路径转换为字典
 *
 *  @param fileRelativePath 文件相对路径
 *
 *  @return 字典对象
 */
+ (NSDictionary *)JsonFileToDictionaryWithFileRelativePath:(NSString *)fileRelativePath
{
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:fileRelativePath ofType:nil];
    
    
    NSData *dataJson = [NSData dataWithContentsOfFile:configFilePath];
    NSDictionary *dicJson;
    if (dataJson) {
        dicJson = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:nil];
    }
    
     return dicJson;
}

/**
 *  Json文件通过绝对路径转换为字典
 *
 *  @param fileAbsolutePath 文件绝对路径
 *
 *  @return 字典对象
 */
+ (NSDictionary *)JsonFileToDictionaryWithFileAbsolutrPath:(NSString *)fileAbsolutePath
{
    NSData *dataJson = [NSData dataWithContentsOfFile:fileAbsolutePath];
    NSDictionary *dicJson = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:nil];
    
    return dicJson;
}

#pragma mark - Dictionary To Json

/**
 字典转Json字符串

 @param dictionary 转换字典

 @return Json字符串
 */
+ (NSString *)dictionaryToJsonString:(NSDictionary *)dictionary
{
    NSError *parseError = nil;
    if (!dictionary)
    {
        return nil;
    } else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&parseError];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

/**
 *  Json转字典
 *
 *  @param responseObject 请求返回Json数据
 *
 *  @return 字典
 */
+ (NSDictionary *)responseConvertToDictionary:(id)responseObject
{
    NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
    if (string == nil)
    {
        return nil;
    }
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //  dic 原来是字典
    id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    return dic;
}


/**
 *  将字典直接转化为 能回调 JS 的字符串
 *
 *  @param dictionary 转换字典
 *
 *  @return Json字符串
 */
+ (NSString *)dicToJavaScriptString:(NSDictionary *)dictionary
{
    NSError *parseError = nil;
    if (!dictionary)
    {
        return nil;
    } else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *jsonString  = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *correctJsonString = [jsonString  stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        return correctJsonString;
    }
}

/**
 *  字符串转颜色
 *
 *  @param stringToConvert NSString
 *
 *  @return uiclolor
 */
+ (UIColor *)hexStringToColor:(NSString *)stringToConvert
{
    /*
     #fff
     #333333
     rgba(0,1,2,1)
     */
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // Scan values
    unsigned int r, g, b;
    float a;
    
    if ([cString hasPrefix:@"#"])
    {
        // 333333
        if (cString.length == 7)
        {
            cString = [cString substringFromIndex:1];
            NSRange range;
            range.location = 0;
            range.length = 2;
            NSString *rString = [cString substringWithRange:range];
            range.location = 2;
            NSString *gString = [cString substringWithRange:range];
            range.location = 4;
            NSString *bString = [cString substringWithRange:range];
            
            
            [[NSScanner scannerWithString:rString] scanHexInt:&r];
            [[NSScanner scannerWithString:gString] scanHexInt:&g];
            [[NSScanner scannerWithString:bString] scanHexInt:&b];
            
            a = 1.0;
        } else if (cString.length == 9) {
            // FFFFFFFF
            cString = [cString substringFromIndex:1];
            NSRange range;
            range.location = 0;
            range.length = 2;
            NSString *aString = [cString substringWithRange:range];
            range.location = 2;
            range.length = 2;
            NSString *rString = [cString substringWithRange:range];
            range.location = 4;
            range.length = 2;
            NSString *gString = [cString substringWithRange:range];
            range.location = 6;
            NSString *bString = [cString substringWithRange:range];
            
            unsigned int inta;
            
            [[NSScanner scannerWithString:aString] scanHexInt:&inta];
            [[NSScanner scannerWithString:rString] scanHexInt:&r];
            [[NSScanner scannerWithString:gString] scanHexInt:&g];
            [[NSScanner scannerWithString:bString] scanHexInt:&b];
            
            a = (float)(inta/255.0);
        } else if (cString.length == 4)
        {
            // #123
            cString = [cString substringFromIndex:1];
            
            NSRange range;
            range.location = 0;
            range.length = 1;
            NSString *rString = [cString substringWithRange:range];
            range.location = 1;
            range.length = 1;
            NSString *gString = [cString substringWithRange:range];
            range.location = 2;
            range.length = 1;
            NSString *bString = [cString substringWithRange:range];
            
            rString = [NSString stringWithFormat:@"%@%@", rString, rString];
            gString = [NSString stringWithFormat:@"%@%@", gString, gString];
            bString = [NSString stringWithFormat:@"%@%@", bString, bString];
            
            [[NSScanner scannerWithString:rString] scanHexInt:&r];
            [[NSScanner scannerWithString:gString] scanHexInt:&g];
            [[NSScanner scannerWithString:bString] scanHexInt:&b];
            
            a = 1.0;
            
        } else if (cString.length == 5)
        {
            // #3333
            cString = [cString substringFromIndex:1];
            
            NSRange range;
            range.location = 0;
            range.length = 1;
            NSString *aString = [cString substringWithRange:range];
            range.location = 1;
            range.length = 1;
            NSString *rString = [cString substringWithRange:range];
            range.location = 2;
            range.length = 1;
            NSString *gString = [cString substringWithRange:range];
            range.location = 3;
            range.length = 1;
            NSString *bString = [cString substringWithRange:range];
            
            aString = [NSString stringWithFormat:@"%@%@", aString, aString];
            rString = [NSString stringWithFormat:@"%@%@", rString, rString];
            gString = [NSString stringWithFormat:@"%@%@", gString, gString];
            bString = [NSString stringWithFormat:@"%@%@", bString, bString];
            
            unsigned int inta;
            
            [[NSScanner scannerWithString:aString] scanHexInt:&inta];
            [[NSScanner scannerWithString:rString] scanHexInt:&r];
            [[NSScanner scannerWithString:gString] scanHexInt:&g];
            [[NSScanner scannerWithString:bString] scanHexInt:&b];
            
            a = (float)(inta/255.0);
        }
    } else if ([cString hasPrefix:@"RGBA"])
    {
        // RGBA(22,1,22,0)
        cString = [cString substringFromIndex:5];
        cString = [cString substringToIndex:cString.length - 1];
        NSArray *arrayRGBA = [cString componentsSeparatedByString:@","];
        if (arrayRGBA)
        {
            r = [arrayRGBA[0] intValue];
            g = [arrayRGBA[1] intValue];
            b = [arrayRGBA[2] intValue];
            a = [arrayRGBA[3] floatValue];
        }
    } else if ([cString hasPrefix:@"RGB"])
    {
        // RGBA(22,1,22,0)
        cString = [cString substringFromIndex:4];
        cString = [cString substringToIndex:cString.length - 1];
        NSArray *arrayRGBA = [cString componentsSeparatedByString:@","];
        if (arrayRGBA)
        {
            r = [arrayRGBA[0] intValue];
            g = [arrayRGBA[1] intValue];
            b = [arrayRGBA[2] intValue];
            a = 1.0;
        }
    }
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:(float) a];
}

#pragma mark - Files Operation

// 拷贝文件/文件夹到目标路径
+ (void)copyFilesWithResourcePath:(NSString *)resourcePath destinationPath:(NSString *)destinationPath
{
    [ToolsFunction createDirectoryWithPath:destinationPath];
    
    NSArray *arrayItemPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:nil];

    if (arrayItemPath.count == 0)
    {
        return;
    }
    
    for (int i = 0; i < arrayItemPath.count; i++)
    {
        NSString *currentPath = [NSString stringWithFormat:@"%@/%@", resourcePath, arrayItemPath[i]];

        BOOL isDirectory = [ToolsFunction judgeFileOrFileDirectoryWithPath:currentPath];
        if (isDirectory)
        {
            NSString *subDestinationPath = [NSString stringWithFormat:@"%@/%@", destinationPath, arrayItemPath[i]];
            [ToolsFunction createDirectoryWithPath:subDestinationPath];
            
            // 递归拷贝文件
            [ToolsFunction copyFilesWithResourcePath:currentPath destinationPath:subDestinationPath];
        } else {
            
            NSString *bundlePath = [currentPath substringFromIndex:[currentPath rangeOfString:@"assets"].location];

            NSString *copyFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@", bundlePath] ofType:nil];
            NSString *copyDestinationPath = [NSString stringWithFormat:@"%@/%@", destinationPath, arrayItemPath[i]];
            
            NSError *error;
            [[NSFileManager defaultManager] copyItemAtPath:copyFilePath toPath:copyDestinationPath error:&error];
        }
    }
}

// 判断文件/文件夹
+ (BOOL)judgeFileOrFileDirectoryWithPath:(NSString *)path
{
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    return isDirectory;
}

// 创建文件夹
+ (BOOL)createDirectoryWithPath:(NSString *)path
{
    BOOL isCreateSuccess = false;
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        isCreateSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        isCreateSuccess = true;
    }
    
    return isCreateSuccess;
}

// 判断文件是否存在
+ (BOOL)isFileExistAtPath:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

#pragma mark - JSContext Param

// 获取CBID
+ (NSString *)JSContextCBID
{
    return [[JSContext currentArguments][0] toDictionary][@"cbId"];
}

// 获取args参数字典
+ (NSDictionary *)JSContextArgsDictionary
{
    return [[JSContext currentArguments][0] toDictionary][@"args"];
}

#pragma mark - NSDate <-> NSString

//NSDate转NSString
+ (NSString *)stringFromDate:(NSDate *)date
{
    //获取系统当前时间
    NSDate *currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    return currentDateString;
}

//NSString转NSDate
+ (NSDate *)dateFromString:(NSString *)string
{
    //需要转换的字符串
    NSString *dateString = @"2015-06-26 08:08:08";
    //设置转换格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString转NSDate
    NSDate *date=[formatter dateFromString:dateString];
    return date;
}

// 获取当前时间戳字符串
+ (NSString *)getCurrentTimeIntervalString
{
    NSString *timeInterval = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    return timeInterval;
}

#pragma mark - Progress

/**
 *  显示进度提示框
 *
 *  @param webView JSContext
 */
+ (void)showCustomProgress
{
    BOOL isExist = false;
    for (UIView *progressView in [AppDelegate shareAppDelegate].baseViewController.view.subviews)
    {
        if (progressView.tag == Gif_View_Tag)
        {
            isExist = true;
            break;
        }
    }
    
    if (!isExist)
    {
        UIView *gifView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100.0, 100.0)];
        gifView.tag = Gif_View_Tag;
        gifView.backgroundColor = [ToolsFunction hexStringToColor:@"#00FFFFFF"];
        
        CGRect rect = CGRectMake(0, 0, 50.0, 50.0);
        UIImageView *imageViewGif = [[UIImageView alloc] initWithFrame:rect];
        
        NSString *absolutePath = [[NSBundle mainBundle] pathForResource:@"ytf_loading_blue.gif" ofType:nil];
        
        NSData *dataGif = [NSData dataWithContentsOfFile:absolutePath];
        imageViewGif.image = [UIImage sd_animatedGIFWithData:dataGif];
        imageViewGif.center = gifView.center;
        
        UILabel *labelTextBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20.0)];
        labelTextBottom.text = @"加载中...";
        labelTextBottom.font = [UIFont systemFontOfSize:12.0];
        labelTextBottom.textColor = [ToolsFunction hexStringToColor:@"#FF333333"];
        labelTextBottom.textAlignment = NSTextAlignmentCenter;
        labelTextBottom.center = CGPointMake(imageViewGif.center.x, CGRectGetMaxY(imageViewGif.frame) + 12.0);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [gifView addSubview:imageViewGif];
            [gifView addSubview:labelTextBottom];
            
            gifView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2 - 60.0);
            
            [[AppDelegate shareAppDelegate].baseViewController.view addSubview:gifView];
        });
    }
}

/**
 *  隐藏进度提示框
 *
 *  @param webView JSContext
 */
+ (void)hideCustomProgress
{
    for (UIView *progressView in [AppDelegate shareAppDelegate].baseViewController.view.subviews)
    {
        if (progressView.tag == Gif_View_Tag)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressView removeFromSuperview];
                [AppDelegate shareAppDelegate].baseViewController.view.userInteractionEnabled = true;
            });
        }
    }
}

/**
 *  获取文件mimeType
 *
 *  @param string
 *
 *  @return
 */
+ (NSString *)mimeWithString:(NSString *)string
{
    // 先从参入的路径的出URL
    NSURL *url = [NSURL fileURLWithPath:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 只有响应头中才有其真实属性 也就是MIME
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    return response.MIMEType;
}

/**
 获取当前 win 的上一层 win ，上一层win也需要跟着做动画
 
 @param currentBaseWebView
 
 @return
 */
+ (BaseWebView *)getSubBaseWebView:(BaseWebView *)currentBaseWebView{
    
    static ToolsFunction * callBack = nil;
    static dispatch_once_t oncetoken;
    _dispatch_once(&oncetoken, ^{
        callBack = [[ToolsFunction alloc]init];
    });
    
    int mark_cycleNum = 0;
    for (id tempBaseWeb in [[([AppDelegate shareAppDelegate].baseViewController.view.subviews) reverseObjectEnumerator]allObjects]){
        if ([tempBaseWeb isKindOfClass:[BaseWebView class]]){
            mark_cycleNum ++;
            if (mark_cycleNum == 2) {
                callBack.subBaseWebView = tempBaseWeb;
                
                break;
            }
        }
    }
    return callBack.subBaseWebView;
}


/**
 获取指定对象的属性列表
 
 @param obj 自定义的对象
 
 @return 属性名字_字符串_的数组
 */
+ (NSMutableArray *)getAllProperties:(id)obj
{
    
    u_int count;
    Ivar *vars = class_copyIvarList([obj class], &count); // 获取到所有的变量列表
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    // 遍历所有的成员变量
    for (int i = 0; i < count; i++) {
        Ivar ivar = vars[i]; // 取出第i个位置的成员变量
        
        const char *propertyName = ivar_getName(ivar); // 通过变量获取变量名
        // const char *propertyType = ivar_getTypeEncoding(ivar); // 获取变量编码类型
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
        // printf("---%s--%s\n", propertyName, propertyType);
    }
    return propertiesArray;
}


/**
 移除webView上所有的模块对象
 
 @param weakwebView 要关闭的  win
 @param weakself    weakself
 */
+ (void)deallocModule:(BaseWebView*)weakwebView{
    
    id moduleObject = nil;
    for (int subIndex = 0; subIndex < weakwebView.subviews.count; subIndex ++) {
        UIView * subView = weakwebView.subviews[subIndex];
        if (subView && [subView isMemberOfClass:[BaseWebView class]] ) {
            //找到子的 Frame ：注意这里win的子视图还有可能是frameGroup的情况
            for (int moduleIndex = 0; moduleIndex < ((BaseWebView *)subView).moduleName_InWebView_Array.count; moduleIndex ++){
                moduleObject =  ((BaseWebView *)subView).moduleName_InWebView_Array[moduleIndex];
                //获取指定对象的属性列表
                NSMutableArray * moduleProperitsArr = [ToolsFunction getAllProperties: moduleObject];
                
                for (int properitsIndex = 0; properitsIndex < moduleProperitsArr.count; properitsIndex ++){
                    
                    const char * filePathChar = [moduleProperitsArr[properitsIndex] UTF8String];
                    Ivar ivar = class_getInstanceVariable([moduleObject class], filePathChar);
                    // 将属性逐个赋空 释放
                    object_setIvar(moduleObject, ivar, nil);
                }
            }
        }
    }
}

/**
 获取当前视图控制器
 
 @return
 */
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    } else
    {
        result = window.rootViewController;
        // 是否为模态是视图
        if (result.presentedViewController) {
            result = result.presentedViewController;
        }
    }
    
    return result;
}

/**
 将字符串转为md5值
 */
+ (NSString*)getmd5WithString:(NSString *)string
{
    const char* original_str=[string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5 (original_str, (CC_LONG)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x", digist[i]];// 小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    return [outPutStr lowercaseString];
}


/**
 将文件后缀修改为常用后缀
 
 @return NSDictionary
 */
+ (NSDictionary *)fileSuffixReName{

    NSDictionary *fileNameDic = @{@".3gp":@"video/3gpp",
                                  @".apk": @"application/vnd.android.package-archive",
                                  @".asf": @"video/x-ms-asf",
                                  @".avi": @"video/x-msvideo",
                                  @".bin": @"application/octet-stream",
                                  @".bmp": @"image/bmp",
                                  @".c": @"text/plain",
                                  @".class": @"application/octet-stream",
                                  @".conf": @"text/plain",
                                  @".cpp": @"text/plain",
                                  @".doc": @"application/msword",
                                  @".exe": @"application/octet-stream",
                                  @".gif": @"image/gif",
                                  @".gtar": @"application/x-gtar",
                                  @".gz": @"application/x-gzip",
                                  @".h": @"text/plain",
                                  @".htm": @"text/html",
                                  @".html": @"text/html",
                                  @".jar": @"application/java-archive",
                                  @".java": @"text/plain",
                                  @".jpeg": @"image/jpeg",
                                  @".jpg": @"image/jpeg",
                                  @".js": @"application/x-javascript",
                                  @".log": @"text/plain",
                                  @".m3u": @"audio/x-mpegurl",
                                  @".m4a": @"audio/mp4a-latm",
                                  @".m4b": @"audio/mp4a-latm",
                                  @".m4p": @"audio/mp4a-latm",
                                  @".m4u": @"video/vnd.mpegurl",
                                  @".m4v": @"video/x-m4v",
                                  @".mov": @"video/quicktime",
                                  @".mp2": @"audio/x-mpeg",
                                  @".mp3": @"audio/x-mpeg",
                                  @".mp4": @"video/mp4",
                                  @".mpc": @"application/vnd.mpohun.certificate",
                                  @".mpe": @"video/mpeg",
                                  @".mpeg": @"video/mpeg",
                                  @".mpg": @"video/mpeg",
                                  @".mpg4": @"video/mp4",
                                  @".mpga": @"audio/mpeg",
                                  @".msg": @"application/vnd.ms-outlook",
                                  @".ogg": @"audio/ogg",
                                  @".pdf": @"application/pdf",
                                  @".png": @"image/png",
                                  @".pps": @"application/vnd.ms-powerpoint",
                                  @".ppt": @"application/vnd.ms-powerpoint",
                                  @".prop": @"text/plain",
                                  @".rar": @"application/x-rar-compressed",
                                  @".rc": @"text/plain",
                                  @".rmvb": @"audio/x-pn-realaudio",
                                  @".rtf": @"application/rtf",
                                  @".sh": @"text/plain",
                                  @".tar": @"application/x-tar",
                                  @".tgz": @"application/x-compressed",
                                  @".txt": @"text/plain",
                                  @".wav": @"audio/x-wav",
                                  @".wma": @"audio/x-ms-wma",
                                  @".wmv": @"audio/x-ms-wmv",
                                  @".wps": @"application/vnd.ms-works",
                                  @".xml": @"text/plain",
                                  @".z": @"application/x-compress",
                                  @".zip": @"application/zip",
                                  @".tmp": @"*/*"
                                  };
    
    
    return fileNameDic;

}


/**
 json字符串的过滤
 
 @param jsonString
 @return
 */
+ (NSString *)transformStringToJSJsonWithJsonString:(NSString *)jsonString{


    
    NSString * callBackFinalData =  [jsonString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\\\n"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\\r" withString:@"\\\r"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    return callBackFinalData;
}


@end
