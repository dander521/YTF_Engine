//
//  LocationSelectorManager.m
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import "LocationSelectorManager.h"
#import "LocationObject.h"
#import "CustomLocationPickerView.h"

#define Animation_Time    0.2

@interface LocationSelectorManager ()<CustomLocationPickerViewDelegate>

@property (nonatomic, strong) UIView *showView;
@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) LocationObject *locationObject;

@property (nonatomic, strong) NSDictionary *locationDictionary;
@property (nonatomic, strong) NSMutableDictionary *submitDictionary;

@property (nonatomic, strong) NSString *callbackString;


@property (nonatomic, assign) BOOL isCallBack;


@end

@implementation LocationSelectorManager

+ (LocationSelectorManager *)shareManagerDictionary:(NSDictionary *)dictionary
{
    static id sharedInstance = nil;
    
    sharedInstance = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds dictionary:dictionary];
    
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame dictionary:(NSDictionary *)dictionary
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupUIWithDictionary:dictionary];
    }
    
    return self;
}


- (void)show
{
    [self makeKeyWindow];
    
    [UIView animateWithDuration:Animation_Time delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.showView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished) {
        self.showView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.3];
    }];
    
    self.hidden = false;
}

- (void)hide
{
    self.showView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:Animation_Time delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.showView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished) {
        [self resignKeyWindow];
        
        self.hidden = true;
        
        [self performSelectorOnMainThread:@selector(mainThreadOperateWithParamsString:) withObject:_callbackString waitUntilDone:NO];
    }];
}

- (void)setupUIWithDictionary:(NSDictionary *)dictionary
{

    _isCallBack = false;

    _locationObject = [LocationObject configObjectWithDictionary:dictionary];
    _submitDictionary = [NSMutableDictionary new];
    
    if (!self.showView)
    {
        self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        self.showView.backgroundColor = [UIColor clearColor];
    }
    
    if (_locationObject.showMode == CitySelectorShowModeBottom)
    {
        UIView *selectTimeView = [[UIView alloc] init];
        UIView *showView = [[UIView alloc] init];
        selectTimeView.backgroundColor = [UIColor lightGrayColor];
        showView.backgroundColor = [UIColor whiteColor];
        
        selectTimeView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 224.0, [UIScreen mainScreen].bounds.size.width, 44.0);
        
        // 显示文字
        UILabel *showLabel = [UILabel new];
        showLabel.frame = selectTimeView.bounds;
        showLabel.text = _locationObject.pickerTitle;
        showLabel.textColor = [ToolsFunction hexStringToColor:_locationObject.pickerTitleColor];
        showLabel.textAlignment = NSTextAlignmentCenter;
        [selectTimeView addSubview:showLabel];
        
        CustomLocationPickerView *locationPicker = [[CustomLocationPickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 180, [UIScreen mainScreen].bounds.size.width, 180) locationObject:_locationObject];
        locationPicker.locationDelegate = self;
        
        if ([_locationObject.pickerBgColor hasPrefix:@"#"] ||
            [_locationObject.pickerBgColor hasPrefix:@"RGB"] ||
            [_locationObject.pickerBgColor hasPrefix:@"rgb"])
        {
            locationPicker.backgroundColor = [ToolsFunction hexStringToColor:_locationObject.pickerBgColor];
        } else {
            locationPicker.backgroundColor = [UIColor clearColor];
            _bgImageView = [[UIImageView alloc] initWithFrame:locationPicker.frame];
            _bgImageView.image = [UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:_locationObject.pickerBgColor]];
            [self.showView addSubview:_bgImageView];
        }
        
        [self.showView addSubview:locationPicker];
        
        // 确定按钮
        UIButton *buttonSub = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 64, 0, 44, 44)];
        buttonSub.titleLabel.adjustsFontSizeToFitWidth = true;
        [buttonSub setTitle:_locationObject.subBtTitle forState:UIControlStateNormal];
        [buttonSub setTitleColor:[ToolsFunction hexStringToColor:_locationObject.subBtTitleColor] forState:UIControlStateNormal];
        // buttonSub.backgroundColor = [LocationSelectorManager hexStringToColor:_locationObject.subBtBgColor];
        [buttonSub addTarget:self action:@selector(touchSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
        [selectTimeView addSubview:buttonSub];
        
        // 取消按钮
        UIButton *buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 44, 44)];
        buttonCancel.titleLabel.adjustsFontSizeToFitWidth = true;
        [buttonCancel setTitle:_locationObject.cancelBtTitle forState:UIControlStateNormal];
        [buttonCancel setTitleColor:[ToolsFunction hexStringToColor:_locationObject.cancelBtTitleColor] forState:UIControlStateNormal];
        // buttonCancel.backgroundColor = [LocationSelectorManager hexStringToColor:_locationObject.cancelBtBgColor];
        [buttonCancel addTarget:self action:@selector(touchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [selectTimeView addSubview:buttonCancel];
        
        [self.showView addSubview:selectTimeView];
    }
    else
    {
        UIView *timeView = [[UIView alloc] init];
        timeView.backgroundColor = [UIColor whiteColor];

        CustomLocationPickerView *locationPicker = [[CustomLocationPickerView alloc] initWithFrame:CGRectMake(40, [UIScreen mainScreen].bounds.size.height/2 - 90, [UIScreen mainScreen].bounds.size.width - 80, 180) locationObject:_locationObject];
        locationPicker.locationDelegate = self;
        
        if ([_locationObject.pickerBgColor hasPrefix:@"#"] ||
            [_locationObject.pickerBgColor hasPrefix:@"RGB"] ||
            [_locationObject.pickerBgColor hasPrefix:@"rgb"])
        {
            locationPicker.backgroundColor = [ToolsFunction hexStringToColor:_locationObject.pickerBgColor];
        } else {
            locationPicker.backgroundColor = [UIColor clearColor];
            _bgImageView = [[UIImageView alloc] initWithFrame:locationPicker.frame];
            _bgImageView.image = [UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:_locationObject.pickerBgColor]];
            [self.showView addSubview:_bgImageView];
        }
        
        timeView.frame = CGRectMake(40, CGRectGetMinY(locationPicker.frame) - 44, [UIScreen mainScreen].bounds.size.width - 80, 44.0);
        
        // 显示文字
        UILabel *showLabel = [UILabel new];
        showLabel.frame = timeView.bounds;
        showLabel.text = _locationObject.pickerTitle;
        showLabel.textColor = [ToolsFunction hexStringToColor:_locationObject.pickerTitleColor];
        showLabel.textAlignment = NSTextAlignmentCenter;
        [timeView addSubview:showLabel];
        
        [self.showView addSubview:timeView];
        [self.showView addSubview:locationPicker];
        
        // 确定按钮
        UIButton *buttonSub = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, CGRectGetMaxY(locationPicker.frame), [UIScreen mainScreen].bounds.size.width/2-40, 44)];
        buttonSub.titleLabel.adjustsFontSizeToFitWidth = true;
        [buttonSub setTitle:_locationObject.subBtTitle forState:UIControlStateNormal];
        [buttonSub setTitleColor:[ToolsFunction hexStringToColor:_locationObject.subBtTitleColor] forState:UIControlStateNormal];
        buttonSub.backgroundColor = [ToolsFunction hexStringToColor:_locationObject.subBtBgColor];
        [buttonSub addTarget:self action:@selector(touchSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.showView addSubview:buttonSub];
        
        // 取消按钮
        UIButton *buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(locationPicker.frame), [UIScreen mainScreen].bounds.size.width/2-40, 44)];
        buttonCancel.titleLabel.adjustsFontSizeToFitWidth = true;
        [buttonCancel setTitle:_locationObject.cancelBtTitle forState:UIControlStateNormal];
        [buttonCancel setTitleColor:[ToolsFunction hexStringToColor:_locationObject.cancelBtTitleColor] forState:UIControlStateNormal];
        buttonCancel.backgroundColor = [ToolsFunction hexStringToColor:_locationObject.cancelBtBgColor];
        [buttonCancel addTarget:self action:@selector(touchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.showView addSubview:buttonCancel];
    }
    
    [self addSubview:self.showView];
}

