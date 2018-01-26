//
//  HeaderCRView.h
//  YTFTest
//
//  Created by apple on 2016/11/16.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderCRViewDelegate <NSObject>

- (void)touchInputButton;

@end

@interface HeaderCRView : UICollectionReusableView

@property (nonatomic, weak) id <HeaderCRViewDelegate> delegate;

@end
