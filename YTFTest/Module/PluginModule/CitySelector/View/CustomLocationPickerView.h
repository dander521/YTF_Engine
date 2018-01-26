//
//  CustomLocationPickerView.h
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationObject.h"
#import "ToolsFunction.h"

@protocol CustomLocationPickerViewDelegate <NSObject>

- (void)didSelectLocation:(NSDictionary *)locationDictionary;

@end

@interface CustomLocationPickerView : UIPickerView<UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) id <CustomLocationPickerViewDelegate> locationDelegate;

- (instancetype)initWithFrame:(CGRect)frame locationObject:(LocationObject *)locationObject;

@end
