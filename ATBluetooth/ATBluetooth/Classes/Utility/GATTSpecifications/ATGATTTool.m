//
//  ATGATTTool.m
//  ATBluetooth
//
//  Created by 敖然 on 15/12/25.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATGATTTool.h"

@interface ATGATTTool ()
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *serviceDic;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *characteristicDic;
@end
@implementation ATGATTTool
static ATGATTTool *_instance;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (NSString *)serviceDesc:(CBService *)service {
    return [self serviceDescWithUUID:service.UUID];
}
- (NSString *)serviceDescWithUUID:(CBUUID *)uuid {
    return self.serviceDic[uuid.UUIDString];
}
- (NSString *)characteristicDesc:(CBCharacteristic *)characteristic {
    return [self characteristicDescWithUUID:characteristic.UUID];
}
- (NSString *)characteristicDescWithUUID:(CBUUID *)uuid {
    return self.characteristicDic[uuid.UUIDString];
}

#pragma mark - getter
- (NSDictionary<NSString *,NSString *> *)serviceDic {
    if (!_serviceDic) {
        _serviceDic = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"GATT_Specifications" withExtension:@"plist"]][@"services"];
    }
    return _serviceDic;
}
- (NSDictionary<NSString *,NSString *> *)characteristicDic {
    if (!_characteristicDic) {
        _characteristicDic = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"GATT_Specifications" withExtension:@"plist"]][@"characteristics"];
    }
    return _characteristicDic;
}
@end
