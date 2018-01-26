//
//  CustomTimePickerView.m
//  CustomDatePicker
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "CustomTimePickerView.h"
#import "PickerCell.h"
#import "UIPickerView+malPicker.m"


@interface CustomTimePickerView()

@property (nonatomic, strong) NSArray *hourArray;
@property (nonatomic, strong) NSArray *minuteArray;
@property (nonatomic, strong) NSArray *amPmArray;

@property (nonatomic, strong) NSString *selectedHour;
@property (nonatomic, strong) NSString *selectedMinute;
@property (nonatomic, strong) NSString *selectedAmPm;

@property (nonatomic, strong) UIImageView *backImageView;

@end

@implementation CustomTimePickerView

//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    if (self = [super initWithCoder:aDecoder])
//    {
//        [self setUpView];
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame selectorObject:(SelectorObject *)selectorObject
{
    if (self == [super initWithFrame:frame])
    {
        [self setUpViewSelectorObject:selectorObject];
    }
    
    return self;
}


- (void)setUpViewSelectorObject:(SelectorObject *)selectorObject
{
    _selectorObject = selectorObject;
    
    self.delegate = self;
    self.dataSource = self;

    _hourArray = _selectorObject.hourArray;
    _minuteArray = _selectorObject.minuteArray;
    _amPmArray = _selectorObject.amPmArray;
    
    _selectedAmPm = _amPmArray[0];
    _selectedHour = [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultHour];
    _selectedMinute = [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMinute];
    
    if (_selectorObject.hourMode == TimeSelectorHourMode12)
    {
        [self selectRow:[_selectedAmPm integerValue] + _amPmArray.count * 100 inComponent:0 animated:false];
        [self selectRow:[_hourArray indexOfObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultHour]] + _hourArray.count * 100 inComponent:1 animated:false];
        [self selectRow:[_minuteArray indexOfObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMinute]] + _minuteArray.count * 100 inComponent:2 animated:false];
    } else {
        [self selectRow:[_hourArray indexOfObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultHour]] + _hourArray.count * 100 inComponent:0 animated:false];
        [self selectRow:[_minuteArray indexOfObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMinute]] + _minuteArray.count * 100 inComponent:1 animated:false];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSUInteger component = 0;
    
    if (_selectorObject.hourMode == TimeSelectorHourMode12)
    {
        component = 3;
    } else {
        component = 2;
    }
    
    return component;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSUInteger rows = 0;
    
    if (_selectorObject.hourMode == TimeSelectorHourMode12)
    {
        if (component == 2)
        {
            rows = _minuteArray.count * 200;
        } else if (component == 1) {
            rows = _hourArray.count * 200;
        } else {
            rows = _amPmArray.count * 200;
        }
    } else {
        if (component == 1)
        {
            rows = _minuteArray.count * 200;
        } else{
            rows = _hourArray.count * 200;
        }
    }
    
    return rows;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    PickerCell *cell = [[PickerCell alloc] init];
    cell.cellLabel.adjustsFontSizeToFitWidth = YES;
    [pickerView clearSpearatorLine];
    cell.cellLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerSelectedColor];
    cell.cellSeparate.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerSepatateColor];
    
    if (_selectorObject.hourMode == TimeSelectorHourMode12)
    {
        if (component == 2)
        {
            cell.cellLabel.text = _minuteArray[row%_minuteArray.count];
        } else if (component == 1) {
            cell.cellLabel.text = _hourArray[row%_hourArray.count];
        } else{
            if ([_amPmArray[row%_amPmArray.count] isEqualToString:@"0"])
            {
                cell.cellLabel.text = @"Am";
            } else {
                cell.cellLabel.text = @"Pm";
            }
        }
    } else {
        if (component == 1)
        {
            cell.cellLabel.text = _minuteArray[row%_minuteArray.count];
        } else{
            cell.cellLabel.text = _hourArray[row%_hourArray.count];
        }
    }
    
    return cell;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return ([UIScreen mainScreen].bounds.size.width - 100.0)/3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_selectorObject.hourMode == TimeSelectorHourMode12)
    {
        if (component == 1)
        {
            _selectedHour = _hourArray[row%_hourArray.count];
        } else if (component == 2) {
            _selectedMinute = _minuteArray[row%_minuteArray.count];
        } else {
            _selectedAmPm = _amPmArray[row%_amPmArray.count];
        }
    } else {
        if (component == 0)
        {
            _selectedHour = _hourArray[row%_hourArray.count];
        } else {
            _selectedMinute = _minuteArray[row%_minuteArray.count];
        }
    }
    
    NSMutableDictionary *dicTime = [NSMutableDictionary new];
    [dicTime setValue:_selectedHour forKey:@"hour"];
    [dicTime setValue:_selectedMinute forKey:@"minute"];
    [dicTime setValue:_selectedAmPm forKey:@"am_pm"];
    
    if (_timeDelegate)
    {
        [self.timeDelegate didSelectTime:dicTime];
    }
}

@end
