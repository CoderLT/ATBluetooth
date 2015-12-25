//
//  ATHomeController.m
//  ATBluetooth
//
//  Created by 敖然 on 15/11/19.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATHomeController.h"
#import <BabyBluetooth/BabyBluetooth.h>
#import <SVProgressHUD.h>
#import "CBPeripheral+RSSI.h"
#import "ATPeripheralController.h"
#import "Wcprotobuf.pbobjc.h"

@interface ATHomeController ()
@property (nonatomic, strong) BabyBluetooth *bluetooth;
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripherals;

@end
#define CurrentChannel (@"ATHomeController")
@implementation ATHomeController
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self scanBluetooth:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    [self.bluetooth setBlockOnCentralManagerDidUpdateStateAtChannel:CurrentChannel block:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showWithStatus:@"蓝牙打开成功，开始扫描设备"];
        }
        else {
            [SVProgressHUD showInfoWithStatus:@"蓝牙打开失败"];
        }
    }];
    
    //设置扫描到设备的委托
    [self.bluetooth setBlockOnDiscoverToPeripheralsAtChannel:CurrentChannel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        [SVProgressHUD dismiss];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        ATLog(@"搜索到了设备:%@ - %@db", peripheral.name, RSSI);
        peripheral.exRSSI = RSSI;
        if(![strongSelf.peripherals containsObject:peripheral]) {
            peripheral.exAdvertisementData = advertisementData;
            [strongSelf.peripherals addObject:peripheral];
            [strongSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:strongSelf.peripherals.count-1 inSection:0]]
                                        withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            NSUInteger index = [strongSelf.peripherals indexOfObject:peripheral];
            [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                        withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}
#pragma mark - actions
- (IBAction)scanBluetooth:(id)sender {
    self.bluetooth.stop(0);
    [self.peripherals removeAllObjects];
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //停止之前的连接
        [self.bluetooth cancelAllPeripheralsConnection];
        //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
        self.bluetooth.channel(CurrentChannel).scanForPeripherals().begin();
    });
}

#pragma mark - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bluetoothListIdentifier"];
    
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    NSDictionary *ad = peripheral.exAdvertisementData;
    NSString *localName = peripheral.name;
    if ([ad objectForKey:CBAdvertisementDataLocalNameKey]) {
        localName = [NSString stringWithFormat:@"%@", [ad objectForKey:CBAdvertisementDataLocalNameKey]];
    }
    cell.textLabel.text = localName;
    NSArray *serviceUUIDs = [ad objectForKey:CBAdvertisementDataServiceUUIDsKey];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@db]%@, %@, %lu个service",
                                 peripheral.exRSSI,
                                 ad[CBAdvertisementDataTxPowerLevelKey] ? [NSString stringWithFormat:@", Tx:%@db", ad[CBAdvertisementDataTxPowerLevelKey]] : @"",
                                 [ad[CBAdvertisementDataIsConnectable] boolValue] ? @"可连接" : @"不可连接",
                                 (unsigned long)serviceUUIDs.count];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[ATPeripheralController vcWithBluetooth:self.bluetooth peripheral:self.peripherals[indexPath.row]]
                                         animated:YES];
}

#pragma mark - getter
- (BabyBluetooth *)bluetooth {
    if (!_bluetooth) {
        _bluetooth = [BabyBluetooth shareBabyBluetooth];
    }
    return _bluetooth;
}
- (NSMutableArray<CBPeripheral *> *)peripherals {
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

#pragma mark - test
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    MmBp_AuthRequest *authReq = [MmBp_AuthRequest message];
////    authReq.hasBaseRequest = YES;
//    authReq.baseRequest = [MmBp_BaseRequest message];
//    
//    // deviceType加deviceId的md5，16字节的二进制数据
//    Byte md5Device[16] = {0x00, };
////    authReq.hasMd5DeviceTypeAndDeviceId = YES;
//    authReq.md5DeviceTypeAndDeviceId = [NSData dataWithBytes:md5Device length:16];
//    
//    // 设备支持的本proto文件的版本号，第一个字节表示最小版本，第二个字节表示小版本，第三字节表示大版本。版本号为1.0.0的话，应该填：0x010000；1.2.3的话，填成0x010203。
////    authReq.hasProtoVersion = YES;
//    authReq.protoVersion = 0x010004;
//    
//    // 填1
////    authReq.hasAuthProto = YES;
//    authReq.authProto = 0x01;
//    
//    // 验证和加密的方法，见EmAuthMethod
////    authReq.hasAuthMethod = YES;
//    authReq.authMethod = MmBp_EmAuthMethod_EamMd5;
//    
//    // 具体生成方法见文档
////    authReq.hasAesSign = YES;
//    Byte aesSign[4] = {0x00, };
//    authReq.aesSign = [NSData dataWithBytes:aesSign length:4];
//    
//    // mac地址，6位。当设备没有烧deviceId的时候，可使用该mac地址字段来通过微信app的认证
////    authReq.hasMacAddress = YES;
//    Byte macAddress[6] = {0x00, };
//    authReq.macAddress = [NSData dataWithBytes:&macAddress length:sizeof(macAddress)];
//    
//    NSLog(@"authReq1 %@ --- %@", authReq, authReq.data);
//    
//    Byte testData2[] = {0x0A, 0x00, 0x12, 0x10, 0xB4, 0x3F, 0x12, 0x04, 0x2A, 0x02, 0xE0, 0x1C,
//        0x2B, 0xDD, 0x7D, 0x02, 0x90, 0x62, 0x13, 0xA3, 0x18, 0x80, 0x80, 0x04, 0x20, 0x01, 0x28, 0x01, 0x32, 0x10, 0x00, 0x00,
//        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x03, 0x41, 0x4D, 0x33};
//    MmBp_AuthRequest *authReq2 = [MmBp_AuthRequest parseFromData:[NSData dataWithBytes:testData2 length:sizeof(testData2)] error:nil];
//    NSLog(@"authReq2 %@ --- %@", authReq2, authReq2.data);
//    
////    蓝牙串口数据 字节流 (蓝牙一次发送20字节, 根据定长包头信息, 将多次接收到的数据拼接在一起)
////    FE 01 00 24 27 11 00 04 0A 00 12 10 39 3D 16 A7 25 92 38 66
////    4D 2C 65 84 EA 6E 6E 1E 18 84 80 04 20 01 28 01
////    
////    定长包头: FE 01 00 24 27 11 00 04
////    FE (魔法数字) 01(版本号) 00 24(包长度) 27 11(命令号) 00 04(序列号)
////    
////    变长包体: 0A 00 12 10 39 3D 16 A7 25 92 38 66 4D 2C 65 84 EA 6E 6E 1E 18 84 80 04 20 01 28 01
////    用protobuf解码成对象
//    Byte testData3[] = {0x0A, 0x00, 0x12, 0x10, 0x39, 0x3D, 0x16, 0xA7, 0x25, 0x92, 0x38, 0x66,
//                        0x4D, 0x2C, 0x65, 0x84, 0xEA, 0x6E, 0x6E, 0x1E, 0x18, 0x84, 0x80, 0x04, 0x20, 0x01, 0x28, 0x01};
//    MmBp_AuthRequest *authReq3 = [MmBp_AuthRequest parseFromData:[NSData dataWithBytes:testData3 length:sizeof(testData3)] error:nil];
//    NSLog(@"authReq3 %@ --- %@", authReq3, authReq3.data);
//}
@end
