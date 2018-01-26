//
//  PickerCell.m
//  DatePopView
//
//  Created by wangtian on 16/4/20.
//  Copyright © 2016年 maliang. All rights reserved.
//

#import "PickerCell.h"

@implementation PickerCell

- (instancetype)init
{
    if (self == [super init])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.width - 100.0)/3, 60);
        
        self.cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, ([UIScreen mainScreen].bounds.size.width - 100.0)/3, 40)];
        self.cellLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.cellLabel];
        
        self.cellSeparate = [[UIView alloc] initWithFrame:CGRectMake(5, 59, ([UIScreen mainScreen].bounds.size.width - 100.0)/3 - 10, 1)];
        [self addSubview:self.cellSeparate];
    }
    
    return self;
}


@end
