//
//  DateManager.m
//  Scanner
//
//  Created by Jakey on 15/8/20.
//  Copyright © 2015年 www.skyfox.org. All rights reserved.
//
#define FORMATER_YYMMDD
#import "DateManager.h"
@interface DateManager ()
@property (nonatomic, strong) NSDateFormatter *dateForrmatter;
@end
@implementation DateManager
+ (DateManager *) sharedManager
{
    static DateManager *dateManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateManager = [[self alloc] init];
    });
    return dateManager;
}
- (id)init
{
    self = [super init];
    if (self) {
        _dateForrmatter = [[NSDateFormatter alloc] init];
        [_dateForrmatter setLocale:[NSLocale currentLocale]];
        [_dateForrmatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return self;
}
#pragma mark--
/**
 *  NSDate 转换 NSString
 *
 *  @param date   待转换NSDate
 *  @param format 待转换NSDate格式 比如yyyy-MM-dd
 *
 *  @return 转换 后的NSString
 */
- (NSString *)stringConvertFromDate:(NSDate *)date format:(NSString *)format
{
    [_dateForrmatter setDateFormat:format];
    NSString *dateString = [_dateForrmatter stringFromDate:date];
    return dateString;
}
/**
 *  NSDate 转换 NSString
 *
 *  @param date   待转换NSDate
 *
 *  @return 转换 后的yyyy-MM-dd NSString
 */
+ (NSString *)stringConvert_YMD_FromDate:(NSDate *)date{
    return [[DateManager sharedManager] stringConvertFromDate:date format:@"yyyy-MM-dd"];
}
/**
 *  NSDate 转换 NSString
 *
 *  @param date   待转换NSDate
 *
 *  @return 转换 后的yyyy-MM-dd HH:mm NSString
 */
+ (NSString *)stringConvert_YMDHM_FromDate:(NSDate *)date{
    return [[DateManager sharedManager] stringConvertFromDate:date format:@"yyyy-MM-dd HH:mm"];

}
/**
 *  NSDate 转换 NSString
 *
 *  @param date   待转换NSDate
 *
 *  @return 转换 后的yyyy-MM-dd HH:mm:dd NSString
 */
+ (NSString *)stringConvert_YMDHMD_FromDate:(NSDate *)date{
    return [[DateManager sharedManager] stringConvertFromDate:date format:@"yyyy-MM-dd HH:mm:dd"];

}
#pragma mark-- string to formater data

/**
 *  NSString 转换 NSDate
 *
 *  @param string 待转换NSString
 *  @param format 待转换NSDate格式 比如yyyy-MM-dd
 *
 *  @return 转换 后的NSDate
 */
- (NSDate *)dateConvertFromString:(NSString *)string format:(NSString *)format
{
    [_dateForrmatter setDateFormat:format];
    NSDate *date = [_dateForrmatter dateFromString:string];
    return date;
}
/**
 *  NSString 转换 NSDate
 *
 *  @param string 待转换yyyy-MM-dd NSString
 *
 *  @return 转换 后的NSDate
 */
+ (NSDate *)dateConvertFrom_YMD_String:(NSString *)string{
    return [[DateManager sharedManager] dateConvertFromString:string format:@"yyyy-MM-dd"];
}
/**
 *  NSString 转换 NSDate
 *
 *  @param string 待转换yyyy-MM-dd HH:mm NSString
 *
 *  @return 转换 后的NSDate
 */
+ (NSDate *)dateConvertFrom_YMDHM_String:(NSString *)string{
    return [[DateManager sharedManager] dateConvertFromString:string format:@"yyyy-MM-dd HH:mm"];
}
/**
 *  NSString 转换 NSDate
 *
 *  @param string 待转换yyyy-MM-dd HH:mm:dd NSString
 *
 *  @return 转换 后的NSDate
 */
+ (NSDate *)dateConvertFrom_YMDHMD_String:(NSString *)string{
    return [[DateManager sharedManager] dateConvertFromString:string format:@"yyyy-MM-dd HH:mm:dd"];
}

#pragma mark-- timeStamp to string date
/**
 *  时间戳根据格式转字符串
 *
 *  @param secs   秒数
 *  @param format 格式
 *
 *  @return 格式后时间字符串
 */
- (NSString *)dateWithTimeIntervalSince1970:(NSTimeInterval)secs format:(NSString *)format
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:secs];
    return [self stringConvertFromDate:date format:format];
}
/**
 *  时间戳根据格式转字符串
 *
 *  @param secs   秒数
 *
 *  @return 格式后时间yyyy-MM-dd字符串
 */
+ (NSString *)date_YMD_WithTimeIntervalSince1970:(NSTimeInterval)secs{
    return [[DateManager sharedManager] dateWithTimeIntervalSince1970:secs format:@"yyyy-MM-dd"];
}
/**
 *  时间戳根据格式转字符串
 *
 *  @param secs   秒数
 *
 *  @return 格式后时间yyyy-MM-dd HH:mm字符串
 */
+ (NSString *)date_YMDHM_WithTimeIntervalSince1970:(NSTimeInterval)secs{
    return [[DateManager sharedManager] dateWithTimeIntervalSince1970:secs format:@"yyyy-MM-dd HH:mm"];
}
/**
 *  时间戳根据格式转字符串
 *
 *  @param secs   秒数
 *
 *  @return 格式后时间yyyy-MM-dd HH:mm:dd字符串
 */
+ (NSString *)date_YMDHMD_WithTimeIntervalSince1970:(NSTimeInterval)secs{
    return [[DateManager sharedManager] dateWithTimeIntervalSince1970:secs format:@"yyyy-MM-dd HH:mm:dd"];
}


#pragma mark-- timeStamp
/**
 *  时间转时间戳long long
 *
 *  @param date NSDate 时间
 *
 *  @return 时间戳long long
 */
+(long long)timeIntervalWithDate:(NSDate*)date
{
    long long interval = 0;
    if (date == nil)
    {
        return interval;
    }
    
    NSTimeInterval tmp = [date timeIntervalSince1970];
    interval = [[NSNumber numberWithDouble:tmp] longLongValue];
    
    //changge to million second
    return interval;
}
/**
 *  时间戳转NSDate
 *
 *  @param interval 时间戳
 *
 *  @return 时间NSDate
 */
+ (NSDate*)dateWithTimeStamp:(long long)interval
{
    if (interval != 0) {
        return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)interval];
    } else {
        return 0;
    }
}
/**
 *  时间转时间戳long long
 *
 *  @param date NSDate 时间
 *
 *  @return 时间戳long long
 */
+(NSString *)timeStampStringWithDate:(NSDate*)date{
    long long  tmp = [self timeIntervalWithDate:date];
    return [[NSNumber numberWithLongLong:tmp] stringValue];
}
/**
 *  当前时间时间戳字符串
 *
 *  @return 当前时间时间戳字符串
 */
+(NSString *)nowTimeStampString{
     return  [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue];
}
#pragma mark--
@end
