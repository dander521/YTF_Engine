//
//  ButtomViewMethodProtocol.h
//  UZApp
//
//  Created by Evyn on 16/10/20.
//  Copyright © 2016年 APICloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ButtomViewMethodProtocol <NSObject>

- (void)playButtonClick:(UIButton *)sender;
- (void)progressSliderClick:(UISlider *)sender;
- (void)landscapeButtonClick:(UIButton *)sender;

@end
