//
//  NSDate+Util.h
//  YAMI
//
//  Created by xiao6 on 14-10-13.
//  Copyright (c) 2014年 Summer. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSDate (NSDateString)
/**
 *  时间转换为字符串
 *
 *  @param dateFormat @“yyyy-MM-dd EEEE HH:mm:ss zzz” ==> @"2114-10-13 星期一 20:13:17 +8:00"
 *
 *  @return 字符串
 */
- (NSString *)stringWithFormat:(NSString *)dateFormat;
/**
 *  设置时间 @“16:30”
 *
 *  @param timeString @“16:30”
 *  @param dateFormat @“HH:mm”
 *
 *  @return 时间
 */
- (NSDate *)dateSetTime:(NSString *)timeString withFormat:(NSString *)dateFormat;

- (NSDate *)day;
- (NSDate *)dateWithFormat:(NSString *)dateFormat;
+ (NSDate *)todayAddingTimeInterval:(NSTimeInterval)timeInterval;
@end

@interface NSString (NSDateString)
/**
 *  字符串转换为时间
 *
 *  @param dateFormat @“yyyy-MM-dd EEEE HH:mm:ss zzz” ==> @"2114-10-13 星期一 20:13:17 +8:00"
 *
 *  @return 时间
 */
- (NSDate *)dateFromFormat:(NSString *)dateFormat;

@end
