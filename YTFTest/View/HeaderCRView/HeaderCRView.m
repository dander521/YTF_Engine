//
//  HeaderCRView.m
//  YTFTest
//
//  Created by apple on 2016/11/16.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "HeaderCRView.h"

@implementation HeaderCRView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:60.0/255.0 green:80.0/255.0 blue:105.0/255.0 alpha:1.0];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, CGRectGetWidth(self.frame) - 160, 50.0)];
        label.text = @"应用列表";
        label.font = [UIFont systemFontOfSize:16.0];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        UIButton *buttonAlert = [UIButton buttonWithType:UIButtonTypeContactAdd];
        buttonAlert.frame = CGRectMake(CGRectGetMaxX(label.frame), 30.0, 80.0, 50.0);
        buttonAlert.tintColor = [UIColor whiteColor];
        [buttonAlert addTarget:self action:@selector(touchInputParamButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:buttonAlert];
    }
    
    return self;
}

- (void)touchInputParamButton:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(touchInputButton)])
    {
        [self.delegate touchInputButton];
    }
}

@end
