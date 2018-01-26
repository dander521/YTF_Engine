//
//  XHScanToolController.m
//  XHScanTool
//
//  Created by TianGeng on 16/6/27.
//  Copyright © 2016年 bykernel. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "YTFScanToolController.h"
#import "YTFScanView.h"
#import <AVFoundation/AVFoundation.h>

@interface YTFScanToolController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) YTFScanView *scanView;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (strong, nonatomic) AVCaptureDevice *defaultDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *activeVideoInput;

@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutPut;
@property (nonatomic, strong) AVCaptureSession *captureSeesion;

@property (nonatomic, assign) BOOL isTorch;
@property (nonatomic, strong) UIButton *torchButton;

@end

@implementation YTFScanToolController


- (NSString *)seesionPreset{
    return AVCaptureSessionPreset640x480;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTorch = false;
    NSError *error;
    self.view.backgroundColor = [UIColor whiteColor];
    BOOL isSuccess= [self setUpSession:error];
    if (isSuccess) {
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSeesion];
        
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        //设置layer的frame为大视图的frame
        
        //把拍摄的layer添加到主视图的layer中
        [self.view.layer insertSublayer:self.preview atIndex:0];
        self.preview.frame = self.view.bounds;

        [self.captureSeesion startRunning];
        
        [self.view addSubview:self.scanView];

        [self setUpOtherView];
        
    }else{
   
    }
}
- (void)setUpOtherView
{
    UIButton *closeButton = [[UIButton alloc] init];
    [self.view addSubview:closeButton];
//    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(15, 28, 40, 40);
//    [closeButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//    closeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [closeButton setImage:[UIImage imageNamed:@"qr_back"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonClck) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *labelDes = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds) - 50.0, 34, 100.0, 25.0)];
    labelDes.textColor = [UIColor whiteColor];
    labelDes.text = @"扫一扫";
    labelDes.textAlignment = NSTextAlignmentCenter;
    labelDes.font = [UIFont systemFontOfSize:26];
    [self.view addSubview:labelDes];
    
    //
    UILabel *labelScan = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/2 + 100, [UIScreen mainScreen].bounds.size.width, 25.0)];
    labelScan.textColor = [UIColor yellowColor];
    labelScan.text = @"二维码／条形码扫描";
    labelScan.textAlignment = NSTextAlignmentCenter;
    labelScan.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:labelScan];
    
    UILabel *labelIntro = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/2 + 135.0, [UIScreen mainScreen].bounds.size.width, 20.0)];
    labelIntro.textAlignment = NSTextAlignmentCenter;
    labelIntro.textColor = [UIColor whiteColor];
    labelIntro.text = @"对准取景框，自动扫描";
    labelIntro.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:labelIntro];
    
    self.torchButton = [[UIButton alloc] init];
    [self.view addSubview:self.torchButton];
    //    [torchButton setTitle:@"闪光灯" forState:UIControlStateNormal];
    self.torchButton.frame = CGRectMake(CGRectGetMidX(labelIntro.frame) + 26.0, CGRectGetMaxY(labelIntro.frame) + 30.0, 44, 44);
    //    [torchButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    //    torchButton.titleLabel.font = [UIFont systemFontOfSize:15];
    if (self.isTorch)
    {
        [self.torchButton setBackgroundImage:[UIImage imageNamed:@"qr_light_on"] forState:UIControlStateNormal];
    } else {
        [self.torchButton setBackgroundImage:[UIImage imageNamed:@"qr_light_off"] forState:UIControlStateNormal];
    }
    
    [self.torchButton addTarget:self action:@selector(toggleTorch) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *albumButton = [[UIButton alloc] init];
    [self.view addSubview:albumButton];
    //    [albumButton setTitle:@"相册" forState:UIControlStateNormal];
    albumButton.frame = CGRectMake(CGRectGetMidX(labelIntro.frame) - 70.0, CGRectGetMaxY(labelIntro.frame) + 30.0, 44, 44);;
    //    [albumButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    //    albumButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [albumButton setBackgroundImage:[UIImage imageNamed:@"qr_album"] forState:UIControlStateNormal];
    [albumButton addTarget:self action:@selector(actionRead) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)closeButtonClck{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleTorch
{
    self.isTorch = !self.isTorch;
    
    if (self.isTorch)
    {
        [self.torchButton setBackgroundImage:[UIImage imageNamed:@"qr_light_on"] forState:UIControlStateNormal];
    } else {
        [self.torchButton setBackgroundImage:[UIImage imageNamed:@"qr_light_off"] forState:UIControlStateNormal];
    }
    
    NSError *error = nil;
    
    [self.defaultDevice lockForConfiguration:&error];
    
    if (error == nil) {
        AVCaptureTorchMode mode = self.defaultDevice.torchMode;
        
        self.defaultDevice.torchMode = mode == AVCaptureTorchModeOn ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    }
    
    [self.defaultDevice unlockForConfiguration];
}

- (void)actionRead
{
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoPicker.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage * srcImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    
    NSString *result = feature.messageString;

    if (result)
    {
        self.albumCodeString(result);
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGRect cropRect = CGRectMake((self.scanView.frame.size.width - self.scanView.showSize.width) / 2,
                                 (self.scanView.frame.size.height - self.scanView.showSize.height) / 2,
                                 self.scanView.showSize.width,
                                 self.scanView.showSize.height);
    CGSize size = self.scanView.bounds.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = self.scanView.frame.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        self.metadataOutPut.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                  cropRect.origin.x/size.width,
                                                  cropRect.size.height/fixHeight,
                                                  cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = self.scanView.frame.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        self.metadataOutPut.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                  (cropRect.origin.x + fixPadding)/fixWidth,
                                                  cropRect.size.height/size.height,
                                                  cropRect.size.width/fixWidth);
    }
   
}
- (YTFScanView *)scanView{
    if (!_scanView) {
        _scanView = [[YTFScanView alloc] init];
        _scanView.frame = self.view.bounds;
        _scanView.showSize = CGSizeMake( 220, 220);
    }
    return _scanView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 初始化

- (BOOL)setUpSession:(NSError *)error{
    
    // 初始化会话
    self.captureSeesion = [[AVCaptureSession alloc] init];
    self.captureSeesion.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 初始化默认输入设备
    self.defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 默认的视频捕捉设备
    self.activeVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.defaultDevice error:&error];
    
    if (error) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to init activeVideoInput"};
        error = [NSError errorWithDomain:@"error" code:0 userInfo:userInfo];
      
        return NO;
    }
    // 初始化输出设备
    if (self.activeVideoInput) {
        if ([self.captureSeesion canAddInput: self.activeVideoInput]) {
            [self.captureSeesion addInput: self.activeVideoInput];
            self.activeVideoInput =  self.activeVideoInput;
        }
    }else{
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to add activeVideoInput"};
        error = [NSError errorWithDomain:@"error" code:0 userInfo:userInfo];
        
        return NO;
    }
    // 初始化输出设备
    self.metadataOutPut = [[AVCaptureMetadataOutput alloc] init];
    if ([self.captureSeesion canAddOutput:self.metadataOutPut]) {
        [self.captureSeesion addOutput:self.metadataOutPut];
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        
        [self.metadataOutPut setMetadataObjectsDelegate:self queue:mainQueue];
        
        NSArray *types = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        self.metadataOutPut.metadataObjectTypes = types;
        
    }else{
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to add metadaa output"};
        error = [NSError errorWithDomain:@"error" code:0 userInfo:userInfo];
        return NO;
        
    }
    return YES;
}

//扫描完成的时候就会调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //终止会话
    [self.captureSeesion stopRunning];
    self.captureSeesion = nil;
    //把扫描的layer从主视图的layer中移除
    [self.preview removeFromSuperlayer];
    
    NSString *val = nil;
    if (metadataObjects.count > 0)
    {
        //取出最后扫描到的对象
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        //获得扫描的结果
        val = obj.stringValue;
        self.cameraCodeString(val);
    }
}

-(BOOL)isCameraAllowed {
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return NO;
    }
    
    return YES;
}

-(BOOL)isCameraValid {
    
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}
@end
