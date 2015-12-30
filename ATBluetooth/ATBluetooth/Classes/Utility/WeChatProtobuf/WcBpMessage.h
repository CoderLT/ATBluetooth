//
//  BPFixHeader.h
//  BLEDemo
//
//  Created by 敖然 on 15/12/15.
//  Copyright (c) 2015年 敖然. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wcprotobuf.pbobjc.h"

#define BUILD_INT16U(byteH, byteL) ((((int16_t)(byteH)<<8) + (byteL)))
#define BYTE_0(data) ((Byte)((data)&0xFF)) // 0x12345678 & 0x000000FF = 0x00000078
#define BYTE_1(data) BYTE_0(((data)>>8))
#define BYTE_2(data) BYTE_0(((data)>>16))
#define BYTE_3(data) BYTE_0(((data)>>24))

typedef NS_ENUM(NSUInteger, WcBpMessageState) {
    WcBpMessageStateStandby = 0,
    WcBpMessageStateWaitForData,
    WcBpMessageStateFinish,
};
@interface WcBpMessage : NSObject
@property (nonatomic, assign) WcBpMessageState state;
@property (nonatomic, assign, readonly) Byte bMagicNumber;
@property (nonatomic, assign) Byte bVar;
@property (nonatomic, assign) int16_t nLength;
@property (nonatomic, assign) MmBp_EmCmdId nCmdId;
@property (nonatomic, assign) int16_t nSeq;
@property (nonatomic, strong) NSMutableData *body;
@property (nonatomic, strong) GPBMessage *gpbMessage;

- (NSData *)data;

- (WcBpMessage *)recieveData:(NSData *)data;
+ (WcBpMessage *)authResponse:(NSData *)sectionData;
+ (WcBpMessage *)initResponse;
+ (WcBpMessage *)pushData:(NSData *)data;
@end
