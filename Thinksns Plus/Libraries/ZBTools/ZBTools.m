//
//  ZBNetworkingTools.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBTools.h"
#import <zlib.h>
#import <CommonCrypto/CommonDigest.h>

#define CHUNK 16384

@implementation ZBTools

+ (void)transformDate:(NSDate *)date token:(NSString *)token intoLockedWord:(void (^)(NSString *, NSString *))lockedWord {
    NSString *hexTimeString = [self convertDateToHexStr:date];
    NSString *string = [NSString stringWithFormat:@"%d%@", (int)date.timeIntervalSince1970, token];
    NSString *lockString = [self md5:string];
    lockedWord(hexTimeString, lockString);
}

+ (void)transformDate:(NSDate *)date intoLockedWord:(void (^)(NSString *, NSString *))lockedWord {
    NSString *hexTimeString = [self convertDateToHexStr:date];
    NSString *string = [NSString stringWithFormat:@"%d%@", (int)date.timeIntervalSince1970, hexTimeString];
    NSString *lockString = [self md5:string];
    lockedWord(hexTimeString, lockString);
}



+ (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary {
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)percentEscapeString:(NSString *)string {
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)string,(CFStringRef)@" ",(CFStringRef)@":/?@!$&'()*+,;=",kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

// 压缩图片至500k以下
+ (NSData *)imageData:(UIImage *)myimage {
    NSData *data = UIImageJPEGRepresentation(myimage,1);
    if (data.length/1024.0/1024<0.5) {
        //小于0.5M的就算了
        return data;
    }
    data = UIImageJPEGRepresentation(myimage, 1);
    if (data.length/1024.0/1024<0.6) {
        //小于0.5M的就算了
        return data;
    }
    //    //先剪切图片的大小
    float ySize = 1.0;
    if (data.length>2048*1024) {//2M以及以上
        //然后压缩
        ySize *=  0.8;
        data = UIImageJPEGRepresentation(myimage, ySize);
        if (data.length>1024*1024*2) {//>2M
            ySize *=  0.6;
            data = UIImageJPEGRepresentation(myimage, ySize);
        }
        if (data.length>1024*1024) {//>1M
            ySize *=  0.7;
            data = UIImageJPEGRepresentation(myimage, ySize);
        }
        if (data.length>512*1024) {//1-0.5M
            ySize *= 0.8;
            data = UIImageJPEGRepresentation(myimage,ySize);
        }
    }
    if (data.length>1024*1024) {//2-1M
        ySize *= 0.99;
        data = UIImageJPEGRepresentation(myimage, ySize);
    }
    if (data.length>512*1024) {//1-0.5M
        ySize *= 0.995;
        data = UIImageJPEGRepresentation(myimage,ySize);
    }
    if (data.length>(512-20)*1024) {//最后一次压缩
        ySize *= 0.995;
        data = UIImageJPEGRepresentation(myimage, ySize);
    }
    if (data.length>(512-20)*1024) {//最后一次压缩
        ySize *= 0.9;
        data = UIImageJPEGRepresentation(myimage, ySize);
    }
    if (data.length>(512-20)*1024) {//最后一次压缩
        ySize *= 0.8;
        data = UIImageJPEGRepresentation(myimage, ySize);
    }
    if (data.length>(512-20)*1024) {//最后一次压缩
        ySize *= 0.7;
        data = UIImageJPEGRepresentation(myimage, ySize);
    }
    if (data.length>(512-20)*1024) {//最后一次压缩
        ySize *= 0.6;
        data = UIImageJPEGRepresentation(myimage, ySize);
    }
    return data;
}

+ (NSString *)convertDateToHexStr:(NSDate *)date {
    NSString *nLetterValue;
    NSString *str = @"";
    int tmpid = (int)date.timeIntervalSince1970;
    int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig = tmpid % 16;
        tmpid = tmpid / 16;
        switch (ttmpig) {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}

+ (NSString *)md5:(NSString *)string {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    const char *bytes = [string UTF8String];
    CC_MD5(bytes, (CC_LONG)strlen(bytes), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4],
            result[5], result[6], result[7], result[8], result[9],
            result[10], result[11], result[12], result[13], result[14], result[15]];
}

+ (NSData *)compressDataByZlib:(NSData *)waitCompressData {
    int ret, flush;
    unsigned have;
    z_stream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];
    /* allocate deflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    ret = deflateInit(&strm, Z_DEFAULT_COMPRESSION);
    if (ret != Z_OK)
        return nil;
    NSInteger pos = 0;
    NSInteger left = waitCompressData.length;
    //output
    NSMutableData* outData = [NSMutableData data];
    /* compress until end of file */
    do {
        NSInteger len = left > CHUNK ? CHUNK : left;
        [waitCompressData getBytes:in range:NSMakeRange(pos, len)];
        pos += len;
        left -= len;
        
        strm.avail_in = (uInt)len;
        flush = left == 0 ? Z_FINISH : Z_NO_FLUSH;
        strm.next_in = in;
        /* run deflate() on input until output buffer not full, finish
         compression if all of source has been read in */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = deflate(&strm, flush);    /* no bad return value */
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            have = CHUNK - strm.avail_out;
            
            [outData appendBytes:out length:have];
        } while (strm.avail_out == 0);
        assert(strm.avail_in == 0);     /* all input will be used */
        /* done when last data in file processed */
    } while (flush != Z_FINISH);
    assert(ret == Z_STREAM_END);        /* stream will be complete */
    /* clean up and return */
    (void)deflateEnd(&strm);
    
    return [outData copy];
    
}

+ (NSData *)decompressZlibData:(NSData *)zlibData {
    int ret;
    unsigned have;
    z_stream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];
    /* allocate inflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
    ret = inflateInit(&strm);
    if (ret != Z_OK)
        return nil;
    NSInteger pos = 0;
    NSInteger left = zlibData.length;
    NSMutableData* outData = [NSMutableData data];
    /* decompress until deflate stream ends or end of file */
    do {
        NSInteger len = left > CHUNK ? CHUNK : left;
        [zlibData getBytes:in range:NSMakeRange(pos, len)];
        pos += len;
        left -= len;
        
        strm.avail_in = (uInt)len;
        if (strm.avail_in == 0)
            break;
        strm.next_in = in;
        
        /* run inflate() on input until output buffer not full */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = inflate(&strm, Z_NO_FLUSH);
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            switch (ret) {
                case Z_NEED_DICT:
                    ret = Z_DATA_ERROR;     /* and fall through */
                case Z_DATA_ERROR:
                case Z_MEM_ERROR:
                    (void)inflateEnd(&strm);
                    return nil;
            }
            have = CHUNK - strm.avail_out;
            [outData appendBytes:out length:have];
        } while (strm.avail_out == 0);
        
        /* done when inflate() says it's done */
    } while (ret != Z_STREAM_END);
    
    /* clean up and return */
    (void)inflateEnd(&strm);
    
    if (ret == Z_STREAM_END) {
        return [outData copy];
    }
    
    return nil;
}

@end
