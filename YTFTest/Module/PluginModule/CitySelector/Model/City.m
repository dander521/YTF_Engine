//
//  City.m
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import "City.h"

@implementation City

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        [self setValue:dictionary[@"id"] forKey:@"id"];
        [self setValue:dictionary[@"name"] forKey:@"name"];
        self.city = [Couty coutyWithArray:dictionary[@"city"]];
    }
    return self;
}

+ (instancetype)cityWithDict:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

+ (NSArray *)cityWithArray:(NSArray *)array
{
    NSMutableArray *arrayCity = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        [arrayCity addObject:[self cityWithDict:dict]];
    }
    return arrayCity;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

int j = 0;
- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@:%p> {id:%@,name:%@,city:%@}---%d",self.class,self,self.id,self.name, self.city,j++];
}

@end
