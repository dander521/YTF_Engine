//
//  YTFQRCodeModule.m
//  YTFQRCodeModule
//
//  Created by apple on 2016/10/19.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "YTFQRCodeModule.h"
#import "YTFScanToolController.h"
#import "AppDelegate.h"
#import "ToolsFunction.h"

@implementation YTFQRCodeModule

/**
 *  打开QRCode页面
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)openScanQRCodeView:(NSDictionary *)paramsDictionary
{
    /*
     cbId
     target
     */
    
    qrWebView = paramsDictionary[@"target"];
    qrCbId = paramsDictionary[@"cbId"];
    
    YTFScanToolController *vwcScan = [[YTFScanToolController alloc] init];
    
    if (vwcScan.isCameraValid && vwcScan.isCameraAllowed)
    {
        [self.viewController presentViewController:vwcScan animated:YES completion:nil];
        
        __weak typeof(vwcScan) weakVwc = vwcScan;
        vwcScan.cameraCodeString = ^(NSString *codeString)
        {
            [weakVwc dismissViewControllerAnimated:true completion:^{

                [self performSelectorOnMainThread:@selector(mainThreadOperationWithParamDictionary:) withObject:@{@"status" : [NSNumber numberWithInt:1], @"codeString" : codeString} waitUntilDone:false];
            }];
            
            
        };
        
        vwcScan.albumCodeString = ^(NSString *codeString)
        {
            [weakVwc dismissViewControllerAnimated:true completion:^{
                
                [self performSelectorOnMainThread:@selector(mainThreadOperationWithParamDictionary:) withObject:@{@"status" : [NSNumber numberWithInt:1], @"codeString" : codeString} waitUntilDone:false];
                
            }];
        };
    } else
    {
        if (!vwcScan.isCameraAllowed)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的设置-隐私-相机中允许访问相机。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alertView show];
        }
        else if (!vwcScan.isCameraValid)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查你的摄像头。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

/**
 *  读取二维码图片
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)decodeQRCodeImage:(NSDictionary *)paramsDictionary
{
    /*
     cbId
     target
     imagePath
     */
    qrWebView = paramsDictionary[@"target"];
    qrCbId = paramsDictionary[@"cbId"];
    
    NSDictionary *dicResult = nil;
    
    if (paramsDictionary[@"args"][@"imagePath"] == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInt:0],
                      @"msg" : @"二维码路径不能为空"};
        
        [paramsDictionary[@"target"] stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", paramsDictionary[@"cbId"], [ToolsFunction dicToJavaScriptString:dicResult],[ToolsFunction dicToJavaScriptString:dicResult]]];
        return;
    }
    
    NSString *imagePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imagePath"]];
    
    UIImage *srcImage = [UIImage imageWithContentsOfFile:imagePath];
    
    if (srcImage == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInt:0],
                      @"msg" : @"二维码图片路径错误"};
        
        [paramsDictionary[@"target"] stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", paramsDictionary[@"cbId"], [ToolsFunction dicToJavaScriptString:dicResult],[ToolsFunction dicToJavaScriptString:dicResult]]];
        return;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    
    NSString *result = feature.messageString;
    
    if (result == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInt:0],
                      @"msg" : @"二维码图片错误"};
        
        [paramsDictionary[@"target"] stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", paramsDictionary[@"cbId"], [ToolsFunction dicToJavaScriptString:dicResult],[ToolsFunction dicToJavaScriptString:dicResult]]];
        return;
    }

    dicResult = @{@"status" : [NSNumber numberWithInt:1],
                  @"codeString" : result};
    
    [paramsDictionary[@"target"] stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", paramsDictionary[@"cbId"], [ToolsFunction dicToJavaScriptString:dicResult],[ToolsFunction dicToJavaScriptString:dicResult]]];
}

/**
 *  生成二维码图片
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)encodeQRCodeImage:(NSDictionary *)paramsDictionary
{
    /*
     cbId
     target
     codeString
     imagePath
     */
    
    qrWebView = paramsDictionary[@"target"];
    qrCbId = paramsDictionary[@"cbId"];
    
    NSDictionary *dicResult = nil;
    
    NSString *codeString = paramsDictionary[@"args"][@"codeString"];
    NSString *imagePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:paramsDictionary[@"args"][@"imagePath"]];
    
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (codeString == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInt:0],
                      @"msg" : @"二维码字符串不能为空"};
        
        [paramsDictionary[@"target"] stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", paramsDictionary[@"cbId"], [ToolsFunction dicToJavaScriptString:dicResult],[ToolsFunction dicToJavaScriptString:dicResult]]];
        return;
    }
    
    NSData *stringData = [codeString dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    UIColor *onColor = [UIColor whiteColor];
    UIColor *offColor = [UIColor blackColor];
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGSize size = CGSizeMake(300, 300);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // 绘制的图片
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    NSData *imageData = UIImageJPEGRepresentation(codeImage, 1);
    
    // 保存图片
    if (imagePath)
    {
        NSString *imageResult = [NSString stringWithFormat:@"%@/%@.png", imagePath, [ToolsFunction getCurrentTimeIntervalString]];
        BOOL isSuccess = [imageData writeToFile:imageResult atomically:false];
        
        if (isSuccess)
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:1],
                          @"imagePath" : imageResult};
        } else {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"code" : [NSNumber numberWithInt:0],
                          @"msg" : @"生成二维码图片保存失败"};
        }
        
    } else {
        // 默认存储二维码图片路径
        NSString *imagePath =  [NSString stringWithFormat:@"%@/ytffs/%@.png", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject, [ToolsFunction getCurrentTimeIntervalString]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        {
            // 创建文件路径
            NSString *directoryPath = [NSString stringWithFormat:@"%@/ytffs", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject];
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
            // 创建文件
            [[NSFileManager defaultManager] createFileAtPath:imagePath contents:nil attributes:nil];
            BOOL isSuccess = [imageData writeToFile:imagePath atomically:false];
            if (isSuccess)
            {
                dicResult = @{@"status" : [NSNumber numberWithInt:1],
                              @"imagePath" : imagePath};
            } else {
                dicResult = @{@"status" : [NSNumber numberWithInt:0],
                              @"code" : [NSNumber numberWithInt:0],
                              @"msg" : @"生成二维码图片保存失败"};
            }
        } else {
            BOOL isSuccess = [imageData writeToFile:imagePath atomically:false];
            if (isSuccess)
            {
                dicResult = @{@"status" : [NSNumber numberWithInt:1],
                              @"imagePath" : imagePath};
            } else {
                dicResult = @{@"status" : [NSNumber numberWithInt:0],
                              @"code" : [NSNumber numberWithInt:0],
                              @"msg" : @"生成二维码图片保存失败"};
            }
        }
    }
    
    [paramsDictionary[@"target"] stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", paramsDictionary[@"cbId"], [ToolsFunction dicToJavaScriptString:dicResult],[ToolsFunction dicToJavaScriptString:dicResult]]];
}

- (void)mainThreadOperationWithParamDictionary:(NSDictionary *)paramDictionary
{
    NSString *stringJson = [ToolsFunction dicToJavaScriptString:paramDictionary];
    [qrWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", qrCbId, stringJson,stringJson]];
}

@end
