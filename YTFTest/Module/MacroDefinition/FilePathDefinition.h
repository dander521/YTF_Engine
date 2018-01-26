/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    FilePath definition.
 * =============================================================================
 */

#ifndef FilePathDefinition_h
#define FilePathDefinition_h

#pragma mark - App System Path

// Documents Path
#define FilePathAppDocuments  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject

// Library Path
#define FilePathAppLibrary  NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject

// Caches Path
#define FilePathAppCaches NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject

// Temp Path
#define FilePathAppTemp NSTemporaryDirectory()

// Resources Path
#define FilePathAppResources [[NSBundle mainBundle] resourcePath]

// Widget Resources Path
#define FilePathAppResourcesWidget  [NSString stringWithFormat:@"%@/assets/widget", FilePathAppResources]


#pragma mark - Custom Path

// FS Path
#define FilePathCustomFS    [NSString stringWithFormat:@"%@/ytffs", FilePathAppDocuments]

// Assets Path
#define FilePathCustomAssets    [NSString stringWithFormat:@"%@/ytf", FilePathAppCaches]

// Widget Path
#define FilePathCustomWidget    [NSString stringWithFormat:@"%@/ytf/widget", FilePathAppCaches]

// Cache Path
#define FilePathCustomCache [NSString stringWithFormat:@"%@/ytf/cache", FilePathAppCaches]

// Download Path
#define FilePathCustomDownload  [NSString stringWithFormat:@"%@/ytf/download", FilePathAppCaches]

// HotFix Path
#define FilePathCustomHotFix    [NSString stringWithFormat:@"%@/ytf/hotfix", FilePathAppCaches]

// Map Path
#define FilePathCustomMap    [NSString stringWithFormat:@"%@/ytf/map", FilePathAppCaches]


#endif /* FilePathDefinition_h */
