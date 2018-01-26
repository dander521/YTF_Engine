//
//  ImageBrowserViewController.m
//  PhotoBrower
//
//  Created by apple on 16/7/22.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  存储成功路径
 *
 *  @param
 */
typedef void (^YTFPhotoBrowser)(BOOL isSave, NSString *path);

/**
 * 跳转方式
 */
typedef NS_ENUM(NSUInteger,PhotoBroswerVCType) {
    
    //modal
    PhotoBroswerVCTypePush=0,
    
    //push
    PhotoBroswerVCTypeModal,
    
    //zoom
    PhotoBroswerVCTypeZoom,
};

@interface ImageBrowserViewController : UIViewController
/**
 *  显示图片
 */
+ (void)show:(UIViewController *)handleVC
        type:(PhotoBroswerVCType)type
       index:(NSUInteger)index
      isLoop:(BOOL)isLoop
    isBottom:(BOOL)isBottom
       count:(NSUInteger)count
      intNum:(NSUInteger)intNum
    savePath:(NSString *)savePath
 imagesBlock:(NSArray *(^)())imagesBlock
browserBlock:(YTFPhotoBrowser)photoBrowser;
@end
