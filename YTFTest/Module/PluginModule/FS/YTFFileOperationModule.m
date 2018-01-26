//
//  YTFFileOperationModule.m
//  YTFFileOperationModule
//
//  Created by apple on 2016/10/20.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "YTFFileOperationModule.h"
#include <CommonCrypto/CommonDigest.h>
#import "ToolsFunction.h"
#import "AppDelegate.h"

#define FileHashDefaultChunkSizeForReadingDatas 1024*8

typedef NS_ENUM(NSUInteger, YTFFileErrorCode)
{
    YTFFileErrorCodeFail = 0,               /**< 操作失败 */
    YTFFileErrorCodeNotFound = 1,           /**< 文件/路径不存在 */
    YTFFileErrorCodeUnRead = 2,             /**< 不可读取 */
    YTFFileErrorCodeCodeFormatter = 3,      /**< 编码格式 */
    YTFFileErrorCodeInvalidOperator = 4,    /**< 无效操作 */
    YTFFileErrorCodeInvalidModify = 5,      /**< 无效修改 */
    YTFFileErrorCodeDiskSpill = 6,          /**< 磁盘溢出 */
    YTFFileErrorCodeExist = 7,              /**< 路径／文件已存在 */
    YTFFileErrorCodePath = 8                /**< 无效路径 */
};

typedef NS_ENUM(NSUInteger, YTFFileFlags)
{
    YTFFileFlagsRead = 0,       /**< 可读*/
    YTFFileFlagsWrite = 1,      /**< 可写*/
    YTFFileFlagsReadWrite = 2   /**< 可读可写*/
};

@interface YTFFileOperationModule ()

@property (nonatomic, strong) NSFileHandle *cusFileHandle;
@property (nonatomic, assign) int fileDes;
@property (nonatomic, assign) unsigned long long readLength;

@end

@implementation YTFFileOperationModule

/**
 同步创建目录
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)createDirectorySync:(NSDictionary *)paramDictionary
{
    /*
     path:
     */
    
    NSString *filePath = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
    } else {
        filePath = paramDictionary[@"path"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult =  @{@"status" : [NSNumber numberWithInt:0],
                       @"msg" : @"无效路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];
    
    BOOL isDirectory = false;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory])
    {
        BOOL isCreateSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if (isCreateSuccess)
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:1]};
        } else {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"msg" : @"操作失败"};
        }
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"msg" : @"路径已存在"};
    }
    
    return dicResult;
}

/**
 同步删除目录
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)removeDirectorySync:(NSDictionary *)paramDictionary
{
    /*
     path:
     */
    
    NSString *filePath = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
    } else {
        filePath = paramDictionary[@"path"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];
    
    // 判断是否为文件夹路径
    BOOL isDir = [self judgeFileDirectoryWithPath:filePath];
    
    // 不是文件夹路径
    if (!isDir)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    // 存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir])
    {
        BOOL isRemove = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        if (isRemove)
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:1]};
        } else {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeFail],
                          @"msg" : @"操作失败"};
        }
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeNotFound],
                      @"msg" : @"路径不存在"};
    }
    
    return dicResult;
}

/**
 同步创建文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)createFileSync:(NSDictionary *)paramDictionary
{
    /*
     path:
     */
    
    NSString *filePath = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
    } else {
        filePath = paramDictionary[@"path"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        BOOL isCreatSuccess = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        if (isCreatSuccess)
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:1]};
        } else {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeFail],
                          @"msg" : @"操作失败"};
        }
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeExist],
                      @"msg" : @"文件已存在"};
    }
    
    return dicResult;
}

/**
 同步删除文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)removeFileSync:(NSDictionary *)paramDictionary
{
    /*
     path:
     */
    
    NSString *filePath = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
    } else {
        filePath = paramDictionary[@"path"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];
    
    // 判断是否为文件路径
    BOOL isDir = [self judgeFileDirectoryWithPath:filePath];
    
    // 不是文件路径
    if (isDir)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效文件路径"};
        return dicResult;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        BOOL isRemove = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        if (isRemove)
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:1]};
        } else {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeFail],
                          @"msg" : @"操作失败"};
        }
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeNotFound],
                      @"msg" : @"文件不存在"};
    }
    
    return dicResult;
}