#pragma mark - CustomLocationPickerViewDelegate

- (void)didSelectLocation:(NSDictionary *)locationDictionary
{
    _locationDictionary = locationDictionary;
}

#pragma mark - Touch Method

- (void)touchSubmitButton:(id)sender
{

    _isCallBack = true;

    NSMutableDictionary *dicBack = [NSMutableDictionary new];
    
    if (_locationDictionary == nil)
    {
        if (_locationObject.selectMode == CitySelectorModeCouty) {
            [dicBack setValue:_locationDictionary[@"province"] == nil ? _locationObject.defaultProvince : _locationDictionary[@"province"] forKey:@"province"];
        } else if (_locationObject.selectMode == CitySelectorModeCity)
        {
            [dicBack setValue:_locationDictionary[@"province"] == nil ? _locationObject.defaultProvince : _locationDictionary[@"province"] forKey:@"province"];
            [dicBack setValue:_locationDictionary[@"city"] == nil ? _locationObject.defaultCity : _locationDictionary[@"city"] forKey:@"city"];
        } else {
            [dicBack setValue:_locationDictionary[@"province"] == nil ? _locationObject.defaultProvince : _locationDictionary[@"province"] forKey:@"province"];
            [dicBack setValue:_locationDictionary[@"city"] == nil ? _locationObject.defaultCity : _locationDictionary[@"city"] forKey:@"city"];
            [dicBack setValue:_locationDictionary[@"zone"] == nil ? _locationObject.defaultCouty : _locationDictionary[@"zone"] forKey:@"zone"];
        }
    } else {
        [dicBack addEntriesFromDictionary:_locationDictionary];
    }
    
    _submitDictionary = [NSMutableDictionary dictionaryWithDictionary:dicBack];
    [_submitDictionary setValue:@"1" forKey:@"index"];
    
    _callbackString = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:_submitDictionary]];
    
    [self hide];
}

- (void)touchCancelButton:(id)sender
{

    _isCallBack = true;
    

    _callbackString = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:@{@"index" : @0}]];
    
    [self hide];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    _isCallBack = false;
    

    if (_locationObject.pickerModal ==  1)
    {
        [self hide];
    }
}

#pragma mark - JS Method

- (void)open:(NSDictionary *)paramsDictionary
{
    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    
    [[LocationSelectorManager shareManagerDictionary:paramsDictionary[@"args"]] show];
}

- (void)close:(NSDictionary *)paramsDictionary
{
    [self hide];
}

- (NSString *)transformStringToJSJsonWithJsonString:(NSString *)jsonString
{
    NSString * callBackFinalData =  [jsonString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\\\n"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\\r" withString:@"\\\r"];
    callBackFinalData = [callBackFinalData stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    return callBackFinalData;
}

// 返回js操作
- (void)mainThreadOperateWithParamsString:(NSString *)paramsString
{
    if (_isCallBack)
    {
        [[AppDelegate shareAppDelegate].excuteWebView stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);",[[NSUserDefaults standardUserDefaults] valueForKey:@"cbid"], paramsString, paramsString]];
    }

}

@end
