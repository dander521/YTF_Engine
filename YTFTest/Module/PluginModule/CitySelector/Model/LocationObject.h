//
//  LocationObject.h
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Province.h"
#import "AppDelegate.h"

#define Default_Location_Mode           2       // 默认 选择器省市区三级联动
#define Default_Show_Mode               1       // 默认显示位置 居中

#define Default_ButtonTitle_Cancel      @"取消"          // 取消按钮文字

#define Default_Picker_BgColor          @"#fff"         // 选择器背景 颜色 图片

#define Default_ButtonBgColor_Submit    @"#02b875"      // 确认按钮背景色
#define Default_ButtonBgColor_Cancel    @"#999"         // 取消按钮背景色
#define Default_ButtonTitle_SubmitColor @"#fff"         // 确认按钮文字颜色
#define Default_ButtonTitle_CancelColor @"#fff"         // 取消按钮文字颜色

#define Default_Picker_UnSelectedColor  @"#999"         // 选择器未选中文字颜色
#define Default_Picker_SelectedColor    @"#02b875"      // 选择器选中文字颜色
#define Default_Picker_SeparateColor    @"#ccc"         // 分割线颜色

#define Default_Picker_TitleColor       @"#333"         // 选择器提示文字颜色
#define Default_Picker_TimeTitle        @"选择地区"      // 时间选择器提示文字

#define Default_ButtonTitle_Submit      @"确认"          // 确认按钮文字

#define Default_Picker_Modal            1               // 点击窗口外可关闭


#define Default_Picker_Province         @"四川省"
#define Default_Picker_City             @"成都市"
#define Default_Picker_Zone             @"武侯区"


typedef NS_ENUM(NSUInteger, CitySelectorMode) {
    CitySelectorModeCouty = 0,
    CitySelectorModeCity = 1,
    CitySelectorModeProvince = 2
};

typedef NS_ENUM(NSUInteger, CitySelectorShowMode) {
    CitySelectorShowModeBottom = 0,
    CitySelectorShowModeCenter = 1
};

@interface LocationObject : NSObject

@property (nonatomic, assign) NSUInteger pickerModal; // 点击窗口外区域隐藏

@property (nonatomic, assign) CitySelectorMode selectMode; // 默认 三级联动选择器
@property (nonatomic, assign) CitySelectorShowMode showMode; // 默认显示位置 居中

@property (nonatomic, strong) NSString *defaultProvince; // 默认省
@property (nonatomic, strong) NSString *defaultCity; // 默认市
@property (nonatomic, strong) NSString *defaultCouty; // 默认区

@property (nonatomic, strong) NSString *pickerTitle; // 时间选择器提示语

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

@property (nonatomic, strong) NSString *dataSource; // 显示区域资源

@property (nonatomic, strong) NSArray <Province *>*dataArray; // 省市区数据

+ (LocationObject *)configObjectWithDictionary:(NSDictionary *)dictionary;

@end