/**
 同步拷贝文件到文件夹
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)copyFileToDirSync:(NSDictionary *)paramDictionary
{
    /*
     oldPath: fs://text.txt
     newPath: fs://folder
     */
    
    NSString *oldPath = nil;
    NSString *newPath = nil;
    
    if (paramDictionary[@"args"])
    {
        oldPath = paramDictionary[@"args"][@"oldPath"];
        newPath = paramDictionary[@"args"][@"newPath"];
    } else {
        oldPath = paramDictionary[@"oldPath"];
        newPath = paramDictionary[@"newPath"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (oldPath == nil || newPath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    oldPath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:oldPath];
    newPath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:newPath];

    // 校验原始文件 是否为文件 文件是否存在
    BOOL isDir = [self judgeFileDirectoryWithPath:oldPath];
    
    // 不是文件路径
    if (isDir)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效文件路径"};
        return dicResult;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldPath])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeNotFound],
                      @"msg" : @"文件不存在"};
        return dicResult;
    }
    
    // 校验目标文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", newPath, [oldPath lastPathComponent]]])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeExist],
                      @"msg" : @"文件已存在"};
        return dicResult;
    }
    
    // 校验目标文件夹是否存在 不存在创建
    BOOL isDir1;
    if (![[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:&isDir1])
    {
        BOOL isCreateSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if (!isCreateSuccess)
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeFail],
                          @"msg" : @"操作失败"};
        }
    }
    
    // copy
    NSString *destinationPath = [NSString stringWithFormat:@"%@/%@", newPath, [oldPath lastPathComponent]];
    
    NSError *error;
    BOOL isCopy = [[NSFileManager defaultManager] copyItemAtPath:oldPath toPath:destinationPath error:&error];
    
    if (isCopy)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1]};
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeFail],
                      @"msg" : @"操作失败"};
    }
    
    return dicResult;
}

/**
 同步移动文件到
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)moveFileToDirSync:(NSDictionary *)paramDictionary
{
    /*
     oldPath: fs://text.txt
     newPath: fs://folder
     */
    
    NSString *oldPath = nil;
    NSString *newPath = nil;
    
    if (paramDictionary[@"args"])
    {
        oldPath = paramDictionary[@"args"][@"oldPath"];
        newPath = paramDictionary[@"args"][@"newPath"];
    } else {
        oldPath = paramDictionary[@"oldPath"];
        newPath = paramDictionary[@"newPath"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (oldPath == nil || newPath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    oldPath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:oldPath];
    newPath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:newPath];

    // 校验原始文件 是否为文件 文件是否存在
    BOOL isDir = [self judgeFileDirectoryWithPath:oldPath];
    
    // 不是文件路径
    if (isDir)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效文件路径"};
        return dicResult;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldPath])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeNotFound],
                      @"msg" : @"文件不存在"};
        return dicResult;
    }
    
    // 校验目标文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", newPath, [oldPath lastPathComponent]]])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeExist],
                      @"msg" : @"文件已存在"};
        return dicResult;
    }
    
    // 校验目标文件夹是否存在 不存在创建
    BOOL isDir1;
    if (![[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:&isDir1])
    {
        BOOL isCreateSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if (!isCreateSuccess)
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeFail],
                          @"msg" : @"操作失败"};
        }
    }
    
    // move
    NSString *destinationPath = [NSString stringWithFormat:@"%@/%@", newPath, [oldPath lastPathComponent]];
    
    NSError *error;
    BOOL isCopy = [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:destinationPath error:&error];
    
    if (isCopy)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1]};
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeFail],
                      @"msg" : @"操作失败"};
    }
    
    return dicResult;
}

/**
 同步重命名文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)renameFileSync:(NSDictionary *)paramDictionary
{
    /*
     oldPath: fs://text.txt
     newPath: fs://rename.txt
     */
    
    NSString *oldPath = nil;
    NSString *newPath = nil;
    
    if (paramDictionary[@"args"])
    {
        oldPath = paramDictionary[@"args"][@"oldPath"];
        newPath = paramDictionary[@"args"][@"newPath"];
    } else {
        oldPath = paramDictionary[@"oldPath"];
        newPath = paramDictionary[@"newPath"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (oldPath == nil || newPath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    oldPath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:oldPath];
    newPath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:newPath];

    // 校验原始文件 是否为文件 文件是否存在
    BOOL isDir = [self judgeFileDirectoryWithPath:oldPath];
    
    // 不是文件路径
    if (isDir)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效文件路径"};
        return dicResult;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldPath])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeNotFound],
                      @"msg" : @"文件不存在"};
        return dicResult;
    }
    
    // 校验目标文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:newPath])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeExist],
                      @"msg" : @"文件已存在"};
        return dicResult;
    }
    
    // 校验目标文件夹是否存在 不存在创建
    BOOL isDir1;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[newPath stringByDeletingLastPathComponent] isDirectory:&isDir1])
    {
        BOOL isCreateSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if (!isCreateSuccess)
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeFail],
                          @"msg" : @"操作失败"};
        }
    }
    
    // rename
    NSError *error;
    BOOL isCopy = [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    
    if (isCopy)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1]};
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeFail],
                      @"msg" : @"操作失败"};
    }
    
    return dicResult;
}

