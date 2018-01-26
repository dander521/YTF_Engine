//
//  Province.h
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "City.h"

@interface Province : NSObject

@property (nonatomic, strong) NSString *id; // id
@property (nonatomic, strong) NSString *name; // name
@property (nonatomic, strong) NSArray <City *>*city; // city

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)provinceWithDict:(NSDictionary *)dictionary;
+ (NSArray *)provinceWithArray:(NSArray *)array;

@end
