//
//  YTFPhotoBrowserModule.m
//  PhotoBrower
//
//  Created by apple on 2016/11/30.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "YTFPhotoBrowserModule.h"
#import "AppDelegate.h"
#import "NetworkManager.h"
#import "ToolsFunction.h"
#import "Definition.h"
#import "ImageBrowserViewController.h"

@interface YTFPhotoBrowserModule ()

@property (nonatomic, strong) NSMutableArray *imageArray;

@end

@implementation YTFPhotoBrowserModule

/**
 显示图片浏览器
 
 @param paramDictionary JS回调参数
 */
- (void)imageBrowser:(NSDictionary *)paramDictionary
{
    /*
     args : {
        images:[];
        isLoop:false
        index :0
        needBottomBrowser:0
        initNum:0
        count:5
        savePath : fs://ytffs/picture
     }
     cbId: 
     target:
     */
    
    NSArray *imagePathsArray = paramDictionary[@"args"][@"images"];
    
    if (imagePathsArray == nil || imagePathsArray.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"图片路径不能为空"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    NSUInteger index = paramDictionary[@"args"][@"index"] == nil ? 0 : [paramDictionary[@"args"][@"index"] integerValue];
    
    BOOL isLoop = paramDictionary[@"args"][@"isLoop"] == nil ? false : [paramDictionary[@"args"][@"isLoop"] boolValue];
    
    BOOL isBottom = paramDictionary[@"args"][@"needBottomBrowser"] == nil ? true : [paramDictionary[@"args"][@"needBottomBrowser"] boolValue];
    
    NSUInteger count = paramDictionary[@"args"][@"count"] == nil ? 5 : [paramDictionary[@"args"][@"count"] integerValue];
    
    NSUInteger intNum = paramDictionary[@"args"][@"initNum"] == nil ? 0 : [paramDictionary[@"args"][@"initNum"] integerValue];
    
    if (isBottom)
    {
        if (index > imagePathsArray.count)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"索引值大于图片总数"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
        
        if (intNum > imagePathsArray.count)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"底部快速浏览器初始显示位置值大于图片总数"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
    }

    NSString *savePath = nil;
    if (paramDictionary[@"args"][@"savePath"] != nil)
    {
        if ([paramDictionary[@"args"][@"savePath"] hasPrefix:@"fs:"])
        {
            // fs://
            savePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramDictionary[@"args"][@"savePath"]];
        } else {
            // 全路径
            savePath = paramDictionary[@"args"][@"savePath"];
        }
    }
    
    webView = paramDictionary[@"target"];
    cbId = paramDictionary[@"cbId"];

    [ImageBrowserViewController show:(UIViewController *)[AppDelegate shareAppDelegate].baseViewController
                                type:PhotoBroswerVCTypeModal
                               index:index
                              isLoop:isLoop
                            isBottom:isBottom
                               count:count
                              intNum:intNum
                            savePath:savePath
                         imagesBlock:^NSArray *
     {
         return imagePathsArray;
     } browserBlock:^(BOOL isSave, NSString *path)
     {
         NSString *jsonString = nil;
         if (isSave == true)
         {
             // 成功
             jsonString = [ToolsFunction dicToJavaScriptString:@{@"path" : path}];
         } else {
             // 失败
             jsonString = [ToolsFunction dicToJavaScriptString:@{@"msg" : @"保存失败"}];
         }
         [self performSelectorOnMainThread:@selector(mainThreadMethod:) withObject:jsonString waitUntilDone:NO];
     }];
}

- (void)mainThreadMethod:(NSString *)jsonString
{
    [webView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", cbId, jsonString,jsonString]];
}

@end
