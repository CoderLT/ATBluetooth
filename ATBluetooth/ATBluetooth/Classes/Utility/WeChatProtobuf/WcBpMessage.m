//
//  BPFixHeader.m
//  BLEDemo
//
//  Created by 敖然 on 15/12/15.
//  Copyright (c) 2015年 敖然. All rights reserved.
//

#import "WcBpMessage.h"
#import <UIDevice+YYAdd.h>

@implementation WcBpMessage
{
    NSTimeInterval _lastTime;
}
- (instancetype)init {
    if (self = [super init]) {
        _bMagicNumber = 0xFE;
        _bVar = 0x01;
        _nCmdId = MmBp_EmCmdId_EciNone;
        _lastTime = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}
- (NSMutableData *)body {
    if (!_body) {
        _body = [[NSMutableData alloc] init];
    }
    return _body;
}
- (NSData *)data {
    NSMutableData *data = [[NSMutableData alloc] init];
    Byte header[] = {self.bMagicNumber, self.bVar,
        BYTE_1(self.nLength), BYTE_0(self.nLength),
        BYTE_1(self.nCmdId), BYTE_0(self.nCmdId),
        BYTE_1(self.nSeq), BYTE_0(self.nSeq)};
    [data appendBytes:header length:sizeof(header)];
    // 包体 procobuf
    if (self.gpbMessage) {
        [data appendData:self.gpbMessage.data];
    }
    else {
        [data appendData:self.body];
    }
    return data;
}

- (WcBpMessage *)recieveData:(NSData *)data {
    Byte *byte = (Byte *)data.bytes;
    NSInteger length = data.length;
    NSUInteger start = 0;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now > _lastTime + 0.5) {
        self.state = WcBpMessageStateStandby;
    }
    if (WcBpMessageStateStandby == self.state) {
        if (byte[0] == self.bMagicNumber) {
            self.bVar = byte[1];
            self.nLength = BUILD_INT16U(byte[2], byte[3]);
            self.nCmdId = BUILD_INT16U(byte[4], byte[5]);
            self.nSeq = BUILD_INT16U(byte[6], byte[7]);
            self.state = WcBpMessageStateWaitForData;
            self.body = nil;
            self.gpbMessage = nil;
            start = 8;
            _lastTime = now;
        }
    }
    if (WcBpMessageStateWaitForData == self.state) {
        NSUInteger remainCount = self.nLength - 8 - self.body.length;
        remainCount = MIN(length - start, remainCount);
        [self.body appendData:[NSData dataWithBytes:&byte[start] length:remainCount]];
        if (self.body.length + 8 >= self.nLength) {
            [self parseMessageData];
            self.state = WcBpMessageStateFinish;
        }
        _lastTime = now;
    }
    return self;
}
- (void)parseMessageData {
    switch (self.nCmdId) {
        case MmBp_EmCmdId_EciReqAuth: {
            self.gpbMessage = [MmBp_AuthRequest parseFromData:self.body error:nil];
            break;
        }
        case MmBp_EmCmdId_EciReqInit: {
            self.gpbMessage = [MmBp_InitRequest parseFromData:self.body error:nil];
            break;
        }
        case MmBp_EmCmdId_EciReqSendData: {
            self.gpbMessage = [MmBp_SendDataRequest parseFromData:self.body error:nil];
            break;
        }
        default:
            break;
    }
}

+ (WcBpMessage *)authResponse:(NSData *)sectionData {
    MmBp_AuthResponse *authRes = [MmBp_AuthResponse message];
    authRes.baseResponse = [MmBp_BaseResponse message];
    authRes.baseResponse.errCode = 0;
    authRes.aesSessionKey = sectionData ?: [NSData dataWithBytes:NULL length:0];
    
    WcBpMessage *respAuth = [[WcBpMessage alloc] init];
    respAuth.nCmdId = MmBp_EmCmdId_EciRespAuth;
    respAuth.nLength = authRes.data.length + 8;
    respAuth.gpbMessage = authRes;
    [respAuth.body appendData:authRes.data];
    return respAuth;
}

+ (WcBpMessage *)initResponse {
    MmBp_InitResponse *initRes = [MmBp_InitResponse message];
    initRes.baseResponse = [MmBp_BaseResponse message];
    initRes.baseResponse.errCode = 0;
    initRes.userIdHigh = 0;
    initRes.userIdLow = 0;
    initRes.challeangeAnswer = 0;
    initRes.initScence = MmBp_EmInitScence_EisAutoSync;
    initRes.autoSyncMaxDurationSecond = 0xffffffff;
    initRes.userNickName = @"蓝牙助手";
    initRes.platformType = MmBp_EmPlatformType_EptIos;
    initRes.model = [[UIDevice currentDevice] model];
    initRes.os = [[UIDevice currentDevice] systemVersion];
    time_t currentTime = time(NULL);;
    struct tm *tm = localtime(&currentTime);
    initRes.time = (int32_t)currentTime;
    initRes.timeZone = (int32_t)timezone;
    initRes.timeString = [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d%01d", tm->tm_year+1900, tm->tm_mon+1, tm->tm_mday, tm->tm_hour, tm->tm_min, tm->tm_sec, tm->tm_wday?:7];
    
    WcBpMessage *respInit = [[WcBpMessage alloc] init];
    respInit.nCmdId = MmBp_EmCmdId_EciRespInit;
    respInit.nLength = initRes.data.length + 8;
    respInit.gpbMessage = initRes;
    [respInit.body appendData:initRes.data];
    return respInit;
}

+ (WcBpMessage *)pushData:(NSData *)data {
    static NSUInteger seq = 0;
    MmBp_RecvDataPush *push = [MmBp_RecvDataPush message];
    push.basePush = [MmBp_BasePush message];
    push.type = MmBp_EmDeviceDataType_EddtManufatureSvr;
    push.data_p = data;
    
    WcBpMessage *bpMessage = [[WcBpMessage alloc] init];
    bpMessage.nCmdId = MmBp_EmCmdId_EciPushRecvData;
    bpMessage.nSeq = seq++;
    bpMessage.nLength = push.data.length + 8;
    bpMessage.gpbMessage = push;
    [bpMessage.body appendData:push.data];
    return bpMessage;
}
@end
