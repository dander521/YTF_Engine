//
//  Macro.h
//  UZApp
//
//  Created by Evyn on 16/10/20.
//  Copyright © 2016年 APICloud. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
#define ScreenHeight        [UIScreen mainScreen].bounds.size.height
#define KNotificationUpDataUI    @"upDataBottomUI"
#define KNotificationPauseOrPaly @"PauseOrPaly"

#ifdef DEBUG

#define DLog(format, ...) NSLog((@"[Function:%s]" format), __FUNCTION__, ##__VA_ARGS__);

#else
# define DLog(...);

#endif

#define LWWeakSelf(type)    __weak typeof(type) weak##type = type;
#define LWStrongSelf(type)  __strong typeof(type) type = weak##type;


#endif /* Macro_h */
