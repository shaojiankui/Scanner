//
//  DateManager.h
//  Scanner
//
//  Created by Jakey on 15/8/20.
//  Copyright © 2015年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateManager : NSObject
+ (DateManager *) sharedManager;
#pragma mark-- data to formater string
/**
 *  NSDate 转换 NSString
 *
 *  @param date   待转换NSDate
 *  @param format 待转换NSDate格式 比如yyyy-MM-dd
 *
 *  @return 转换 后的NSString
 */
- (NSString *)stringConvertFromDate:(NSDate *)date format:(NSString *)format;
/**
 *  NSDate 转换 NSString
 *
 *  @param date   待转换NSDate
 *
 *  @return 转换 后的yyyy-MM-dd NSString
 */
+ (NSString *)stringConvert_YMD_FromDate:(NSDate *)date;
/**
 *  NSDate 转换 NSString
 *
 *  @param date   待转换NSDate
 *
 *  @return 转换 后的yyyy-MM-dd HH:mm NSString
 */
+ (NSString *)stringConvert_YMDHM_FromDate:(NSDate *)date;
/**
 *  NSDate 转换 NSString
 *
 *  @param date   待转换NSDate
 *
 *  @return 转换 后的yyyy-MM-dd HH:mm:dd NSString
 */
+ (NSString *)stringConvert_YMDHMD_FromDate:(NSDate *)date;


#pragma mark-- string to formater data
/**
 *  NSString 转换 NSDate
 *
 *  @param string 待转换NSString
 *  @param format 待转换NSDate格式 比如yyyy-MM-dd
 *
 *  @return 转换 后的NSDate
 */

- (NSDate *)dateConvertFromString:(NSString *)string format:(NSString *)format;
/**
 *  NSString 转换 NSDate
 *
 *  @param string 待转换yyyy-MM-dd NSString
 *
 *  @return 转换 后的NSDate
 */
+ (NSDate *)dateConvertFrom_YMD_String:(NSString *)string;
/**
 *  NSString 转换 NSDate
 *
 *  @param string 待转换yyyy-MM-dd HH:mm NSString
 *
 *  @return 转换 后的NSDate
 */
+ (NSDate *)dateConvertFrom_YMDHM_String:(NSString *)string;
/**
 *  NSString 转换 NSDate
 *
 *  @param string 待转换yyyy-MM-dd HH:mm:dd NSString
 *
 *  @return 转换 后的NSDate
 */
+ (NSDate *)dateConvertFrom_YMDHMD_String:(NSString *)string;


#pragma mark-- timeStamp to string date
/**
 *  时间戳根据格式转字符串
 *
 *  @param secs   秒数
 *  @param format 格式
 *
 *  @return 格式后时间字符串
 */
- (NSString *)dateWithTimeIntervalSince1970:(NSTimeInterval)secs format:(NSString *)format;
/**
 *  时间戳根据格式转字符串
 *
 *  @param secs   秒数
 *
 *  @return 格式后时间yyyy-MM-dd字符串
 */
+ (NSString *)date_YMD_WithTimeIntervalSince1970:(NSTimeInterval)secs;
/**
 *  时间戳根据格式转字符串
 *
 *  @param secs   秒数
 *
 *  @return 格式后时间yyyy-MM-dd HH:mm字符串
 */
+ (NSString *)date_YMDHM_WithTimeIntervalSince1970:(NSTimeInterval)secs;
/**
 *  时间戳根据格式转字符串
 *
 *  @param secs   秒数
 *
 *  @return 格式后时间yyyy-MM-dd HH:mm:dd字符串
 */
+ (NSString *)date_YMDHMD_WithTimeIntervalSince1970:(NSTimeInterval)secs;

#pragma mark-- timeStamp
/**
 *  时间转时间戳字符串
 *
 *  @param date NSDate 时间
 *
 *  @return 时间戳字符串
 */
+(NSString *)timeStampStringWithDate:(NSDate*)date;
/**
 *  时间戳转NSDate
 *
 *  @param interval 时间戳
 *
 *  @return 时间NSDate
 */
+ (NSDate*)dateWithTimeStamp:(long long)interval;
/**
 *  时间转时间戳long long
 *
 *  @param date NSDate 时间
 *
 *  @return 时间戳long long
 */
+(long long)timeIntervalWithDate:(NSDate*)date;
/**
 *  当前时间时间戳字符串
 *
 *  @return 当前时间时间戳字符串
 */
+(NSString*)nowTimeStampString;
#pragma mark --

@end
