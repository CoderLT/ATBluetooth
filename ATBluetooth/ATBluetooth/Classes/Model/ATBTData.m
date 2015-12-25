//
//  ATBTData.m
//  ATBluetooth
//
//  Created by 敖然 on 15/12/22.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATBTData.h"

@implementation ATBTData
+ (instancetype)dataWithValue:(NSData *)value encoding:(ATDataEncoding)encoding {
    return [self dataWithValue:value date:nil encoding:encoding];
}
+ (instancetype)dataWithValue:(NSData *)value date:(NSDate *)date encoding:(ATDataEncoding)encoding {
    ATBTData *data = [[self alloc] init];
    data.date = date ?: [NSDate date];
    data.value = value;
    data.encoding = encoding;
    switch (encoding) {
        case ATDataEncodingHex: {
            NSMutableString *content = [NSMutableString string];
            for (int i = 0; i < value.length; i++) {
                [content appendFormat:@"%@%02X", i == 0 ? @"" : @" ", ((Byte *)value.bytes)[i]];
            }
            data.text = content;
            break;
        }
        case ATDataEncodingUTF8: {
            data.text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            break;
        }
        case ATDataEncodingGB18030: {
            NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            data.text = [[NSString alloc] initWithData:value encoding:encoding];
            break;
        }
        case ATDataProtobuf: {
            
            break;
        }
    }
    return data;
}

+ (instancetype)dataWithText:(NSString *)text {
    return [self dataWithText:text date:nil];
}
+ (instancetype)dataWithText:(NSString *)text date:(NSDate *)date {
    ATBTData *data = [[self alloc] init];
    data.date = date ?: [NSDate date];
    data.text = text;
    return data;
}
@end
@implementation ATBTDataR
@end
@implementation ATBTDataW
@end