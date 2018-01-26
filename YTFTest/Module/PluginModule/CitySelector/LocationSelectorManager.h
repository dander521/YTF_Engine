//
//  LocationSelectorManager.h
//  CustomLocationPicker
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 yuantuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolsFunction.h"
#import "AppDelegate.h"

@interface LocationSelectorManager : UIWindow

- (void)open:(NSDictionary *)paramsDictionary;

- (void)close:(NSDictionary *)paramsDictionary;


@end
