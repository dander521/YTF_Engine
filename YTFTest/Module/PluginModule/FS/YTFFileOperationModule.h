//
//  YTFFileOperationModule.h
//  YTFFileOperationModule
//
//  Created by apple on 2016/10/20.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTFFileOperationModule : NSObject

#pragma mark - Sync Method

/**
 同步创建目录

 @param paramDictionary JS参数
 */
- (NSDictionary *)createDirectorySync:(NSDictionary *)paramDictionary;

/**
 同步删除目录
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)removeDirectorySync:(NSDictionary *)paramDictionary;

/**
 同步创建文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)createFileSync:(NSDictionary *)paramDictionary;

/**
 同步删除文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)removeFileSync:(NSDictionary *)paramDictionary;

/**
 同步拷贝文件到
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)copyFileToDirSync:(NSDictionary *)paramDictionary;

/**
 同步移动文件到
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)moveFileToDirSync:(NSDictionary *)paramDictionary;

/**
 同步重命名文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)renameFileSync:(NSDictionary *)paramDictionary;

/**
 同步列出目录下内容
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readDirectorySync:(NSDictionary *)paramDictionary;

/**
 同步打开文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)openFileSync:(NSDictionary *)paramDictionary;

/**
 同步读取文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readFileSync:(NSDictionary *)paramDictionary;

/**
 同步当前文件句柄向上读取一页
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readUpFileSync:(NSDictionary *)paramDictionary;

/**
 同步当前文件句柄向下读取一页
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readDownFileSync:(NSDictionary *)paramDictionary;

/**
 同步写入文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)wirteFileSync:(NSDictionary *)paramDictionary;

/**
 同步关闭文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)closeFileSync:(NSDictionary *)paramDictionary;

/**
 同步判断文件是否存在
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)fileExistSync:(NSDictionary *)paramDictionary;

/**
 同步获取文件属性
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)getFileAttributeSync:(NSDictionary *)paramDictionary;

/**
 同步读取文本文件的字符串
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)readTxtFileByLengthSync:(NSDictionary *)paramDictionary;

/**
 同步将字符串写入文本文件
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)writeTxtFileByLengthSync:(NSDictionary *)paramDictionary;

/**
 同步获取文件md5值
 
 @param paramDictionary JS参数
 */
- (NSDictionary *)getFileMD5Sync:(NSDictionary *)paramDictionary;


#pragma mark - Async Method

/**
 异步创建目录
 
 @param paramDictionary JS参数
 */
- (void)createDirectory:(NSDictionary *)paramDictionary;

/**
 异步删除目录
 
 @param paramDictionary JS参数
 */
- (void)removeDirectory:(NSDictionary *)paramDictionary;

/**
 异步创建文件
 
 @param paramDictionary JS参数
 */
- (void)createFile:(NSDictionary *)paramDictionary;

/**
 异步删除文件
 
 @param paramDictionary JS参数
 */
- (void)removeFile:(NSDictionary *)paramDictionary;

/**
 异步拷贝文件到
 
 @param paramDictionary JS参数
 */
- (void)copyFileToDir:(NSDictionary *)paramDictionary;

/**
 异步移动文件到
 
 @param paramDictionary JS参数
 */
- (void)moveFileToDir:(NSDictionary *)paramDictionary;

/**
 异步重命名文件
 
 @param paramDictionary JS参数
 */
- (void)renameFile:(NSDictionary *)paramDictionary;

/**
 异步列出目录下内容
 
 @param paramDictionary JS参数
 */
- (void)readDirectory:(NSDictionary *)paramDictionary;

/**
 异步打开文件
 
 @param paramDictionary JS参数
 */
- (void)openFile:(NSDictionary *)paramDictionary;

/**
 异步读取文件
 
 @param paramDictionary JS参数
 */
- (void)readFile:(NSDictionary *)paramDictionary;

/**
 异步当前文件句柄向上读取一页
 
 @param paramDictionary JS参数
 */
- (void)readUpFile:(NSDictionary *)paramDictionary;

/**
 异步当前文件句柄向下读取一页
 
 @param paramDictionary JS参数
 */
- (void)readDownFile:(NSDictionary *)paramDictionary;

/**
 异步写入文件
 
 @param paramDictionary JS参数
 */
- (void)wirteFile:(NSDictionary *)paramDictionary;

/**
 异步关闭文件
 
 @param paramDictionary JS参数
 */
- (void)closeFile:(NSDictionary *)paramDictionary;

/**
 异步判断文件是否存在
 
 @param paramDictionary JS参数
 */
- (void)fileExist:(NSDictionary *)paramDictionary;

/**
 异步获取文件属性
 
 @param paramDictionary JS参数
 */
- (void)getFileAttribute:(NSDictionary *)paramDictionary;

/**
 异步读取文本文件的字符串
 
 @param paramDictionary JS参数
 */
- (void)readTxtFileByLength:(NSDictionary *)paramDictionary;

/**
 异步将字符串写入文本文件
 
 @param paramDictionary JS参数
 */
- (void)writeTxtFileByLength:(NSDictionary *)paramDictionary;

/**
 异步获取文件md5值
 
 @param paramDictionary JS参数
 */
- (void)getFileMD5:(NSDictionary *)paramDictionary;

@end
