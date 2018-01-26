//
//  CustomTimePickerView.h
//  CustomDatePicker
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "UIPickerView+malPicker.h"

@implementation UIPickerView (malPicker)

- (void)clearSpearatorLine
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.frame.size.height < 1)
        {
            [obj setBackgroundColor:[UIColor clearColor]];
        }
    }];
}

@end
