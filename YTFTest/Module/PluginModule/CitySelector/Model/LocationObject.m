//
//  LocationObject.m
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import "LocationObject.h"


@implementation LocationObject

+ (LocationObject *)configObjectWithDictionary:(NSDictionary *)dictionary
{
    LocationObject *object = [[LocationObject alloc] init];
    
    object.selectMode = dictionary[@"mode"] == nil ? Default_Location_Mode : [dictionary[@"mode"] integerValue];
    object.showMode = dictionary[@"showMode"] == nil ? Default_Show_Mode : [dictionary[@"showMode"] integerValue];
    
    object.pickerModal = dictionary[@"modal"] == nil ? Default_Picker_Modal : [dictionary[@"modal"] integerValue];

    object.defaultProvince = dictionary[@"defaultValue"][@"province"] == nil ? Default_Picker_Province : dictionary[@"defaultValue"][@"province"];
    object.defaultCity = dictionary[@"defaultValue"][@"city"] == nil ? Default_Picker_City : dictionary[@"defaultValue"][@"city"];
    object.defaultCouty = dictionary[@"defaultValue"][@"zone"] == nil ? Default_Picker_Zone : dictionary[@"defaultValue"][@"zone"];
    
    object.pickerBgColor = dictionary[@"bgColor"] == nil ? Default_Picker_BgColor : dictionary[@"bgColor"];
    object.pickerSelectedColor = dictionary[@"selectedColor"] == nil ? Default_Picker_SelectedColor : dictionary[@"selectedColor"];
    object.pickerUnSelectedColor = dictionary[@"normalColor"] == nil ? Default_Picker_UnSelectedColor : dictionary[@"normalColor"];
    object.pickerSepatateColor = dictionary[@"separateColor"] == nil ? Default_Picker_SeparateColor : dictionary[@"separateColor"];
    object.pickerTitleColor = dictionary[@"titleColor"] == nil ? Default_Picker_TitleColor : dictionary[@"titleColor"];
    object.pickerTitle = dictionary[@"title"] == nil ? Default_Picker_TimeTitle : dictionary[@"title"];
    
    object.subBtTitle = dictionary[@"enterValue"] == nil ? Default_ButtonTitle_Submit : dictionary[@"enterValue"];
    object.subBtBgColor = dictionary[@"enterBgColor"] == nil ? Default_ButtonBgColor_Submit : dictionary[@"enterBgColor"];
    object.subBtTitleColor = dictionary[@"enterColor"] == nil ? Default_ButtonTitle_SubmitColor : dictionary[@"enterColor"];
    object.cancelBtTitle = dictionary[@"cancelValue"] == nil ? Default_ButtonTitle_Cancel : dictionary[@"cancelValue"];
    object.cancelBtBgColor = dictionary[@"cancelBgColor"] == nil ? Default_ButtonBgColor_Cancel : dictionary[@"cancelBgColor"];
    object.cancelBtTitleColor = dictionary[@"cancelColor"] == nil ? Default_ButtonTitle_CancelColor : dictionary[@"cancelColor"];
    
    object.dataSource = dictionary[@"dataSource"];
    
    object.dataArray = [object configLocationDataWithDataSource:object.dataSource];
    
    return object;
}

- (NSArray *)configLocationDataWithDataSource:(NSString *)dataSource
{
    NSArray *array = nil;
    NSData *dataJson = nil;
    if (dataSource && ![dataSource isEqualToString:@""])
    {
        dataJson = [NSData dataWithContentsOfFile:[[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:dataSource]];
    } else {
        dataJson = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cityNew" ofType:@"json"]];
    }
    
    NSAssert(dataJson != nil, @"请检查你的数据源文件是否存在，格式是否正确");
    
    NSArray *arrayCity = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:nil];
    
    array = [Province provinceWithArray:arrayCity];
    
    return array;
}


@end
