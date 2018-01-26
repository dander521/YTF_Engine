//
//  CustomLocationPickerView.m
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import "CustomLocationPickerView.h"
#import "LocationPickerCell.h"
#import "UIPickerView+cusPicker.m"

#import "Province.h"
#import "City.h"
#import "Couty.h"

@interface CustomLocationPickerView ()

@property (nonatomic, strong) LocationObject *locationObject;

@property (nonatomic, assign) NSUInteger currentProvinceIndex;
@property (nonatomic, assign) NSUInteger currentCityIndex;
@property (nonatomic, assign) NSUInteger currentCoutyIndex;

@property (nonatomic, strong) NSString *selectedProvince;
@property (nonatomic, strong) NSString *selectedCity;
@property (nonatomic, strong) NSString *selectedCouty;

@end

@implementation CustomLocationPickerView

- (instancetype)initWithFrame:(CGRect)frame locationObject:(LocationObject *)locationObject
{
    if (self == [super initWithFrame:frame])
    {
        [self setUpViewSelectorObject:locationObject];
    }
    
    return self;
}

- (void)setUpViewSelectorObject:(LocationObject *)locationObject
{
    _locationObject = locationObject;
    
    self.delegate = self;
    self.dataSource = self;
    
    _selectedProvince = _locationObject.defaultProvince;
    _selectedCity = _locationObject.defaultCity;
    _selectedCouty = _locationObject.defaultCouty;
    
    _currentProvinceIndex = 0;
    _currentCityIndex = 0;
    _currentCoutyIndex = 0;
    
    for (NSUInteger i = 0; i < _locationObject.dataArray.count; i++)
    {
        Province *pro = _locationObject.dataArray[i];
        
        if ([_selectedProvince isEqualToString:pro.name])
        {
            _currentProvinceIndex = i;
            break;
        }
    }
    
    for (NSUInteger i = 0; i < _locationObject.dataArray[_currentProvinceIndex].city.count; i++)
    {
        City *city = _locationObject.dataArray[_currentProvinceIndex].city[i];
        
        if ([_selectedCity isEqualToString:city.name])
        {
            _currentCityIndex = i;
            break;
        }
    }
    
    for (NSUInteger i = 0; i < _locationObject.dataArray[_currentProvinceIndex].city[_currentCityIndex].city.count; i++)
    {
        Couty *couty = _locationObject.dataArray[_currentProvinceIndex].city[_currentCityIndex].city[i];
        
        if ([_selectedCouty isEqualToString:couty.name])
        {
            _currentCoutyIndex = i;
            break;
        }
    }
    
    if (_locationObject.selectMode == CitySelectorModeCouty)
    {
        [self selectRow:_currentProvinceIndex inComponent:0 animated:false];
    } else if (_locationObject.selectMode == CitySelectorModeCity)
    {
        [self selectRow:_currentProvinceIndex inComponent:0 animated:false];
        [self selectRow:_currentCityIndex inComponent:1 animated:false];
    } else {
        [self selectRow:_currentProvinceIndex inComponent:0 animated:false];
        [self selectRow:_currentCityIndex inComponent:1 animated:false];
        [self selectRow:_currentCoutyIndex inComponent:2 animated:false];
    }
}

#pragma mark - Data Source

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (_locationObject.selectMode)
    {
        case CitySelectorModeProvince:
        {
            return 3;
        }
            break;
            
        case CitySelectorModeCity:
        {
            return 2;
        }
            break;
            
        case CitySelectorModeCouty:
        {
            return 1;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    Province *pro = _locationObject.dataArray[_currentProvinceIndex];
    
    switch (component)
    {
        case 0:
        {
            return _locationObject.dataArray.count;
        }
            break;
            
        case 1:
        {
            return pro.city.count;
        }
            break;
            
        case 2:
        {
            City *city = pro.city[_currentCityIndex];
            return city.city.count;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

#pragma mark - Delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    LocationPickerCell *cell = [[LocationPickerCell alloc] init];
    cell.cellLabel.adjustsFontSizeToFitWidth = YES;
    [pickerView clearSpearatorLine];
    cell.cellLabel.textColor = [ToolsFunction hexStringToColor:_locationObject.pickerSelectedColor];
    cell.cellSeparate.backgroundColor = [ToolsFunction hexStringToColor:_locationObject.pickerSepatateColor];
    
    Province *pro = _locationObject.dataArray[_currentProvinceIndex];
    
    switch (component) {
        case 0:
        {
            cell.cellLabel.text =  _locationObject.dataArray[row].name;
        }
            break;
        case 1:
        {
            cell.cellLabel.text =  pro.city[row].name;
        }
            break;
        case 2:
        {
            cell.cellLabel.text =  pro.city[_currentCityIndex].city[row].name;
        }
            break;
            
        default:
            cell.cellLabel.text = @"其他";
            break;
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
    switch (component) {
        case 0:
            // 滑动了第 0 列 更新后两列
            _currentProvinceIndex = [pickerView selectedRowInComponent:0];
            
            if (_locationObject.selectMode == CitySelectorModeProvince)
            {
                [pickerView reloadComponent:1];
                [pickerView selectRow:0 inComponent:1 animated:YES];
                _currentCityIndex = 0;
                [pickerView reloadComponent:2];
                [pickerView selectRow:0 inComponent:2 animated:YES];

            } else if (_locationObject.selectMode == CitySelectorModeCity)
            {
                [pickerView reloadComponent:1];
                [pickerView selectRow:0 inComponent:1 animated:YES];
                _currentCityIndex = 0;
            }
            
            break;
            
        case 1:
            
            // 滑动了第 1 列 更新最后一列
            _currentCityIndex = [pickerView selectedRowInComponent:1];
            if (_locationObject.selectMode == CitySelectorModeProvince)
            {
                [pickerView reloadComponent:2];
                [pickerView selectRow:0 inComponent:2 animated:YES];
            }
            
            break;
            
        case 2:
            _currentCoutyIndex = row;
            break;
            
        default:
            break;
    }
    
    Province *pro = _locationObject.dataArray[_currentProvinceIndex];
    
    _selectedProvince = pro.name;
    
    if (_currentCityIndex >= pro.city.count)
    {
        _selectedCity = pro.city[0].name;
        if (_locationObject.selectMode != CitySelectorModeCouty)
        {
            [pickerView selectRow:0 inComponent:1 animated:YES];
        }
    } else {
        _selectedCity = pro.city[_currentCityIndex].name;
    }
    
    if (_currentCoutyIndex >= pro.city[_currentCityIndex].city.count)
    {
        _selectedCouty = pro.city[_currentCityIndex].city[0].name;
        if (_locationObject.selectMode == CitySelectorModeProvince)
        {
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
    }else
    {
        _selectedCouty = pro.city[_currentCityIndex].city[_currentCoutyIndex].name;
    }
    
    NSMutableDictionary *dicBack = [NSMutableDictionary new];
    
    if (_locationDelegate)
    {
        if (_locationObject.selectMode == CitySelectorModeCouty)
        {
            [dicBack setValue:_selectedProvince forKey:@"province"];
        } else if (_locationObject.selectMode == CitySelectorModeCity)
        {
            [dicBack setValue:_selectedProvince forKey:@"province"];
            [dicBack setValue:_selectedCity forKey:@"city"];
        } else {
            [dicBack setValue:_selectedProvince forKey:@"province"];
            [dicBack setValue:_selectedCity forKey:@"city"];
            [dicBack setValue:_selectedCouty forKey:@"zone"];
        }
        
        [self.locationDelegate didSelectLocation:dicBack];
    }
}

@end