/**
 同步列出目录下内容
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readDirectorySync:(NSDictionary *)paramDictionary
{
    /*
     path:
     */
    
    NSString *filePath = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
    } else {
        filePath = paramDictionary[@"path"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];
    
    BOOL isDir;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    if (!isExist)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeNotFound],
                      @"msg" : @"文件／路径不存在"};
        return dicResult;
    } else {
        NSArray *arrayData = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
        dicResult = @{@"status" : [NSNumber numberWithInt:1],
                      @"data" : arrayData};
    }
    
    return dicResult;
}

/**
 同步打开文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)openFileSync:(NSDictionary *)paramDictionary
{
    /*
     path:
     flags: 0 1 2
     */
    
    if (_cusFileHandle)
    {
        [_cusFileHandle closeFile];
        _cusFileHandle = nil;
        _fileDes = 0;
    }
    
    NSString *filePath = nil;
    int flags = 0;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
        flags = paramDictionary[@"args"][@"flags"] == nil ? 0 : [paramDictionary[@"args"][@"flags"] intValue];
    } else {
        filePath = paramDictionary[@"path"];
        flags = paramDictionary[@"flags"] == nil ? 0 : [paramDictionary[@"flags"] intValue];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];
    
    // 是否为文件
    BOOL isDir = [self judgeFileDirectoryWithPath:filePath];
    // 不是文件路径
    if (isDir)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效文件路径"};
        return dicResult;
    }
    
    // 文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeNotFound],
                      @"msg" : @"文件／路径不存在"};
        return dicResult;
    }
    
    switch (flags)
    {
        case 0:
        {
            _cusFileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        }
            break;
            
        case 1:
        {
            _cusFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        }
            break;
            
        case 2:
        {
            _cusFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        }
            break;
            
        default:
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeInvalidOperator],
                          @"msg" : @"无效操作"};
            return dicResult;
        }
            break;
    }

    _fileDes = _cusFileHandle.fileDescriptor;
    
    if (_cusFileHandle)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1],
                      @"fd" : [NSString stringWithFormat:@"%d", _fileDes]};
        
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail],
                      @"msg" : @"打开文件失败"};
    }
    
    return dicResult;
}

/**
 同步读取文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readFileSync:(NSDictionary *)paramDictionary
{
    /*
     fd:
     offset:
     length:
     codingType:
     */
    
    NSString *fileDes = nil;
    NSString *fileOffset = nil;
    NSString *fileLength = nil;
    NSString *fileCodingType = nil;
    
    if (paramDictionary[@"args"])
    {
        fileDes = paramDictionary[@"args"][@"fd"];
        fileOffset = paramDictionary[@"args"][@"offset"];
        fileLength = paramDictionary[@"args"][@"length"];
        fileCodingType = paramDictionary[@"args"][@"codingType"];
    } else {
        fileDes = paramDictionary[@"fd"];
        fileOffset = paramDictionary[@"offset"];
        fileLength = paramDictionary[@"length"];
        fileCodingType = paramDictionary[@"codingType"];
    }
    
    NSDictionary *dicResult = nil;
    if (fileDes == nil || _fileDes != [fileDes intValue])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeInvalidOperator],
                      @"msg" : @"文件未打开"};
        return dicResult;
    }
    
    unsigned long long allLength = [[_cusFileHandle availableData] length];
    unsigned long long length = fileLength == nil ? allLength : [fileLength intValue];
    unsigned long long offset = fileOffset == nil ? 0 : [fileOffset intValue];
    NSString *codeType = fileCodingType == nil ? @"uft8" : fileCodingType;
    
    if (offset > allLength)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeInvalidOperator],
                      @"msg" : @"offset大于文件最大长度"};
        return dicResult;
    }
    
    if (!_readLength)
    {
        _readLength = length;
    }
    
    [_cusFileHandle seekToFileOffset:offset];
    
    NSData *data = [_cusFileHandle readDataOfLength:(NSUInteger)length];
    NSString *stringResult = nil;
    if ([codeType isEqualToString:@"utf8"])
    {
        stringResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else if ([codeType isEqualToString:@"gbk"]) {
        NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        stringResult = [[NSString alloc] initWithData:data encoding:enc];
    }
    
    stringResult = stringResult == nil ? @"" : stringResult;

    if (_cusFileHandle)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1],
                      @"data" : stringResult};
    } else if (!_cusFileHandle)
    {
        dicResult = @{@"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail],
                      @"msg" : @"打开文件失败"};
    }
    
    return dicResult;
}

