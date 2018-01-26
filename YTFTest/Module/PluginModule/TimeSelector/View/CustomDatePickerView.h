//
//  CustomDatePickerView.h
//  CustomDatePicker
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectorObject.h"
#import "ToolsFunction.h"

@protocol CustomDatePickerViewDelegate <NSObject>

- (void)didSelectDate:(NSDictionary *)dateDictionary;

@end

@interface CustomDatePickerView : UIPickerView<UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) id <CustomDatePickerViewDelegate> dateDelegate;
@property (nonatomic, strong) SelectorObject *selectorObject;

- (instancetype)initWithFrame:(CGRect)frame selectorObject:(SelectorObject *)selectorObject;

@end
