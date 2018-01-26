/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Plugin center.
 * =============================================================================
 */

#import "BridgeCenter.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "ToolsFunction.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Definition.h"

@interface BridgeCenter ()
{

    id retObject; // 同步方法返回的数据
    NSDictionary * paramsDic;//JS 传入的参数  包含  args  及 cbid
}
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, assign)BOOL isSyncMethod; // 是否为同步方法
@property (nonatomic,weak)id classObject;


@end

@implementation BridgeCenter


+ (instancetype)shareManager
{
    static BridgeCenter *bridgeModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bridgeModel = [[self alloc] init];
        bridgeModel.appDelegate = [AppDelegate shareAppDelegate];
    });
    
    return bridgeModel;
}


/**
 *  插件的调度中心  js 统一来调用这个方法 由此方法接收的参数来 进行相应 原生方法的分发 主要通过传入对象
 *
 *  @param baseWebView 执行此方法的 webView
 */
- (void)ytfNativeBridget:(BaseWebView *)baseWebView{
    
    RCWeakSelf(self);
    RCWeakSelf(baseWebView);
    [baseWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfNativeBridget"] = ^() {
        
     
     NSString *methodName  = [[JSContext currentArguments][0] toDictionary][@"methodName"];
     weakself.classObject   = [[JSContext currentArguments][0] toDictionary][@"nativeObj"];
     
     if (!weakbaseWebView.moduleName_InWebView_Array) {
            weakbaseWebView.moduleName_InWebView_Array = [NSMutableArray array];
     }
        
    [weakbaseWebView.moduleName_InWebView_Array addObject:weakself.classObject];
        
    //类名转字符串
     NSString * className = NSStringFromClass([weakself.classObject class]);
     NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
     NSString *dicCbId = [[JSContext currentArguments][0] toDictionary][@"cbId"];
        
    
    if (dicArgs==nil) {
            dicArgs = @{@"":@""};
    }
      if (dicCbId) {
      
         paramsDic = @{@"args":dicArgs,@"cbId":dicCbId,@"target":weakbaseWebView};
     }else{
             paramsDic = dicArgs;

         }
        //格式化成json数据
       NSMutableArray * jsonArrayObject =  [NSJSONSerialization JSONObjectWithData:[[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"module"ofType:@"json"]] options:NSJSONReadingMutableLeaves error:nil];
        
       // 获取当前模块在model.json文件中的字典
        NSMutableDictionary * targetModuleDic;
        for (NSMutableDictionary * tempDic in jsonArrayObject) {
            if ([tempDic[@"class" ] isEqualToString:className]) {
                targetModuleDic = [NSMutableDictionary dictionary];
                targetModuleDic = tempDic;
            }
        }

        for (NSString * methodNameTemp in targetModuleDic[@"methods"]) {
            
            if ([methodNameTemp isEqualToString:methodName]) {
                
                weakself.isSyncMethod = NO;
                break;
            }
        }
        
        
        for (NSString * syncMethodsName in targetModuleDic[@"syncMethods"]) {
            
            if ([syncMethodsName isEqualToString:methodName]) {
                
                weakself.isSyncMethod = YES;
                break;
            }
        }

        //获取当前类的所有方法 因为调用原生需要传入值的方法时 需要有：冒号 而Js只传了方法名 没有冒号 无法调到方法 这里需要处理下
        NSMutableArray * methodNameArray   = [weakself getObjcAllMethods:weakself.classObject];
        methodName = [NSString stringWithFormat:@"%@:",methodName];
        for (NSString * nameString in methodNameArray) {
            if ([nameString isEqualToString:methodName]) {
                methodName = nameString;
            }
        }
        if (weakself.isSyncMethod)
        {
            // FIXME: 利用IMP和函数指针方法配合解决
            SuppressPerformSelectorLeakWarning(
               // 同步方法
               retObject =  [weakself.classObject performSelector:NSSelectorFromString(methodName) withObject:dicArgs];
                                               paramsDic = nil;
            );
        }else
        {
            // FIXME: 利用IMP和函数指针方法配合解决
            SuppressPerformSelectorLeakWarning(
                // 异步方法
                [weakself.classObject performSelector:NSSelectorFromString(methodName) withObject:paramsDic];
                                               paramsDic = nil;
                                               
            );
        }
        return retObject;
    };
}

/**
 *  最先响应插件的方法 require  用来只初始化一个对象
 *
 *  @param baseWebView 执行此方法的 webView
 */
- (void)ytfRequireNativeMethod:(BaseWebView *)baseWebView
{
    
    [baseWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfRequireNative"] = ^() {
        NSString *moduleNameStr   = [[JSContext currentArguments][0] toDictionary][@"moduleName"];
        // 测试读取 json文件
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"module"ofType:@"json"];
        //根据文件路径读取数据
        NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
        NSMutableArray * jsonArrayObjectRequire;
        if (jdata) {
            jsonArrayObjectRequire =  [NSJSONSerialization JSONObjectWithData:jdata options:NSJSONReadingMutableLeaves error:nil];
        }
        NSString * className;// 获取类名
        for (id jsonDictionaryRequire in jsonArrayObjectRequire){
            if ([jsonDictionaryRequire[@"moduleName"] isEqualToString:moduleNameStr]) {
                // 拿到该模块下的类名
                className = jsonDictionaryRequire[@"class"];
            }
        }
       id targetViewController;
        if (className.length == 0) {
        }else{
                // 控制器类对象 字符串转类！
            Class targetViewControllerClass = NSClassFromString(className);
                // 创建对象
            targetViewController  = [[targetViewControllerClass alloc] init];
         }
        
        
         return  targetViewController;
    };
}


/**
 *  获取当前类的所有方法
 *
 *  @param classObject 类的实例化对象
 *
 *  @return 方法的数组
 */
- (NSMutableArray *)getObjcAllMethods:(id )classObject{

    unsigned int count;
    Method *methods = class_copyMethodList([classObject class], &count);
    NSMutableArray * methodsArr;
    if (!methodsArr) {
        
        methodsArr = [NSMutableArray array];
    }
    for (int i = 0; i < count; i++)
    {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *methodName = NSStringFromSelector(selector);
        [methodsArr addObject:methodName];
    
    }
    return methodsArr;
}



@end
