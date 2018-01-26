//
//  TimeSelectorManager.m
//  CustomDatePicker
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "TimeSelectorManager.h"
#import "CustomDatePickerView.h"
#import "CustomTimePickerView.h"
#import "SelectorObject.h"

#define Animation_Time    0.2

@interface TimeSelectorManager ()<CustomDatePickerViewDelegate, CustomTimePickerViewDelegate>

@property (nonatomic, strong) UIView *showView;
@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) SelectorObject *selectorObject;

@property (nonatomic, strong) NSDictionary *timeDictionary;
@property (nonatomic, strong) NSDictionary *dateDictionary;
@property (nonatomic, strong) NSMutableDictionary *submitDictionary;

@property (nonatomic, strong) NSString *callbackString; // 回调


@property (nonatomic, assign) BOOL isCallBack;

@end

@implementation TimeSelectorManager

+ (TimeSelectorManager *)shareManagerDictionary:(NSDictionary *)dictionary
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

#pragma mark - JS Method

- (void)open:(NSDictionary *)paramsDictionary
{

    [[NSUserDefaults standardUserDefaults] setValue:paramsDictionary[@"cbId"] forKey:@"cbid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].excuteWebView = paramsDictionary[@"target"];
    
    [[TimeSelectorManager shareManagerDictionary:paramsDictionary[@"args"]] show];
}

- (void)close:(NSDictionary *)paramsDictionary
{
    [self hide];
}

#pragma mark - Setup UI

- (void)setupUIWithDictionary:(NSDictionary *)dictionary
{

    _isCallBack = false;

    _selectorObject = [SelectorObject configObjectWithDictionary:dictionary];
    _submitDictionary = [NSMutableDictionary new];
    
    if (!self.showView)
    {
        self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        self.showView.backgroundColor = [UIColor clearColor];
    }
    
    if (_selectorObject.locationMode == TimeSelectorLocationBottom)
    {
        UIView *selectTimeView = [[UIView alloc] init];
        UIView *showView = [[UIView alloc] init];
        selectTimeView.backgroundColor = [UIColor lightGrayColor];
        showView.backgroundColor = [UIColor whiteColor];
        
        switch (_selectorObject.selectMode)
        {
            case TimeSelectorModeTime:
            {
                selectTimeView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 224.0, [UIScreen mainScreen].bounds.size.width, 44.0);
                
                // 显示文字
                UILabel *showLabel = [UILabel new];
                showLabel.frame = selectTimeView.bounds;
                showLabel.text = _selectorObject.pickerTimeTitle;
                showLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerTitleColor];
                showLabel.textAlignment = NSTextAlignmentCenter;
                [selectTimeView addSubview:showLabel];
                
                CustomTimePickerView *timePicker = [[CustomTimePickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 180, [UIScreen mainScreen].bounds.size.width, 180) selectorObject:_selectorObject];
                timePicker.timeDelegate = self;
                
                if ([_selectorObject.pickerBgColor hasPrefix:@"#"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"RGB"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"rgb"])
                {
                    timePicker.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerBgColor];
                } else {
                    timePicker.backgroundColor = [UIColor clearColor];
                    _bgImageView = [[UIImageView alloc] initWithFrame:timePicker.frame];
                    _bgImageView.image = [UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:_selectorObject.pickerBgColor]];
                    [self.showView addSubview:_bgImageView];
                }

                [self.showView addSubview:timePicker];
            }
                break;
                
            case TimeSelectorModeDate:
            {
                selectTimeView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 224.0, [UIScreen mainScreen].bounds.size.width, 44.0);
                
                // 显示文字
                UILabel *showLabel = [UILabel new];
                showLabel.frame = selectTimeView.bounds;
                showLabel.text = _selectorObject.pickerDateTitle;
                showLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerTitleColor];
                showLabel.textAlignment = NSTextAlignmentCenter;
                [selectTimeView addSubview:showLabel];
                
                CustomDatePickerView *datePicker = [[CustomDatePickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 180, [UIScreen mainScreen].bounds.size.width, 180) selectorObject:_selectorObject];
                datePicker.dateDelegate = self;
                
                if ([_selectorObject.pickerBgColor hasPrefix:@"#"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"RGB"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"rgb"])
                {
                    datePicker.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerBgColor];
                } else {
                    datePicker.backgroundColor = [UIColor clearColor];
                    _bgImageView = [[UIImageView alloc] initWithFrame:datePicker.frame];
                    _bgImageView.image = [UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:_selectorObject.pickerBgColor]];
                    [self.showView addSubview:_bgImageView];
                }
                
                [self.showView addSubview:datePicker];
            }
                break;
                
            case TimeSelectorModeBoth:
            {
                selectTimeView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 448.0, [UIScreen mainScreen].bounds.size.width, 44.0);
                showView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 224.0, [UIScreen mainScreen].bounds.size.width, 44.0);
                
                // 显示文字
                UILabel *showselectLabel = [UILabel new];
                showselectLabel.frame = selectTimeView.bounds;
                showselectLabel.text = _selectorObject.pickerDateTitle;
                showselectLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerTitleColor];
                showselectLabel.textAlignment = NSTextAlignmentCenter;
                [selectTimeView addSubview:showselectLabel];
                
                // 显示文字
                UILabel *showLabel = [UILabel new];
                showLabel.frame = showView.bounds;
                showLabel.text = _selectorObject.pickerTimeTitle;
                showLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerTitleColor];
                showLabel.textAlignment = NSTextAlignmentCenter;
                [showView addSubview:showLabel];
                
                CustomTimePickerView *timePicker = [[CustomTimePickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 180, [UIScreen mainScreen].bounds.size.width, 180) selectorObject:_selectorObject];
                timePicker.timeDelegate = self;
                
                CustomDatePickerView *datePicker = [[CustomDatePickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 404, [UIScreen mainScreen].bounds.size.width, 180) selectorObject:_selectorObject];
                datePicker.dateDelegate = self;
                
                
                if ([_selectorObject.pickerBgColor hasPrefix:@"#"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"RGB"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"rgb"])
                {
                    timePicker.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerBgColor];
                    datePicker.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerBgColor];
                } else {
                    timePicker.backgroundColor = [UIColor clearColor];
                    datePicker.backgroundColor = [UIColor clearColor];
                    showLabel.backgroundColor = [UIColor clearColor];
                    showView.backgroundColor = [UIColor clearColor];
                    
                    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(datePicker.frame), CGRectGetMinY(datePicker.frame), CGRectGetWidth(datePicker.frame), CGRectGetHeight(timePicker.frame) + CGRectGetHeight(datePicker.frame) + CGRectGetHeight(showselectLabel.frame))];
                    
                    _bgImageView.image = [UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:_selectorObject.pickerBgColor]];
                    [self.showView addSubview:_bgImageView];
                }

                [self.showView addSubview:timePicker];
                [self.showView addSubview:datePicker];
                [self.showView addSubview:showView];
            }
                break;
                
            default:
                break;
        }
        
        // 确定按钮
        UIButton *buttonSub = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 64, 0, 44, 44)];
        buttonSub.titleLabel.adjustsFontSizeToFitWidth = true;
        [buttonSub setTitle:_selectorObject.subBtTitle forState:UIControlStateNormal];
        [buttonSub setTitleColor:[ToolsFunction hexStringToColor:_selectorObject.subBtTitleColor] forState:UIControlStateNormal];
        //buttonSub.backgroundColor = [TimeSelectorManager hexStringToColor:_selectorObject.subBtBgColor];
        [buttonSub addTarget:self action:@selector(touchSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
        [selectTimeView addSubview:buttonSub];
        
        // 取消按钮
        UIButton *buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 44, 44)];
        buttonCancel.titleLabel.adjustsFontSizeToFitWidth = true;
        [buttonCancel setTitle:_selectorObject.cancelBtTitle forState:UIControlStateNormal];
        [buttonCancel setTitleColor:[ToolsFunction hexStringToColor:_selectorObject.cancelBtTitleColor] forState:UIControlStateNormal];
        //buttonCancel.backgroundColor = [TimeSelectorManager hexStringToColor:_selectorObject.cancelBtBgColor];
        [buttonCancel addTarget:self action:@selector(touchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [selectTimeView addSubview:buttonCancel];
        
        [self.showView addSubview:selectTimeView];
    }
    else
    {
        UIView *timeView = [[UIView alloc] init];
        UIView *dateView = [[UIView alloc] init];
        timeView.backgroundColor = [UIColor whiteColor];
        dateView.backgroundColor = [UIColor whiteColor];
        
        UIView *lastView = nil;
        
        switch (_selectorObject.selectMode)
        {
            case TimeSelectorModeTime:
            {
                CustomTimePickerView *timePicker = [[CustomTimePickerView alloc] initWithFrame:CGRectMake(40, [UIScreen mainScreen].bounds.size.height/2 - 90, [UIScreen mainScreen].bounds.size.width - 80, 180) selectorObject:_selectorObject];
                timePicker.timeDelegate = self;
                
                if ([_selectorObject.pickerBgColor hasPrefix:@"#"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"RGB"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"rgb"])
                {
                    timePicker.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerBgColor];
                } else {
                    timePicker.backgroundColor = [UIColor clearColor];
                    _bgImageView = [[UIImageView alloc] initWithFrame:timePicker.frame];
                    _bgImageView.image = [UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:_selectorObject.pickerBgColor]];
                    [self.showView addSubview:_bgImageView];
                }

                timeView.frame = CGRectMake(40, CGRectGetMinY(timePicker.frame) - 44, [UIScreen mainScreen].bounds.size.width - 80, 44.0);
                
                // 显示文字
                UILabel *showLabel = [UILabel new];
                showLabel.frame = timeView.bounds;
                showLabel.text = _selectorObject.pickerTimeTitle;
                showLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerTitleColor];
                showLabel.textAlignment = NSTextAlignmentCenter;
                [timeView addSubview:showLabel];
                
                [self.showView addSubview:timeView];
                [self.showView addSubview:timePicker];
                
                lastView = timePicker;
            }
                break;
                
            case TimeSelectorModeDate:
            {
                CustomDatePickerView *datePicker = [[CustomDatePickerView alloc] initWithFrame:CGRectMake(40, [UIScreen mainScreen].bounds.size.height/2 - 90, [UIScreen mainScreen].bounds.size.width - 80, 180) selectorObject:_selectorObject];
                datePicker.dateDelegate = self;
                
                datePicker.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerBgColor];

                dateView.frame = CGRectMake(40, CGRectGetMinY(datePicker.frame) - 44, [UIScreen mainScreen].bounds.size.width - 80, 44.0);
                
                if ([_selectorObject.pickerBgColor hasPrefix:@"#"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"RGB"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"rgb"])
                {
                    datePicker.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerBgColor];
                } else {
                    datePicker.backgroundColor = [UIColor clearColor];
                    _bgImageView = [[UIImageView alloc] initWithFrame:datePicker.frame];
                    _bgImageView.image = [UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:_selectorObject.pickerBgColor]];
                    [self.showView addSubview:_bgImageView];
                }
                
                
                // 显示文字
                UILabel *showselectLabel = [UILabel new];
                showselectLabel.frame = dateView.bounds;
                showselectLabel.text = _selectorObject.pickerDateTitle;
                showselectLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerTitleColor];
                showselectLabel.textAlignment = NSTextAlignmentCenter;
                [dateView addSubview:showselectLabel];
                
                [self.showView addSubview:dateView];
                [self.showView addSubview:datePicker];
                
                lastView = datePicker;
            }
                break;
                
            case TimeSelectorModeBoth:
            {
                CustomTimePickerView *timePicker = [[CustomTimePickerView alloc] initWithFrame:CGRectMake(40, [UIScreen mainScreen].bounds.size.height/2 + 44.0, [UIScreen mainScreen].bounds.size.width - 80, 180) selectorObject:_selectorObject];
                timePicker.timeDelegate = self;
                
                timeView.frame = CGRectMake(40, CGRectGetMinY(timePicker.frame) - 44, [UIScreen mainScreen].bounds.size.width - 80, 44.0);
                
                CustomDatePickerView *datePicker = [[CustomDatePickerView alloc] initWithFrame:CGRectMake(40, [UIScreen mainScreen].bounds.size.height/2 - 180, [UIScreen mainScreen].bounds.size.width - 80, 180) selectorObject:_selectorObject];
                datePicker.dateDelegate = self;

                dateView.frame = CGRectMake(40, CGRectGetMinY(datePicker.frame) - 44, [UIScreen mainScreen].bounds.size.width - 80, 44.0);
                
                // 显示文字
                UILabel *showLabel = [UILabel new];
                showLabel.frame = timeView.bounds;
                showLabel.text = _selectorObject.pickerTimeTitle;
                showLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerTitleColor];
                showLabel.textAlignment = NSTextAlignmentCenter;
                [timeView addSubview:showLabel];
                
                // 显示文字
                UILabel *showselectLabel = [UILabel new];
                showselectLabel.frame = dateView.bounds;
                showselectLabel.text = _selectorObject.pickerDateTitle;
                showselectLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerTitleColor];
                showselectLabel.textAlignment = NSTextAlignmentCenter;
                [dateView addSubview:showselectLabel];
                
                if ([_selectorObject.pickerBgColor hasPrefix:@"#"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"RGB"] ||
                    [_selectorObject.pickerBgColor hasPrefix:@"rgb"])
                {
                    timePicker.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerBgColor];
                    datePicker.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerBgColor];
                } else {
                    timePicker.backgroundColor = [UIColor clearColor];
                    datePicker.backgroundColor = [UIColor clearColor];
                    showLabel.backgroundColor = [UIColor clearColor];
                    timeView.backgroundColor = [UIColor clearColor];
                    
                    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(datePicker.frame), CGRectGetMinY(datePicker.frame), CGRectGetWidth(datePicker.frame), CGRectGetHeight(timePicker.frame) + CGRectGetHeight(datePicker.frame) + CGRectGetHeight(showLabel.frame))];
                    
                    _bgImageView.image = [UIImage imageWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:_selectorObject.pickerBgColor]];
                    [self.showView addSubview:_bgImageView];
                }
                
                [self.showView addSubview:dateView];
                [self.showView addSubview:timeView];
                [self.showView addSubview:timePicker];
                [self.showView addSubview:datePicker];
                
                lastView = timePicker;
            }
                break;
                
            default:
                break;
        }
        
        // 确定按钮
        UIButton *buttonSub = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, CGRectGetMaxY(lastView.frame), [UIScreen mainScreen].bounds.size.width/2-40, 44)];
        buttonSub.titleLabel.adjustsFontSizeToFitWidth = true;
        [buttonSub setTitle:_selectorObject.subBtTitle forState:UIControlStateNormal];
        [buttonSub setTitleColor:[ToolsFunction hexStringToColor:_selectorObject.subBtTitleColor] forState:UIControlStateNormal];
        buttonSub.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.subBtBgColor];
        [buttonSub addTarget:self action:@selector(touchSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.showView addSubview:buttonSub];
        
        // 取消按钮
        UIButton *buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(lastView.frame), [UIScreen mainScreen].bounds.size.width/2-40, 44)];
        buttonCancel.titleLabel.adjustsFontSizeToFitWidth = true;
        [buttonCancel setTitle:_selectorObject.cancelBtTitle forState:UIControlStateNormal];
        [buttonCancel setTitleColor:[ToolsFunction hexStringToColor:_selectorObject.cancelBtTitleColor] forState:UIControlStateNormal];
        buttonCancel.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.cancelBtBgColor];
        [buttonCancel addTarget:self action:@selector(touchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.showView addSubview:buttonCancel];
    }
    
    [self addSubview:self.showView];
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

