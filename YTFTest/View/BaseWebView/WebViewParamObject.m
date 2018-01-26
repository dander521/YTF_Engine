/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    WebView object.
 * =============================================================================
 */

#import "WebViewParamObject.h"
#import "YTFConfigManager.h"
#import "Definition.h"

@implementation WebViewParamObject

- (instancetype)init
{
    if (self == [super init])
    {
        self.originX = 0;
        self.originY = (![[YTFConfigManager shareConfigManager].statusBarAppearance isEqualToString:@"none"] ? 68 : 40.0);
        self.sizeWidth = ScreenWidth;
        self.sizeHeight = ScreenHeight;
        self.marginTop = 0;
        self.marginBottom = 0;
        self.marginLeft = 0;
        self.marginRight = 0;
    }
    
    return self;
}

/**
 *  配置frame参数
 *
 *  @param frameDictionary
 */
- (CGRect)configWebViewFrameWithDictionary:(NSDictionary *)frameDictionary
{
    self.originX = frameDictionary[@"x"] != nil ? [frameDictionary[@"x"] floatValue] : self.originX;
    self.originY = frameDictionary[@"y"] != nil ? [frameDictionary[@"y"] floatValue] : self.originY;
    self.sizeWidth = frameDictionary[@"w"] != nil ? [frameDictionary[@"w"] floatValue] : self.sizeWidth;
    if (self.sizeWidth == 0)
    {
        self.sizeWidth = 0.01;
    }
    self.sizeHeight = frameDictionary[@"h"] != nil ? [frameDictionary[@"h"] floatValue] : self.sizeHeight;
    
    self.marginTop = frameDictionary[@"marginTop"] != nil ? [frameDictionary[@"marginTop"] floatValue] : self.marginTop;
    self.marginBottom = frameDictionary[@"marginBottom"] != nil ? [frameDictionary[@"marginBottom"] floatValue] : self.marginBottom;
    self.marginRight = frameDictionary[@"marginRight"] != nil ? [frameDictionary[@"marginRight"] floatValue] : self.marginRight;
    self.marginLeft = frameDictionary[@"marginLeft"] != nil ? [frameDictionary[@"marginLeft"] floatValue] : self.marginLeft;

    return CGRectMake(self.originX + self.marginLeft, self.originY + self.marginTop, self.sizeWidth - self.marginLeft - self.marginRight, self.sizeHeight - self.marginTop - self.marginBottom);
}


@end
