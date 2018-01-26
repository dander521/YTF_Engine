//
//  SelectorObject.h
//  CustomDatePicker
//
//  Created by apple on 2016/12/30.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Default_Year                    2016    // 默认年
#define Default_Month                   6       // 默认月
#define Default_Day                     12      // 默认日
#define Default_Hour                    2       // 默认小时
#define Default_Minute                  30      // 默认分钟

#define Default_Time_Mode               0       // 默认 时间选择器
#define Default_Show_Mode               1       // 默认显示位置 居中
#define Default_Hour_Mode               0       // 默认时间模式 24小时

#define Default_Year_Min                1949    // 最小年
#define Default_Year_Max                2050    // 最大年

#define Default_Picker_BgColor          @"#fff"         // 选择器背景 颜色 图片
#define Default_Picker_SelectedColor    @"#02b875"      // 选择器选中文字颜色
#define Default_Picker_UnSelectedColor  @"#999"         // 选择器未选中文字颜色
#define Default_Picker_SeparateColor    @"#ccc"         // 分割线颜色

#define Default_Picker_TitleColor       @"#333"         // 选择器提示文字颜色
#define Default_Picker_TimeTitle        @"选择时间"      // 时间选择器提示文字
#define Default_Picker_DateTitle        @"选择日期"      // 日期选择器提示文字

#define Default_ButtonTitle_Submit      @"确认"          // 确认按钮文字
#define Default_ButtonTitle_Cancel      @"取消"          // 取消按钮文字
#define Default_ButtonTitle_SubmitColor @"#fff"         // 确认按钮文字颜色
#define Default_ButtonTitle_CancelColor @"#fff"         // 取消按钮文字颜色
#define Default_ButtonBgColor_Submit    @"#02b875"      // 确认按钮背景色
#define Default_ButtonBgColor_Cancel    @"#999"         // 取消按钮背景色

#define Default_Picker_Modal            1               // 点击窗口外可关闭


typedef NS_ENUM(NSUInteger, TimeSelectorMode) {
    TimeSelectorModeTime = 0,
    TimeSelectorModeDate = 1,
    TimeSelectorModeBoth = 2
};

typedef NS_ENUM(NSUInteger, TimeSelectorLocation) {
    TimeSelectorLocationBottom = 0,
    TimeSelectorLocationCenter = 1
};

typedef NS_ENUM(NSUInteger, TimeSelectorHourMode) {
    TimeSelectorHourMode24 = 0,
    TimeSelectorHourMode12 = 1
};


@interface SelectorObject : NSObject

@property (nonatomic, assign) NSUInteger pickerModal; // 点击窗口外区域隐藏

@property (nonatomic, assign) NSUInteger defaultYear; // 默认年
@property (nonatomic, assign) NSUInteger defaultMonth; // 默认月
@property (nonatomic, assign) NSUInteger defaultDay; // 默认日
@property (nonatomic, assign) NSUInteger defaultHour; // 默认小时
@property (nonatomic, assign) NSUInteger defaultMinute; // 默认分钟
@property (nonatomic, strong) NSString *defaultAmPm; // 默认分钟

@property (nonatomic, assign) NSUInteger maxYear; // 最大年
@property (nonatomic, assign) NSUInteger minYear; // 最小年

@property (nonatomic, assign) TimeSelectorMode selectMode; // 默认 时间选择器
@property (nonatomic, assign) TimeSelectorLocation locationMode; // 默认显示位置 居中
@property (nonatomic, assign) TimeSelectorHourMode hourMode; // 默认时间模式 24小时

@property (nonatomic, strong) NSString *pickerTimeTitle; // 时间选择器提示语
@property (nonatomic, strong) NSString *pickerDateTitle; // 日期选择器提示语

@property (nonatomic, strong) NSString *pickerBgColor; // 选择器背景
@property (nonatomic, strong) NSString *pickerTitleColor; // 选择器提示语颜色
@property (nonatomic, strong) NSString *pickerSepatateColor; // 选择器分割线颜色
@property (nonatomic, strong) NSString *pickerSelectedColor; // 选择器选中颜色
@property (nonatomic, strong) NSString *pickerUnSelectedColor; // 选择器未选中颜色


@property (nonatomic, strong) NSString *subBtBgColor; // 确认按钮背景色
@property (nonatomic, strong) NSString *subBtTitleColor; // 确认按钮文字颜色
@property (nonatomic, strong) NSString *subBtTitle; // 确认按钮文字

@property (nonatomic, strong) NSString *cancelBtBgColor; // 取消按钮背景色
@property (nonatomic, strong) NSString *cancelBtTitleColor; // 取消按钮文字颜色
@property (nonatomic, strong) NSString *cancelBtTitle; // 取消按钮文字

@property (nonatomic, strong) NSMutableArray *yearArray; // 年
@property (nonatomic, strong) NSMutableArray *monthArray; // 月
@property (nonatomic, strong) NSMutableArray *day31Array; // 31 天
@property (nonatomic, strong) NSMutableArray *day30Array; // 30 天
@property (nonatomic, strong) NSMutableArray *day29Array; // 29 天
@property (nonatomic, strong) NSMutableArray *day28Array; // 28 天

@property (nonatomic, strong) NSArray *amPmArray; // 早上下午
@property (nonatomic, strong) NSMutableArray *hourArray; // 小时
@property (nonatomic, strong) NSMutableArray *minuteArray; // 分钟


+ (SelectorObject *)configObjectWithDictionary:(NSDictionary *)dictionary;


@end
