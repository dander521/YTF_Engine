//
//  City.h
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Couty.h"

@interface City : NSObject

@property (nonatomic, strong) NSString *id; // id
@property (nonatomic, strong) NSString *name; // name
@property (nonatomic, strong) NSArray <Couty *>*city; // city

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)cityWithDict:(NSDictionary *)dictionary;
+ (NSArray *)cityWithArray:(NSArray *)array;

@end
