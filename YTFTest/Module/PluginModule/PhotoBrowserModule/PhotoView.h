//
//  PhotoView.m
//  PhotoBrower
//
//  Created by apple on 16/7/22.
//  Copyright © 2016年 yuantuan. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol PhotoViewDelegate <NSObject>

/**
 *  点击图片时，隐藏图片浏览器
 */
-(void)tapHiddenPhotoView;


/**
 长按图片
 */
- (void)longPressPhotoView:(UIImage *)saveImage;

@end

@interface PhotoView : UIView

/** 父视图 */
@property(nonatomic,strong)  UIScrollView *scrollView;

/** 图片视图 */
@property(nonatomic, strong) UIImageView *imageView;

/** 代理 */
@property(nonatomic, assign) id<PhotoViewDelegate> delegate;

/**
 *  传图片Url
 */
-(id)initWithFrame:(CGRect)frame withPhotoUrl:(NSString *)photoUrl;

/**
 *  传具体图片
 */
-(id)initWithFrame:(CGRect)frame withPhotoImage:(UIImage *)image;

@end
