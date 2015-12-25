//
//  ATBTData.h
//  ATBluetooth
//
//  Created by 敖然 on 15/12/22.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ATDataEncoding) {
    ATDataEncodingHex, // Hex
    ATDataEncodingUTF8, // UTF-8
    ATDataEncodingGB18030, // kCFStringEncodingGB_18030_2000
    ATDataProtobuf,// 微信智能硬件
};
@interface ATBTData : NSObject
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSData *value;
@property (nonatomic, assign) ATDataEncoding encoding;


+ (instancetype)dataWithValue:(NSData *)value encoding:(ATDataEncoding)encoding;
+ (instancetype)dataWithValue:(NSData *)value date:(NSDate *)date encoding:(ATDataEncoding)encoding;

+ (instancetype)dataWithText:(NSString *)text;
+ (instancetype)dataWithText:(NSString *)text date:(NSDate *)date;
@end

@interface ATBTDataR : ATBTData
@end
@interface ATBTDataW : ATBTData
@end