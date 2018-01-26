//
//  WidgetCollectionViewCell.m
//  YTFTest
//
//  Created by apple on 2016/11/16.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "WidgetCollectionViewCell.h"

@implementation WidgetCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        self.backgroundColor = [UIColor grayColor];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) - 0.5, CGRectGetHeight(self.frame) - 0.5)];
        view.backgroundColor = [UIColor whiteColor];
        [self addSubview:view];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 15, CGRectGetWidth(self.frame) - 60, CGRectGetWidth(self.frame) - 60)];
        self.imageView.layer.cornerRadius = 10.0;
        self.imageView.layer.masksToBounds = true;
        [self addSubview:self.imageView];
        
        self.appName = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.imageView.frame) + 10.0, CGRectGetWidth(self.frame) - 10, 20.0)];
        self.appName.textAlignment = NSTextAlignmentCenter;
        self.appName.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.appName];
        
//        self.appId = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.appName.frame), CGRectGetWidth(self.frame) - 10, 20.0)];
//        self.appId.textAlignment = NSTextAlignmentCenter;
//        self.appId.font = [UIFont systemFontOfSize:10.0];
//        [self addSubview:self.appId];
    }
    
    return self;
}

@end
