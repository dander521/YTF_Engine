//
//  BottomView.m
//  YTFTest
//
//  Created by apple on 2017/1/13.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import "BrowserBottomView.h"

@implementation BrowserBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.cornerRadius = CGRectGetWidth(self.frame)/2;
        self.layer.masksToBounds = true;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6)];
        
        self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame)/2;
        self.imageView.layer.masksToBounds = true;
        
        [self addSubview:self.imageView];
    }
    
    return self;
}

- (void)setIsChecked:(BOOL)isChecked
{
    if (isChecked)
    {
        self.backgroundColor = [UIColor redColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
