//
//  Couty.h
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Couty : NSObject

@property (nonatomic, strong) NSString *id; // id
@property (nonatomic, strong) NSString *name; // name
@property (nonatomic, strong) NSArray *city; // city

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)coutyWithDict:(NSDictionary *)dictionary;
+ (NSArray *)coutyWithArray:(NSArray *)array;

@end
