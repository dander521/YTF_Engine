/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Media manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TZImagePickerController.h"
#import "BaseWebView.h"
@interface MediaManager : NSObject<TZImagePickerControllerDelegate>
/**
 *  block 回传 多选的图片路径数组和URL数组
 */
@property(nonatomic,copy) void (^ MultipleChoiceImageHandle)(NSMutableArray * imagePathArray,
NSMutableArray *imageUrlArray);

@property(nonatomic,weak)   NSMutableArray *muiltImagePathArray;//多选图片返回的图片路径数组
@property(nonatomic,strong) NSMutableArray *cropImagePathArray;// 裁剪的单张图片也要放在数组里 JS才能接收到并使用路径访问图片

/**
 *  单例
 *
 *  @return 初始化本类
 */
+ (instancetype)shareManager;
/**
 *  获取相册图片或视频
 *
 *  @param excuteWebView 当前执行环境
 */-(void)mediaGetPicture:(BaseWebView *)excuteWebView;


@end
