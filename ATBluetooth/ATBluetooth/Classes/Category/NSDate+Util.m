//
//  NSDate+Util.m
//  YAMI
//
//  Created by xiao6 on 14-10-13.
//  Copyright (c) 2014年 Summer. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (NSDateString)

- (NSString *)stringWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    
    return [dateFormatter stringFromDate:self];
}

- (NSDate *)dateSetTime:(NSString *)timeString withFormat:(NSString *)dateFormat
{
    return [[[self stringWithFormat:@"yyyy-MM-dd "] stringByAppendingString:timeString] dateFromFormat:[@"yyyy-MM-dd " stringByAppendingString:dateFormat]];
}

- (NSDate *)dateWithFormat:(NSString *)dateFormat
{
    return [[self stringWithFormat:dateFormat] dateFromFormat:dateFormat];
}

- (NSDate *)day
{
    return [[self stringWithFormat:@"yyyy-MM-dd"] dateFromFormat:@"yyyy-MM-dd"];
}

+ (NSDate *)todayAddingTimeInterval:(NSTimeInterval)timeInterval
{
    return [[[NSDate date] day] dateByAddingTimeInterval:timeInterval];
}
@end


@implementation NSString (NSDateString)

- (NSDate *)dateFromFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    
    return [dateFormatter dateFromString:self];
}

@end