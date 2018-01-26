//
//  CustomDatePickerView.m
//  CustomDatePicker
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "CustomDatePickerView.h"
#import "PickerCell.h"
#import "UIPickerView+malPicker.m"

@interface CustomDatePickerView()


@property (nonatomic, strong) NSMutableArray *yearArray;
@property (nonatomic, strong) NSMutableArray *monthArray;
@property (nonatomic, strong) NSMutableArray *dayArray;

@property (nonatomic, strong) NSString *selectedYear;
@property (nonatomic, strong) NSString *selectedMonth;
@property (nonatomic, strong) NSString *selectedDay;

@property (assign, nonatomic) NSInteger currentYearIndex;
@property (assign, nonatomic) NSInteger currentMonthIndex;

@end

@implementation CustomDatePickerView

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
        [self setUpViewWithSelectorObject:selectorObject];
    }
    
    return self;
}


- (void)setUpViewWithSelectorObject:(SelectorObject *)selectorObject
{
    _selectorObject = selectorObject;
    
    self.delegate = self;
    self.dataSource = self;
    
    _yearArray = _selectorObject.yearArray;
    _monthArray = _selectorObject.monthArray;
    
    
    
    _selectedYear = [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultYear];
    _selectedMonth = [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMonth];
    _selectedDay = [NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultDay];
    
    _currentYearIndex = [_yearArray indexOfObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultYear]];
    _currentMonthIndex = [_monthArray indexOfObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMonth]];
    
    switch ([_monthArray[_currentMonthIndex%_monthArray.count] integerValue])
    {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
        _dayArray = _selectorObject.day31Array;
        break;
        
        case 2:
        if ([_yearArray[_currentYearIndex%_yearArray.count] integerValue]%4==0)
        {
            _dayArray = _selectorObject.day29Array;
        } else {
            _dayArray = _selectorObject.day28Array;
        }
        break;
        
        case 4:
        case 6:
        case 9:
        case 11:
        _dayArray = _selectorObject.day30Array;
        break;
        default:
        break;
    }
    
    [self selectRow:[_yearArray indexOfObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultYear]] + _yearArray.count * 100 inComponent:0 animated:false];
    [self selectRow:[_monthArray indexOfObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultMonth]] + _monthArray.count * 100 inComponent:1 animated:false];
    [self selectRow:[_dayArray indexOfObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectorObject.defaultDay]] + _dayArray.count * 100 inComponent:2 animated:false];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = 0;
    if (component == 0)
    {
        rows = _yearArray.count * 200;
    } else if (component == 1)
    {
        rows = _monthArray.count * 200;
    } else {
        
        switch ([_monthArray[_currentMonthIndex%_monthArray.count] integerValue])
        {
            case 1:
            case 3:
            case 5:
            case 7:
            case 8:
            case 10:
            case 12:
                rows = _dayArray.count * 200;
                break;
                
            case 2:
                if ([_yearArray[_currentYearIndex%_yearArray.count] integerValue]%4==0)
                {
                    rows = _selectorObject.day29Array.count * 200;
                } else {
                    rows = _selectorObject.day28Array.count * 200;
                }
                break;
                
            case 4:
            case 6:
            case 9:
            case 11:
                rows = _selectorObject.day30Array.count * 200;
                break;
            default:
                break;
        }
    }
    
    return rows;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    PickerCell *cell = [[PickerCell alloc] init];
    [pickerView clearSpearatorLine];
    cell.cellLabel.adjustsFontSizeToFitWidth = YES;
    cell.cellLabel.textColor = [ToolsFunction hexStringToColor:_selectorObject.pickerSelectedColor];
    cell.cellSeparate.backgroundColor = [ToolsFunction hexStringToColor:_selectorObject.pickerSepatateColor];
    
    NSString *rowText = nil;
    
    if (component == 0)
    {
        rowText = _yearArray[row%_yearArray.count];
    } else if (component == 1)
    {
        rowText = _monthArray[row%_monthArray.count];
    } else {
        
        switch ([_monthArray[_currentMonthIndex%_monthArray.count] integerValue])
        {
            case 1:
            case 3:
            case 5:
            case 7:
            case 8:
            case 10:
            case 12:
                rowText = _dayArray[row%_dayArray.count];
                break;
                
            case 2:
                if ([_yearArray[_currentYearIndex%_yearArray.count] integerValue]%4==0)
                {
                    rowText = _selectorObject.day29Array[row%_selectorObject.day29Array.count];
                } else {
                    rowText = _selectorObject.day28Array[row%_selectorObject.day28Array.count];
                }
                break;
                
            case 4:
            case 6:
            case 9:
            case 11:
                rowText = _selectorObject.day30Array[row%_selectorObject.day30Array.count];
                break;
            default:
                break;
        }
        
    }
    
    cell.cellLabel.text = rowText;
    
    
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
    if (component == 0)
    {
        _selectedYear = _yearArray[row%_yearArray.count];
        _currentYearIndex = row;
        
        switch ([_monthArray[_currentMonthIndex%_monthArray.count] integerValue])
        {
            case 1:
            case 3:
            case 5:
            case 7:
            case 8:
            case 10:
            case 12:
            _dayArray = _selectorObject.day31Array;
            break;
            
            case 2:
            if ([_yearArray[_currentYearIndex%_yearArray.count] integerValue]%4==0)
            {
                _dayArray = _selectorObject.day29Array;
            } else {
                _dayArray = _selectorObject.day28Array;
            }
            break;
            
            case 4:
            case 6:
            case 9:
            case 11:
            _dayArray = _selectorObject.day30Array;
            break;
            default:
            break;
        }
        
        [pickerView reloadComponent:2];
    } else if (component == 1)
    {
        _selectedMonth = _monthArray[row%_monthArray.count];
        _currentMonthIndex = row;
        
        switch ([_monthArray[_currentMonthIndex%_monthArray.count] integerValue])
        {
            case 1:
            case 3:
            case 5:
            case 7:
            case 8:
            case 10:
            case 12:
            _dayArray = _selectorObject.day31Array;
            break;
            
            case 2:
            if ([_yearArray[_currentYearIndex%_yearArray.count] integerValue]%4==0)
            {
                _dayArray = _selectorObject.day29Array;
            } else {
                _dayArray = _selectorObject.day28Array;
            }
            break;
            
            case 4:
            case 6:
            case 9:
            case 11:
            _dayArray = _selectorObject.day30Array;
            break;
            default:
            break;
        }
        
        [pickerView reloadComponent:2];
    } else
    {
        _selectedDay = _dayArray[row%_dayArray.count];
    }
    
    NSDictionary *dicTime = @{@"year" : _selectedYear,
                              @"month" : _selectedMonth,
                              @"day" : _selectedDay};
    
    if (_dateDelegate)
    {
        [self.dateDelegate didSelectDate:dicTime];
    }
}

@end