#pragma mark - Touch Method

- (void)touchSubmitButton:(id)sender
{

    _isCallBack = true;

    NSMutableDictionary *dicBack = [NSMutableDictionary new];
    
    switch (_selectorObject.selectMode) {
        case TimeSelectorModeTime:
        {
            if (_timeDictionary == nil)
            {
                [dicBack setValue:_timeDictionary[@"hour"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultHour] : _timeDictionary[@"hour"] forKey:@"hour"];
                [dicBack setValue:_timeDictionary[@"minute"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMinute] : _timeDictionary[@"minute"] forKey:@"minute"];
                if (_selectorObject.hourMode == TimeSelectorHourMode12)
                {
                    [dicBack setValue:_timeDictionary[@"am_pm"] == nil ? _selectorObject.defaultAmPm : _timeDictionary[@"am_pm"] forKey:@"am_pm"];
                }
                
            } else {
                [dicBack addEntriesFromDictionary:_timeDictionary];
            }
        }
            break;
            
        case TimeSelectorModeDate:
        {
            if (_dateDictionary == nil)
            {
                [dicBack setValue:_dateDictionary[@"year"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultYear] : _dateDictionary[@"year"] forKey:@"year"];
                [dicBack setValue:_dateDictionary[@"month"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMonth] : _dateDictionary[@"month"] forKey:@"month"];
                [dicBack setValue:_dateDictionary[@"day"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultDay] : _dateDictionary[@"day"] forKey:@"day"];
            } else {
                [dicBack addEntriesFromDictionary:_dateDictionary];
            }
        }
            break;
            
        case TimeSelectorModeBoth:
        {
            if (_timeDictionary == nil)
            {
                [dicBack setValue:_timeDictionary[@"hour"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultHour] : _timeDictionary[@"hour"] forKey:@"hour"];
                [dicBack setValue:_timeDictionary[@"minute"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMinute] : _timeDictionary[@"minute"] forKey:@"minute"];
                if (_selectorObject.hourMode == TimeSelectorHourMode12)
                {
                    [dicBack setValue:_timeDictionary[@"am_pm"] == nil ? _selectorObject.defaultAmPm : _timeDictionary[@"am_pm"] forKey:@"am_pm"];
                }
            } else {
                dicBack = [NSMutableDictionary dictionaryWithDictionary:_timeDictionary];
            }
            
            if (_dateDictionary == nil)
            {
                [dicBack setValue:_dateDictionary[@"year"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultYear] : _dateDictionary[@"year"] forKey:@"year"];
                [dicBack setValue:_dateDictionary[@"month"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMonth] : _dateDictionary[@"month"] forKey:@"month"];
                [dicBack setValue:_dateDictionary[@"day"] == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultDay] : _dateDictionary[@"day"] forKey:@"day"];
            } else {
                [dicBack addEntriesFromDictionary:_dateDictionary];
            }
        }
            break;
            
        default:
            break;
    }
    
    [dicBack setValue:@"1" forKey:@"index"];
    
    _callbackString = [self transformStringToJSJsonWithJsonString:[ToolsFunction dicToJavaScriptString:dicBack]];
    
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

    if (_selectorObject.pickerModal ==  1)
    {
        [self hide];
    }
}


#pragma mark - CustomDatePickerViewDelegate

- (void)didSelectDate:(NSDictionary *)dateDictionary
{
    _dateDictionary = dateDictionary;
}

#pragma mark - CustomTimePickerViewDelegate

- (void)didSelectTime:(NSDictionary *)timeDictionary
{
    _timeDictionary = timeDictionary;
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
