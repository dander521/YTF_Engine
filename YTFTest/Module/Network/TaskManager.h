/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Network task manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>

@interface TaskManager : NSObject

/**
 *  单例存储AJax方法的参数
 */
@property(nonatomic,copy)NSMutableArray * taskArray;

/**
 *  单例存储AJaxDownLoad方法的参数  用于取消下载做标识
 */
@property(nonatomic,copy)NSDictionary * downLoadTaskDic;

/**
 *  单例存储AJax方法的Header参数
 */
@property(nonatomic,copy)NSDictionary * headerDictionary;


/**
 *  单例存储AJaxDownLoad方法的参数  用于多个下载任务通过CBID 做区分
 */
@property(nonatomic,copy)NSDictionary * downLoadCbIdTask;

/**
 *  初始化单例对象
 *
 *  @return 类的实例对象
 */
+ (instancetype)shareManager;//单例

/**
 *  传递参数给Task单例
 *
 *  @param taskDic 参数
 */
- (void)setTaskDicMethod:(NSDictionary *)taskDic;

/**
 *  传递参数给AJaxDownLoad单例
 *
 *  @param taskDic 参数
 */
- (void)setdownLoadTaskDicMethod:(NSDictionary *)downLoadTaskDic;

/**
 *  用于多个下载任务通过CBID 做区分
 *
 *  @param taskDic 参数
 */
- (void)setdownLoadCbIdTask:(NSDictionary *)downLoadCbIdTaskDic;


/**
 *  传递 Header参数给Task单例
 *
 *  @param headerDic 参数
 */
- (void)setHeader:(NSDictionary *)headerDic;




@end
