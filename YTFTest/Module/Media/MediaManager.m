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

#import "MediaManager.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "TZImagePickerController.h"
#import "BaseWebView.h"
#import "YTFConfigManager.h"
#import "ToolsFunction.h"
#import "Definition.h"

@interface MediaManager ()
{
    NSString  *cbID;//mediaGetPicture 方法的回调函数ID
     NSString * compStrPath;
}
@property (nonatomic , weak) BaseWebView *mediaGetPictureWebView;//mediaGetPicture 方法接收的执行环境WebView

@end

@implementation MediaManager
// 单例
+ (instancetype)shareManager
{
    static MediaManager *mediaManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaManager = [[self alloc] init];
    });
    
    return mediaManager;
}
/**
 *  获取相册图片或视频
 *
 *  @param excuteWebView 当前执行环境
 */
- (void)mediaGetPicture:(BaseWebView *)excuteWebView{
 
    RCWeakSelf(self);
    RCWeakSelf(excuteWebView);
     [excuteWebView  valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"][@"ytfMediaGetPicture"] = ^() {
         // JS对象转化成OC字典
         cbID  = [[JSContext currentArguments][0] toDictionary][@"cbId"];
         NSDictionary *dicArgs = [[JSContext currentArguments][0] toDictionary][@"args"];
         _mediaGetPictureWebView = weakexcuteWebView;
         BOOL isEdite;
         if (dicArgs[@"isEdit"]==[NSNumber numberWithBool:0]) {
             isEdite = NO;
         }else {
             isEdite = YES;
         }
         
         TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:(NSInteger)[[YTFConfigManager shareConfigManager] configisCheckboxWithJSParam:dicArgs[@"isCheckbox"]]
                                                                                                 delegate:weakself
                                                                                                   isCrop:(NSInteger)[[YTFConfigManager shareConfigManager]                                                                                                                            configPictureIsEdit:isEdite]];
         UIViewController * currentVc = [ToolsFunction getCurrentVC];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [currentVc presentViewController:imagePickerVc animated:YES completion: nil];
         });
         
         //多选图片信息回调
         [[NSNotificationCenter defaultCenter]addObserver:weakself selector:@selector(multipleImageChoice:) name:@"namemultipleImageChoice" object:nil];
         
         //单张裁剪图片信息回调
         [[NSNotificationCenter defaultCenter]addObserver:weakself
                                                 selector:@selector(photoCropNotific:)
                                                     name:@"namephotoCropNotific"
                                                   object:nil];
     };
 }

/**
 *  多选图片信息回调
 *
 *  @param notif NSNotification
 */
- (void)multipleImageChoice:(NSNotification *)notif{
    
    [self.muiltImagePathArray removeAllObjects];
    self.muiltImagePathArray = notif.userInfo[@"imagePath"];
    
    [ToolsFunction callBackExcWebView:_mediaGetPictureWebView
                                 cbID:cbID
                        successParams:@{@"imagePath":self.muiltImagePathArray}
                             errorStr:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"namemultipleImageChoice" object:nil];
    
}
/**
 *  单张裁剪图片信息回调
 *
 *  @param notific NSNotification
 */
- (void)photoCropNotific:(NSNotification *)notific{
    
    [self.cropImagePathArray removeAllObjects];
    NSString * cropImagePath = notific.userInfo[@"imagePath"];
    [self.cropImagePathArray addObject:cropImagePath];
    
    //  回调CallBack
    [ToolsFunction callBackExcWebView:_mediaGetPictureWebView cbID:cbID successParams:@{@"imagePath":self.cropImagePathArray} errorStr:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"namephotoCropNotific" object:nil];
    
}
/**
 *  多选图片返回的图片路径数组懒加载  重写getter方法,内部不能再用self.muiltImagePathArray  因为这样是在getter里调用了set方法 是不允许的
 *
 *  @return 数组
 */
- (NSMutableArray *)muiltImagePathArray{
    
    if (!_muiltImagePathArray) {
        _muiltImagePathArray = [NSMutableArray array];
    }
    return _muiltImagePathArray;
}
- (NSMutableArray *)cropImagePathArray{
    if (!_cropImagePathArray) {
        _cropImagePathArray = [NSMutableArray array];
    }
    
    return _cropImagePathArray;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"namemultipleImageChoice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"namephotoCropNotific" object:nil];
}



@end
