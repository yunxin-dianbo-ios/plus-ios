//
//  ZBNetworkingTools.h
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZBTools : NSObject
/**
 *  将时间和安全口令转换为加密后的安全词
 *
 *  @param date       加密的时间
 *  @param token      云服务器返回的安全口令
 *  @param lockedWord 加密后的安全词和16进制的加密时间
 */
+ (void)transformDate:(NSDate *)date token:(NSString *)token intoLockedWord:(void(^)(NSString *hextime, NSString *lockedToken))lockedWord;

/**
 *  对时间进行加密
 *
 *  @param date       加密的时间
 *  @param lockedWord 加密后的安全词和16进制的加密时间
 */
+ (void)transformDate:(NSDate *)date intoLockedWord:(void(^)(NSString *hextime, NSString *lockedToken))lockedWord;

/// 通过参数字典生成请求体
+ (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary;

/**
 *  压缩图片,将图片压缩至 500 kb 以下
 *
 *  @param myimage 需要压缩的图片
 *
 *  @return 压缩后的数据包
 */
+ (NSData *)imageData:(UIImage *)myimage;

/**
 *  压缩数据data 为 zlib
 *
 *  @param waitCompressData 需要压缩的数据
 *
 *  @return 压缩后的 zip-data 格式的数据
 */
+ (NSData *)compressDataByZlib:(NSData *)waitCompressData;

/**
 *  解压缩 zip-data 格式的数据为 data 格式
 *
 *  @param zlibData 待解压缩的数据 需要时 zlib 格式的压缩数据
 *
 *  @return 解压缩后的数据
 */
+ (NSData *)decompressZlibData:(NSData *)zlibData;
/**
 *  将字符串转为MD5加密后的字符串
 *
 *  @param string 待加密的字符串
 *
 *  @return 加密后的字符串
 */
+ (NSString *)md5:(NSString *)string;

@end
