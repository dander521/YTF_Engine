//
//  SelectorObject.m
//  CustomDatePicker
//
//  Created by apple on 2016/12/30.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "SelectorObject.h"

@implementation SelectorObject

+ (SelectorObject *)configObjectWithDictionary:(NSDictionary *)dictionary
{
    /*
     
     mode:
     showMode:
     hourMode:
     minYear:
     maxYear:
     defaultValue:{
     year
     month
     day
     hour
     minute
     }
     
     bgColor:
     normalColor:
     selectedColor:
     separateColor:
     titleColor:
     timeTitle:
     dateTitle:
     
     enterValue:
     cancelValue:
     enterBgColor:
     cancelBgColor:
     enterColor:
     cancelColor:
     
     */
    SelectorObject *object = [[SelectorObject alloc] init];
    
    object.selectMode = dictionary[@"mode"] == nil ? Default_Time_Mode : [dictionary[@"mode"] integerValue];
    object.locationMode = dictionary[@"showMode"] == nil ? Default_Show_Mode : [dictionary[@"showMode"] integerValue];
    object.hourMode = dictionary[@"hourMode"] == nil ? Default_Hour_Mode : [dictionary[@"hourMode"] integerValue];
    
    object.pickerModal = dictionary[@"modal"] == nil ? Default_Picker_Modal : [dictionary[@"modal"] integerValue];

    object.minYear = dictionary[@"minYear"] == nil ? Default_Year_Min : [dictionary[@"minYear"] integerValue];
    object.maxYear = dictionary[@"maxYear"] == nil ? Default_Year_Max : [dictionary[@"maxYear"] integerValue];
    
    object.defaultYear = dictionary[@"defaultValue"][@"year"] == nil ? Default_Year : [dictionary[@"defaultValue"][@"year"] integerValue];
    object.defaultMonth = dictionary[@"defaultValue"][@"month"] == nil ? Default_Month : [dictionary[@"defaultValue"][@"month"] integerValue];
    object.defaultDay = dictionary[@"defaultValue"][@"day"] == nil ? Default_Day : [dictionary[@"defaultValue"][@"day"] integerValue];
    object.defaultHour = dictionary[@"defaultValue"][@"hour"] == nil ? Default_Hour : [dictionary[@"defaultValue"][@"hour"] integerValue];
    object.defaultMinute = dictionary[@"defaultValue"][@"minute"] == nil ? Default_Minute : [dictionary[@"defaultValue"][@"minute"] integerValue];
    
    object.pickerBgColor = dictionary[@"bgColor"] == nil ? Default_Picker_BgColor : dictionary[@"bgColor"];
    object.pickerSelectedColor = dictionary[@"selectedColor"] == nil ? Default_Picker_SelectedColor : dictionary[@"selectedColor"];
    object.pickerUnSelectedColor = dictionary[@"normalColor"] == nil ? Default_Picker_UnSelectedColor : dictionary[@"normalColor"];
    object.pickerSepatateColor = dictionary[@"separateColor"] == nil ? Default_Picker_SeparateColor : dictionary[@"separateColor"];
    object.pickerTitleColor = dictionary[@"titleColor"] == nil ? Default_Picker_TitleColor : dictionary[@"titleColor"];
    object.pickerTimeTitle = dictionary[@"timeTitle"] == nil ? Default_Picker_TimeTitle : dictionary[@"timeTitle"];
    object.pickerDateTitle = dictionary[@"dateTitle"] == nil ? Default_Picker_DateTitle : dictionary[@"dateTitle"];
    
    object.subBtTitle = dictionary[@"enterValue"] == nil ? Default_ButtonTitle_Submit : dictionary[@"enterValue"];
    object.subBtBgColor = dictionary[@"enterBgColor"] == nil ? Default_ButtonBgColor_Submit : dictionary[@"enterBgColor"];
    object.subBtTitleColor = dictionary[@"enterColor"] == nil ? Default_ButtonTitle_SubmitColor : dictionary[@"enterColor"];
    object.cancelBtTitle = dictionary[@"cancelValue"] == nil ? Default_ButtonTitle_Cancel : dictionary[@"cancelValue"];
    object.cancelBtBgColor = dictionary[@"cancelBgColor"] == nil ? Default_ButtonBgColor_Cancel : dictionary[@"cancelBgColor"];
    object.cancelBtTitleColor = dictionary[@"cancelColor"] == nil ? Default_ButtonTitle_CancelColor : dictionary[@"cancelColor"];
    
    object.amPmArray = @[@"0", @"1"];
    object.minuteArray = [object configDefaultArrayWithMin:0 maxNum:59];
    object.defaultAmPm = @"0";
    
    if (object.hourMode == TimeSelectorHourMode12)
    {
        object.hourArray = [object configDefaultArrayWithMin:1 maxNum:12];
    } else {
        object.hourArray = [object configDefaultArrayWithMin:0 maxNum:23];
    }
    
    object.day28Array = [object configDefaultArrayWithMin:1 maxNum:28];
    object.day29Array = [object configDefaultArrayWithMin:1 maxNum:29];
    object.day30Array = [object configDefaultArrayWithMin:1 maxNum:30];
    object.day31Array = [object configDefaultArrayWithMin:1 maxNum:31];
    
    object.monthArray = [object configDefaultArrayWithMin:1 maxNum:12];
    
    object.yearArray = [object configDefaultArrayWithMin:object.minYear maxNum:object.maxYear];
    
    return object;
}

- (NSMutableArray *)configDefaultArrayWithMin:(NSUInteger)minNum maxNum:(NSUInteger)maxNum
{
    NSAssert(minNum < maxNum, @"Please make sure your minNum is lower than maxNum");
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSUInteger i = minNum; i <  maxNum + 1; i++)
    {
        [array addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    
    return array;
}

@end