/**
 同步当前文件句柄向上读取一页
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readUpFileSync:(NSDictionary *)paramDictionary
{
    /*
     fd:
     length:
     codingType:
     */
    
    NSString *fileDes = nil;
    NSString *fileLength = nil;
    NSString *fileCodingType = nil;
    
    if (paramDictionary[@"args"])
    {
        fileDes = paramDictionary[@"args"][@"fd"];
        fileLength = paramDictionary[@"args"][@"length"];
        fileCodingType = paramDictionary[@"args"][@"codingType"];
    } else {
        fileDes = paramDictionary[@"fd"];
        fileLength = paramDictionary[@"length"];
        fileCodingType = paramDictionary[@"codingType"];
    }
    
    NSDictionary *dicResult = nil;
    if (fileDes == nil || _fileDes != [fileDes intValue])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeInvalidOperator],
                      @"msg" : @"文件未打开"};
        return dicResult;
    }
    
    unsigned long long length = [fileLength longLongValue];
    NSString *codeType = fileCodingType == nil ? @"uft8" : fileCodingType;
    
    if (fileLength == nil && _readLength)
    {
        length = _readLength;
    } else {
        _readLength = length;
    }
    
    unsigned long long currentOffset = [_cusFileHandle offsetInFile];
    unsigned long long readUpOffset = currentOffset > 2*length ? currentOffset - 2*length : 0;
    
    [_cusFileHandle seekToFileOffset:readUpOffset];
    
    NSData *data = [_cusFileHandle readDataOfLength:(NSUInteger)length];
    
    NSString *stringResult = nil;
    if ([codeType isEqualToString:@"utf8"])
    {
        stringResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else if ([codeType isEqualToString:@"gbk"]) {
        NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        stringResult = [[NSString alloc] initWithData:data encoding:enc];
    }
    
    stringResult = stringResult == nil ? @"" : stringResult;
    
    if (_cusFileHandle)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1],
                      @"data" : stringResult};
    } else if (!_cusFileHandle)
    {
        dicResult = @{@"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail],
                      @"msg" : @"打开文件失败"};
    }
    
    return dicResult;
}

/**
 同步当前文件句柄向下读取一页
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readDownFileSync:(NSDictionary *)paramDictionary
{
    /*
     fd:
     length:
     codingType:
     */
    
    NSString *fileDes = nil;
    NSString *fileLength = nil;
    NSString *fileCodingType = nil;
    
    if (paramDictionary[@"args"])
    {
        fileDes = paramDictionary[@"args"][@"fd"];
        fileLength = paramDictionary[@"args"][@"length"];
        fileCodingType = paramDictionary[@"args"][@"codingType"];
    } else {
        fileDes = paramDictionary[@"fd"];
        fileLength = paramDictionary[@"length"];
        fileCodingType = paramDictionary[@"codingType"];
    }
    
    NSDictionary *dicResult = nil;
    if (fileDes == nil || _fileDes != [fileDes intValue])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeInvalidOperator],
                      @"msg" : @"文件未打开"};
        return dicResult;
    }
    
    NSString *codeType = fileCodingType == nil ? @"uft8" : fileCodingType;
    unsigned long long length = [fileLength longLongValue];
    if (fileLength == nil && _readLength)
    {
        length = _readLength;
    } else {
        _readLength = length;
    }
    
    NSData *data = [_cusFileHandle readDataOfLength:(NSUInteger)length];
    NSString *stringResult = nil;
    if ([codeType isEqualToString:@"utf8"])
    {
        stringResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else if ([codeType isEqualToString:@"gbk"]) {
        NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        stringResult = [[NSString alloc] initWithData:data encoding:enc];
    }
    
    stringResult = stringResult == nil ? @"" : stringResult;
    
    if (_cusFileHandle)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1],
                      @"data" : stringResult};
    } else if (!_cusFileHandle)
    {
        dicResult = @{@"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail],
                      @"msg" : @"打开文件失败"};
    }
    
    return dicResult;
}

