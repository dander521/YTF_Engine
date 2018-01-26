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

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>


@class BaseWebView;
@class MaskingView;

@interface ToolsFunction : NSObject

@property (nonatomic, strong) MaskingView *maskingView;//蒙板view

#pragma mark - Json To Dictionary

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
                  errorStr:(NSDictionary *)errorDic;

/**
 Json文件通过相对路径转换为字典

 @param fileRelativePath fileRelativePath 文件相对路径

 @return 字典对象
 */
+ (NSDictionary *)JsonFileToDictionaryWithFileRelativePath:(NSString *)fileRelativePath;

/**
 Json文件通过绝对路径转换为字典

 @param fileAbsolutePath 文件绝对路径

 @return 字典对象
 */
+ (NSDictionary *)JsonFileToDictionaryWithFileAbsolutrPath:(NSString *)fileAbsolutePath;

/**
 字符串转颜色

 @param stringToConvert color string

 @return UIColor
 */
+ (UIColor *)hexStringToColor:(NSString *)stringToConvert;


#pragma mark - Dictionary To Json

/**
 字典转Json字符串

 @param dictionary 转换字典

 @return Json字符串
 */
+ (NSString *)dictionaryToJsonString:(NSDictionary *)dictionary;




/**
 *  Json转字典
 *
 *  @param responseObject 请求返回Json数据
 *
 *  @return 字典
 */
+ (NSDictionary *)responseConvertToDictionary:(id)responseObject;


/**
 将字典直接转化为能回调JS的字符串
 
 @param dictionary 转换字典
 
 @return Json字符串
 */
+ (NSString *)dicToJavaScriptString:(NSDictionary *)dictionary;

#pragma mark - Files Operation

/**
 拷贝文件/文件夹到目标路径

 @param resourcePath    源路径
 @param destinationPath 目标路径
 */
+ (void)copyFilesWithResourcePath:(NSString *)resourcePath
                  destinationPath:(NSString *)destinationPath;

/**
 判断是非为文件夹

 @param path 文件路径

 @return bool
 */
+ (BOOL)judgeFileOrFileDirectoryWithPath:(NSString *)path;

/**
 创建文件夹

 @param path 文件路径

 @return bool
 */
+ (BOOL)createDirectoryWithPath:(NSString *)path;

/**
 判断文件是否存在

 @param filePath 文件路径

 @return bool
 */
+ (BOOL)isFileExistAtPath:(NSString *)filePath;

#pragma mark - JSContext Param

/**
 获取CBID

 @return CBID
 */
+ (NSString *)JSContextCBID;

/**
 获取args参数字典

 @return 参数字典
 */
+ (NSDictionary *)JSContextArgsDictionary;

#pragma mark - NSDate <-> NSString

/**
 NSDate转NSString

 @param date 日期

 @return String
 */
+ (NSString *)stringFromDate:(NSDate *)date;

/**
 NSString转NSDate

 @param string String

 @return 日期
 */
+ (NSDate *)dateFromString:(NSString *)string;

/**
 获取当前时间戳字符串

 @return 当前时间戳字符串
 */
+ (NSString *)getCurrentTimeIntervalString;


#pragma mark - Progress

/**
 显示进度提示框
 */
+ (void)showCustomProgress;

/**
 隐藏进度提示框
 */
+ (void)hideCustomProgress;

/**
 获取文件mimeType
 
 @param string 文件路径
 
 @return 文件mime类型
 */
+ (NSString *)mimeWithString:(NSString *)string;

/**
 获取当前win的上一层win，上一层win也需要跟着做动画

 @param currentBaseWebView 当前webView

 @return win
 */
+ (BaseWebView *)getSubBaseWebView:(BaseWebView *)currentBaseWebView;

/**
 获取指定对象的属性列表
 
 @param obj 自定义的对象
 
 @return 属性名字_字符串_的数组
 */
+ (NSMutableArray *)getAllProperties:(id)obj;


/**
 移除webView上所有的模块对象
 
 @param weakwebView 要关闭的win
 */
+ (void)deallocModule:(BaseWebView*)weakwebView;



/**
 获取当前视图控制器
 
 @return 顶部ViewController
 */
+ (UIViewController *)getCurrentVC;


/**
 将字符串转为md5值
 */
+ (NSString*)getmd5WithString:(NSString *)string;


/**
 将文件后缀修改为常用后缀

 @return NSDictionary
 */
+ (NSDictionary *)fileSuffixReName;


/**
 json字符串的过滤

 @param jsonString
 @return
 */
+ (NSString *)transformStringToJSJsonWithJsonString:(NSString *)jsonString;

@end
