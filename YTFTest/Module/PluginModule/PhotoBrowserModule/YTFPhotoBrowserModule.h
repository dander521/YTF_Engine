//
//  YTFPhotoBrowserModule.h
//  PhotoBrower
//
//  Created by apple on 2016/11/30.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTFPhotoBrowserModule : NSObject
{
    id webView;
    NSString *cbId;
}


/**
 显示图片浏览器

 @param paramDictionary JS回调参数
 */
- (void)imageBrowser:(NSDictionary *)paramDictionary;

@end