/**
 同步写入文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)wirteFileSync:(NSDictionary *)paramDictionary
{
    /*
     fd
     data
     offset
     overwrite
     codingType
     */
    
    NSString *fileDes = nil;
    NSString *fileData = nil;
    NSString *fileOffset = nil;
    NSString *fileOverwrite = nil;
    NSString *fileCodingType = nil;
    
    if (paramDictionary[@"args"])
    {
        fileDes = paramDictionary[@"args"][@"fd"];
        fileData = paramDictionary[@"args"][@"data"];
        fileOffset = paramDictionary[@"args"][@"offset"];
        fileOverwrite = paramDictionary[@"args"][@"overwrite"];
        fileCodingType = paramDictionary[@"args"][@"codingType"];
    } else {
        fileDes = paramDictionary[@"fd"];
        fileData = paramDictionary[@"data"];
        fileOffset = paramDictionary[@"offset"];
        fileOverwrite = paramDictionary[@"overwrite"];
        fileCodingType = paramDictionary[@"codingType"];
    }
    
    NSDictionary *dicResult = nil;
    if (fileDes == nil || _fileDes != [fileDes intValue] || fileData == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeInvalidOperator],
                      @"msg" : @"文件未打开"};
        return dicResult;
    }
    
    // 文件总长
    unsigned long long allBytes = [[_cusFileHandle availableData] length];
    
    NSString *dataString = fileData;
    BOOL overwrite = fileOverwrite == nil ? false : [fileOverwrite boolValue];
    unsigned long long offset = fileOffset == nil ? allBytes : [fileOffset longLongValue];
    if ([fileOffset longLongValue] > allBytes)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeInvalidOperator],
                      @"msg" : @"offset大于文件最大长度"};
        return dicResult;
    }
    NSString *codeType = fileCodingType == nil ? @"uft8" :fileCodingType;
    
    NSData *data = nil;
    if ([codeType isEqualToString:@"utf8"])
    {
        data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([codeType isEqualToString:@"gbk"]) {
        NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        data = [dataString dataUsingEncoding:enc];
    }
    
    if (_cusFileHandle)
    {
        // 内容追加
        if (fileOffset == nil || offset == allBytes)
        {
            [_cusFileHandle seekToEndOfFile];
            [_cusFileHandle writeData:data];
        } else if (fileOffset != nil && overwrite == true)
        {
            // 内容覆盖
            [_cusFileHandle truncateFileAtOffset:offset];
            [_cusFileHandle seekToFileOffset:offset];
            [_cusFileHandle writeData:data];
        } else if (fileOffset != nil && overwrite == false)
        {
            // 插入位置后的data
            [_cusFileHandle seekToFileOffset:offset];
            NSData *dataSuf = [_cusFileHandle readDataToEndOfFile];
            
            // 内容截取
            [_cusFileHandle truncateFileAtOffset:offset];
            
            [_cusFileHandle writeData:data];
            [_cusFileHandle writeData:dataSuf];
        }
        dicResult = @{@"status" : [NSNumber numberWithInt:1]};
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail],
                      @"msg" : @"打开文件失败"};
    }
    
    return dicResult;
}

/**
 同步关闭文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)closeFileSync:(NSDictionary *)paramDictionary
{
    /*
     fd
     */
    
    NSString *fileDes = nil;
    
    if (paramDictionary[@"args"])
    {
        fileDes = paramDictionary[@"args"][@"fd"];
    } else {
        fileDes = paramDictionary[@"fd"];
    }
    
    NSDictionary *dicResult = nil;
    if (fileDes == nil || _fileDes != [fileDes intValue])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeInvalidOperator],
                      @"msg" : @"文件未打开"};
        return dicResult;
    }
    
    if (_cusFileHandle)
    {
        [_cusFileHandle closeFile];
        _cusFileHandle = nil;
        _fileDes = 0;
        dicResult = @{@"status" : [NSNumber numberWithInt:1]};
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail],
                      @"msg" : @"获取文件失败"};
    }
    
    return dicResult;
}

