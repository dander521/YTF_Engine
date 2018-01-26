/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    LaunchView manager.
 * =============================================================================
 */

#import "YTFAnimationManager.h"

@implementation YTFAnimationManager

// 动画模型单例
+ (instancetype)sharedInstance
{
    static YTFAnimationManager *animationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animationManager = [[self alloc] init];
    });
    
    return animationManager;
}

/**
 *  设置转场动画
 *
 *  @param animationDictionary 转场动画参数
 */
- (void)transitionAnimationWithDictionary:(NSDictionary *)animationDictionary view:(UIView *)view
{
    /*
     {
        type:"movein",                //动画类型（详见动画类型常量）
        subType:"from_left",       //动画子类型（详见动画子类型常量）
        duration:300                //动画过渡时间，默认300毫秒
     }
     */
    // 安卓支持
    NSUInteger animationType = 0;
    NSString *stringSubtype = nil;
    
//    if (!animationDictionary ||
//        (animationDictionary && animationDictionary[@"type"] == nil))
//    {
//        animationType = Push;
//        stringSubtype = kCATransitionFromLeft;
//    }
    
    if ([animationDictionary[@"type"] isEqualToString:@"movein"])
    {
        // 覆盖
        animationType = MoveIn;
    } else if ([animationDictionary[@"type"] isEqualToString:@"zoom"])
    {
        if ([animationDictionary[@"subType"] isEqualToString:@"from_center"])
        {
            // 缩放
            animationType = CameraIrisHollowOpen;
        } else {
            // 缩放
            animationType = CameraIrisHollowClose;
        }
    } else if ([animationDictionary[@"type"] isEqualToString:@"rotate"])
    {
        // 翻转
        animationType = OglFlip;
    } else if ([animationDictionary[@"type"] isEqualToString:@"shade"])
    {
        // 淡入淡出
        animationType = Fade;
    }
    
    if ([animationDictionary[@"subType"] isEqualToString:@"from_left"])
    {
        stringSubtype = kCATransitionFromLeft;
    } else if ([animationDictionary[@"subType"] isEqualToString:@"from_right"])
    {
        stringSubtype = kCATransitionFromRight;
    } else if ([animationDictionary[@"subType"] isEqualToString:@"from_top"])
    {
        stringSubtype = kCATransitionFromTop;
    } else if ([animationDictionary[@"subType"] isEqualToString:@"from_bottom"])
    {
        stringSubtype = kCATransitionFromBottom;
    }
    
    double durition = 0.0f;
    if (animationDictionary[@"duration"])
    {
        durition = [animationDictionary[@"duration"] doubleValue] / 1000.0;
    } else {
        durition = 0.3f;
    }
    
    // iOS额外支持
    if ([animationDictionary[@"type"] isEqualToString:@"push"])
    {
        // 推挤
        animationType = Push;
    } else if ([animationDictionary[@"type"] isEqualToString:@"reveal"])
    {
        // 揭开
        animationType = Reveal;
    } else if ([animationDictionary[@"type"] isEqualToString:@"cube"])
    {
        // 立方体
        animationType = Cube;
    } else if ([animationDictionary[@"type"] isEqualToString:@"suckeffect"])
    {
        // 吸吮
        animationType = SuckEffect;
    } else if ([animationDictionary[@"type"] isEqualToString:@"rippleeffect"])
    {
        // 波纹
        animationType = RippleEffect;
    } else if ([animationDictionary[@"type"] isEqualToString:@"pagecurl"])
    {
        // 翻页
        animationType = PageCurl;
    } else if ([animationDictionary[@"type"] isEqualToString:@"pageuncurl"])
    {
        // 反翻页
        animationType = PageUnCurl;
    }
    
    [self transitionWithAnimationType:animationType subtype:stringSubtype view:view  durition:durition];
}

/**
 *  view 动画
 *
 *  @param animationType    动画类型 AnimationType
 *  @param subtype          动画方向 Common transition subtypes
 *  @param view             动画 view
 */
- (void)transitionWithAnimationType:(NSUInteger)animationType subtype:(NSString *)subtypeString view:(UIView *)view durition:(double)durition
{
    switch (animationType) {
        case Fade:
            [self transitionWithType:kCATransitionFade subtype:subtypeString view:view durition:durition];
            break;
            
        case Push:
            [self transitionWithType:kCATransitionPush subtype:subtypeString view:view durition:durition];
            break;
            
        case Reveal:
            [self transitionWithType:kCATransitionReveal subtype:subtypeString view:view durition:durition];
            break;
            
        case MoveIn:
            [self transitionWithType:kCATransitionMoveIn subtype:subtypeString view:view durition:durition];
            break;
            
        case Cube:
            [self transitionWithType:@"cube" subtype:subtypeString view:view durition:durition];
            break;
            
        case SuckEffect:
            [self transitionWithType:@"suckEffect" subtype:subtypeString view:view durition:durition];
            break;
            
        case OglFlip:
            [self transitionWithType:@"oglFlip" subtype:subtypeString view:view durition:durition];
            break;
            
        case RippleEffect:
            [self transitionWithType:@"rippleEffect" subtype:subtypeString view:view durition:durition];
            break;
            
        case PageCurl:
            [self transitionWithType:@"pageCurl" subtype:subtypeString view:view durition:durition];
            break;
            
        case PageUnCurl:
            [self transitionWithType:@"pageUnCurl" subtype:subtypeString view:view durition:durition];
            break;
            
        case CameraIrisHollowOpen:
            [self transitionWithType:@"cameraIrisHollowOpen" subtype:subtypeString view:view durition:durition];
            break;
            
        case CameraIrisHollowClose:
            [self transitionWithType:@"cameraIrisHollowClose" subtype:subtypeString view:view durition:durition];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIView实现动画

/**
 *  设置UIView动画
 *
 *  @param view       动画 view
 *  @param transition 动画方向
 */
- (void)animationWithView:(UIView *)view animationTransition:(UIViewAnimationTransition)transition
{
//    [UIView animateWithDuration:DURATION animations:^{
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        [UIView setAnimationTransition:transition forView:view cache:YES];
//    }];
}

#pragma mark - CATransition动画实现

/**
 *  view 动画
 *
 *  @param type    动画类型 AnimationType
 *  @param subtype 动画方向 Common transition subtypes
 *  @param view    动画 view
 */
- (void)transitionWithType:(NSString *)type subtype:(NSString *)subtype view:(UIView *)view durition:(double)durition
{
    // 创建CATransition对象
    CATransition *animation = [CATransition animation];
    
    // 设置运动时间
    animation.duration = durition;
    
    // 设置运动type
    animation.type = type;
    if (subtype != nil)
    {
        // 设置子类
        animation.subtype = subtype;
    }
    
    // 设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    [view.layer addAnimation:animation forKey:@"animation"];
}

@end
