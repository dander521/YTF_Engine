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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WebViewParamObject : NSObject

@property (nonatomic, assign) float originX; // x坐标
@property (nonatomic, assign) float originY; // y坐标
@property (nonatomic, assign) float sizeWidth; // 宽度
@property (nonatomic, assign) float sizeHeight; // 高度
@property (nonatomic, assign) float marginTop; // 上内边距
@property (nonatomic, assign) float marginBottom; // 下内边距
@property (nonatomic, assign) float marginLeft; // 左内边距
@property (nonatomic, assign) float marginRight; // 右内边距

/**
 *  配置frame参数
 *
 *  @param frameDictionary
 */
- (CGRect)configWebViewFrameWithDictionary:(NSDictionary *)frameDictionary;

@end