/**
 同步判断文件是否存在
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)fileExistSync:(NSDictionary *)paramDictionary
{
    /*
     path:
     */
    
    NSString *filePath = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
    } else {
        filePath = paramDictionary[@"path"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径／文件路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];
    
    BOOL isDir = false;
    BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    // 文件夹
    if(isDir && isDirExist)
    {
        dicResult = @{@"exist" : [NSNumber numberWithInt:1],
                      @"dir" : [NSNumber numberWithInt:1]};
    } else if(isDirExist)
    {
        // 文件
        dicResult = @{@"exist" : [NSNumber numberWithInt:1],
                      @"dir" : [NSNumber numberWithInt:0]};
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径／文件路径"};
    }
    
    return dicResult;
}

/**
 同步获取文件属性
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)getFileAttributeSync:(NSDictionary *)paramDictionary
{
    /*
     path:
     */
    
    NSString *filePath = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
    } else {
        filePath = paramDictionary[@"path"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径／文件路径"};
        
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];
    
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    
    if (fileAttributes != nil) {
        // 文件类型
        NSString *fileType = [fileAttributes objectForKey:NSFileType];
        if ([fileType isEqualToString:@"NSFileTypeDirectory"])
        {
            fileType = @"文件夹";
        } else {
            fileType = @"文件";
        }
        // 文件大小
        NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
        // 修改时间
        NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
        // 创建时间
        NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];

        
        dicResult = @{@"status" : [NSNumber numberWithInt:1],
                      @"attribute" : @{@"size" : [NSString stringWithFormat:@"%@bytes", fileSize],
                                       @"type" : fileType,
                                       @"creationDate" : [self dateToString:fileCreateDate],
                                       @"modificationDate" : [self dateToString:fileModDate]}};
    }
    else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径／文件路径"};
    }
    
    return dicResult;
}

/**
 同步读取文本文件的字符串
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readTxtFileByLengthSync:(NSDictionary *)paramDictionary
{
    /*
     path
     substring
     */
    
    NSString *filePath = nil;
    NSDictionary *subStringDictionary = nil;
    NSString *fileStartIndex = nil;
    NSString *fileLenght = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
        subStringDictionary = paramDictionary[@"args"][@"substring"];
        fileStartIndex = subStringDictionary[@"start"];
        fileLenght = subStringDictionary[@"length"];
    } else {
        filePath = paramDictionary[@"path"];
        subStringDictionary = paramDictionary[@"substring"];
        fileStartIndex = subStringDictionary[@"start"];
        fileLenght = subStringDictionary[@"length"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];

    BOOL isExist = [self isFileExistAtPath:filePath];
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    
    if (isExist)
    {
        if (!subStringDictionary)
        {
            fileString = fileString == nil ? @"" : fileString;
            
            dicResult = @{@"status" : [NSNumber numberWithInt:1],
                          @"content" : fileString,
                          @"codingType" : @"utf8"};
        } else
        {
            NSUInteger startIndex = fileStartIndex ? [fileStartIndex intValue] : 0;
            
            if (startIndex > [fileString length])
            {
                dicResult = @{@"status" : [NSNumber numberWithInt:0],
                              @"msg" : @"起始索引大于文件长度",
                              @"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail]};
                return dicResult;
            }
            
            NSUInteger length = fileLenght ? [fileLenght intValue] : [fileString length];
            length = length > ([fileString length] - startIndex) ? ([fileString length] - startIndex) : length;
            
            NSString *subString = [fileString substringWithRange:NSMakeRange(startIndex, length)];
            
            subString = subString == nil ? @"" : subString;
            
            dicResult = @{@"status" : [NSNumber numberWithInt:1],
                          @"content" : subString,
                          @"codingType" : @"utf8"};
        }
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:YTFFileErrorCodeFail],
                      @"msg" : @"文件路径不可用",
                      @"code" : [NSNumber numberWithInt:0]};
    }
    
    return dicResult;
}

