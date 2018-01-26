//
//  Province.m
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import "Province.h"

@implementation Province

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        [self setValue:dictionary[@"id"] forKey:@"id"];
        [self setValue:dictionary[@"name"] forKey:@"name"];
        self.city = [City cityWithArray:dictionary[@"city"]];
    }
    return self;
}

+ (instancetype)provinceWithDict:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

+ (NSArray *)provinceWithArray:(NSArray *)array
{
    NSMutableArray *arrayProvince = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        [arrayProvince addObject:[self provinceWithDict:dict]];
    }
    return arrayProvince;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

int i = 0;
- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@:%p> {id:%@,name:%@,city:%@}---%d",self.class,self,self.id,self.name, self.city,i++];
}


@end
