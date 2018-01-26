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

#import "TaskManager.h"

@implementation TaskManager

/**
 *  初始化单例对象
 *
 *  @return 类的实例对象
 */
+(instancetype)shareManager
{
    
    static TaskManager * manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[TaskManager alloc]init];
        
        
    });
    
    return manager;
}
/**
 *  传递参数给Task单例
 *
 *  @param taskDic 参数
 */
-(void)setTaskDicMethod:(NSDictionary *)taskDic{
    
    [self.taskArray addObject: taskDic];
    
}
/**
 *  传递参数给AJaxDownLoad单例
 *
 *  @param taskDic 参数
 */
- (void)setdownLoadTaskDicMethod:(NSDictionary *)downLoadTaskDic
{
    self.downLoadTaskDic = downLoadTaskDic;
}

/**
 *  用于多个下载任务通过CBID 做区分
 *
 *  @param taskDic 参数
 */
- (void)setdownLoadCbIdTask:(NSDictionary *)downLoadCbIdTaskDic{

    self.downLoadCbIdTask = downLoadCbIdTaskDic;

}

/**
 *  传递 Header参数给Task单例
 *
 *  @param headerDic 参数
 */
- (void)setHeader:(NSDictionary *)headerDic{

    self.headerDictionary = headerDic;
}



@end