/**
 同步将字符串写入文本文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)writeTxtFileByLengthSync:(NSDictionary *)paramDictionary
{
    /*
     path
     content
     place
     codingType
     */
    
    NSString *filePath = nil;
    NSString *fileContent = nil;
    NSDictionary *subStringDictionary = nil;
    NSString *fileStartIndex = nil;
    NSString *fileLenght = nil;
    NSString *fileCodingType = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
        fileContent = paramDictionary[@"args"][@"content"];
        subStringDictionary = paramDictionary[@"args"][@"place"];
        fileStartIndex = subStringDictionary[@"start"];
        fileLenght = subStringDictionary[@"strategy"];
        fileCodingType = paramDictionary[@"args"][@"codingType"];
    } else {
        filePath = paramDictionary[@"path"];
        fileContent = paramDictionary[@"content"];
        subStringDictionary = paramDictionary[@"place"];
        fileStartIndex = subStringDictionary[@"start"];
        fileLenght = subStringDictionary[@"strategy"];
        fileCodingType = paramDictionary[@"codingType"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil || fileContent == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];
    
    NSString *content = fileContent;
    NSString *codeType = fileCodingType == nil ? @"uft8" : fileCodingType;
    NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    if ([codeType isEqualToString:@"utf8"])
    {
        enc = NSUTF8StringEncoding;
    } else if ([codeType isEqualToString:@"gbk"]) {
        
        enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    }
    
    BOOL isExist = [self isFileExistAtPath:filePath];
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSMutableString *fileString = [[NSMutableString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    
    NSData *contentData = nil;
    if (isExist)
    {
        if (!subStringDictionary)
        {
            contentData = [content dataUsingEncoding:enc];
        } else
        {
            NSUInteger startIndex = fileStartIndex != nil ? [fileStartIndex intValue] : 0;
            
            if (startIndex > [fileString length])
            {
                dicResult = @{@"status" : [NSNumber numberWithInt:0],
                              @"msg" : @"起始索引大于文件长度",
                              @"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail]};
                return dicResult;
            }
            
            NSInteger length = fileLenght != nil ? [fileLenght intValue] : -1;
            
            // 覆盖起始位置后所有
            if (length == -1 && startIndex == 0)
            {
                contentData = [content dataUsingEncoding:enc];
            }
            
            if ([fileData length] == 0)
            {
                dicResult = @{@"status" : [NSNumber numberWithInt:0],
                              @"msg" : @"文件为空",
                              @"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail]};
                return dicResult;
            }
            
            if (length == -1 && startIndex != 0)
            {
                // 覆盖指定位置后所有
                NSString *subString = [fileString substringToIndex:startIndex];
                NSString *resultString = [NSString stringWithFormat:@"%@%@", subString, content];
                contentData = [resultString dataUsingEncoding:enc];
            } else if (length == 0)
            {
                // 不覆盖 插入
                startIndex = startIndex > [fileString length] ? [fileString length] : startIndex;
                [fileString insertString:content atIndex:startIndex];
                contentData = [fileString dataUsingEncoding:enc];
            } else {
                // 大于零的整数 (起始位置向后覆盖指定字符的长度)
                length = length > ([fileString length] - startIndex) ? ([fileString length] - startIndex) : length;
                [fileString replaceCharactersInRange:NSMakeRange(startIndex, length) withString:content];
                contentData = [fileString dataUsingEncoding:enc];
            }
        }
        
        BOOL isWrite = [contentData writeToFile:filePath atomically:false];
        if (isWrite)
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:1]};
        } else {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"msg" : @"写入文件失败",
                          @"code" : [NSNumber numberWithInt:YTFFileErrorCodeFail]};
        }
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"msg" : @"文件路径不可用",
                      @"code" : [NSNumber numberWithInt:YTFFileErrorCodeNotFound]};
    }
    
    return dicResult;
}

/**
 同步获取文件md5值
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)getFileMD5Sync:(NSDictionary *)paramDictionary
{
    /*
     path:
     */
    
    NSString *filePath = nil;
    
    if (paramDictionary[@"args"])
    {
        filePath = paramDictionary[@"args"][@"path"];
    } else {
        filePath = paramDictionary[@"path"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (filePath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodePath],
                      @"msg" : @"无效路径／文件路径"};
        return dicResult;
    }
    
    filePath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:filePath];
    
    NSString *stringMD5 = (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)filePath, FileHashDefaultChunkSizeForReadingDatas);
    if (stringMD5)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1],
                      @"md5Str" : stringMD5};
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"code" : [NSNumber numberWithInteger:YTFFileErrorCodeInvalidOperator],
                      @"msg" : @"无效操作"};
    }
    
    return dicResult;
}

#pragma mark - Async Method

/**
 异步创建目录
 
 @param paramDictionary JS参数
 */
- (void)createDirectory:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path:
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self createDirectorySync:paramDictionary]]];
}

/**
 异步删除目录
 
 @param paramDictionary JS参数
 */
- (void)removeDirectory:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path:
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self removeDirectorySync:paramDictionary]]];
}

/**
 异步创建文件
 
 @param paramDictionary JS参数
 */
- (void)createFile:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path:
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self createFileSync:paramDictionary]]];
}

/**
 异步删除文件
 
 @param paramDictionary JS参数
 */
- (void)removeFile:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path:
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self removeFileSync:paramDictionary]]];
}

/**
 异步拷贝文件到
 
 @param paramDictionary JS参数
 */
- (void)copyFileToDir:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     oldPath: fs://text.txt
     newPath: fs://folder
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self copyFileToDirSync:paramDictionary]]];
}

/**
 异步移动文件到
 
 @param paramDictionary JS参数
 */
- (void)moveFileToDir:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     oldPath: fs://text.txt
     newPath: fs://folder
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self moveFileToDirSync:paramDictionary]]];
}

/**
 异步重命名文件
 
 @param paramDictionary JS参数
 */
- (void)renameFile:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     oldPath: fs://text.txt
     newPath: fs://rename.txt
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self renameFileSync:paramDictionary]]];
}

/**
 异步列出目录下内容
 
 @param paramDictionary JS参数
 */
- (void)readDirectory:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path:
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self readDirectorySync:paramDictionary]]];
}

/**
 异步打开文件
 
 @param paramDictionary JS参数
 */
- (void)openFile:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path:
     flags: 0 1 2
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self openFileSync:paramDictionary]]];
}

/**
 异步读取文件
 
 @param paramDictionary JS参数
 */
- (void)readFile:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     fd:
     offset:
     length:
     codingType:
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self readFileSync:paramDictionary]]];
}

/**
 异步当前文件句柄向上读取一页
 
 @param paramDictionary JS参数
 */
- (void)readUpFile:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     fd:
     length:
     codingType:
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self readUpFileSync:paramDictionary]]];
}

/**
 异步当前文件句柄向下读取一页
 
 @param paramDictionary JS参数
 */
- (void)readDownFile:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     fd:
     length:
     codingType:
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self readDownFileSync:paramDictionary]]];
}

/**
 异步写入文件
 
 @param paramDictionary JS参数
 */
- (void)wirteFile:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     fd
     data
     offset
     overwrite
     codingType
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self wirteFileSync:paramDictionary]]];
}

/**
 异步关闭文件
 
 @param paramDictionary JS参数
 */
- (void)closeFile:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     fd
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self closeFileSync:paramDictionary]]];
}

/**
 异步判断文件是否存在
 
 @param paramDictionary JS参数
 */
- (void)fileExist:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path:
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self fileExistSync:paramDictionary]]];
}

/**
 异步获取文件属性
 
 @param paramDictionary JS参数
 */
- (void)getFileAttribute:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path:
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self getFileAttributeSync:paramDictionary]]];
}

/**
 异步读取文本文件的字符串
 
 @param paramDictionary JS参数
 */
- (void)readTxtFileByLength:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path
     substring
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self readTxtFileByLengthSync:paramDictionary]]];
}

/**
 异步将字符串写入文本文件
 
 @param paramDictionary JS参数
 */
- (void)writeTxtFileByLength:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path
     content
     place
     codingType
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self writeTxtFileByLengthSync:paramDictionary]]];
}

/**
 异步获取文件md5值
 
 @param paramDictionary JS参数
 */
- (void)getFileMD5:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     path:
     */
    
    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self getFileMD5Sync:paramDictionary]]];
}

#pragma mark - Custom Method

- (void)evaluatingWithJSParam:(NSDictionary *)paramDictionary resultString:(NSString *)jsonString
{
    [paramDictionary[@"target"] stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", paramDictionary[@"cbId"], jsonString,jsonString]];
}

- (NSString*)getMD5:(NSString *)path
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingDatas);
}


CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingDatas;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

// 判断文件夹
- (BOOL)judgeFileDirectoryWithPath:(NSString *)path
{
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    return isDirectory;
}

// 创建文件夹
- (BOOL)createDirectoryWithPath:(NSString *)path
{
    BOOL isCreateSuccess = false;
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        isCreateSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        isCreateSuccess = true;
    }
    
    return isCreateSuccess;
}

// 判断文件是否存在
- (BOOL)isFileExistAtPath:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (NSString *)dateToString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    return strDate;
}

- (NSDate *)stringToDate:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}

@end
