//
//  ATPeripheralController.m
//  ATBluetooth
//
//  Created by 敖然 on 15/11/19.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATPeripheralController.h"
#import "ATCharacteristicController.h"
#import "CBPeripheral+RSSI.h"

#define channelOnPeropheralView @"peripheralView"
@interface ATPeripheralController ()

@end

@implementation ATPeripheralController
+ (instancetype)vcWithBluetooth:(BabyBluetooth *)bluetooth peripheral:(CBPeripheral *)peripheral {
    ATPeripheralController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    vc.bluetooth = bluetooth;
    vc.peripheral = peripheral;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    
    // 设置设备连接成功的委托, 同一个baby对象，使用不同的channel切换委托回调
    [self.bluetooth setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功", peripheral.name]];
    }];
    [self.bluetooth setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败", peripheral.name]];
    }];
    [self.bluetooth setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败", peripheral.name]];
    }];
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    //设置发现设备的Services的委托
    [self.bluetooth setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.tableView reloadData];
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [self.bluetooth setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        ATLog(@"===service name:%@",service.UUID);
        [strongSelf.tableView reloadData];
    }];
    //设置读取characteristics的委托
    [self.bluetooth setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        ATLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [self.bluetooth setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.tableView reloadData];
    }];
    //设置读取Descriptor的委托
    [self.bluetooth setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.tableView reloadData];
    }];
    
    //读取rssi的委托
    [self.bluetooth setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.peripheral.exRSSI = RSSI;
        [strongSelf.tableView reloadData];
    }];
    
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        ATLog(@"setBlockOnBeatsBreak call");
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        ATLog(@"setBlockOnBeatsOver call");
    }];
    
    //开始扫描设备
    [self refresh:nil];
}
- (void)dealloc {
    [_bluetooth cancelAllPeripheralsConnection];
}
#pragma mark - actions
- (IBAction)refresh:(id)sender {
    [SVProgressHUD showInfoWithStatus:@"设备连接中..."];
    [self.bluetooth cancelAllPeripheralsConnection];
    self.bluetooth.having(self.peripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

#pragma mark - actions

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.peripheral.services.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < self.peripheral.services.count) {
        return self.peripheral.services[section].characteristics.count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ATPeripheralController"];
    CBCharacteristic *characteristic = self.peripheral.services[indexPath.section].characteristics[indexPath.row];
    cell.textLabel.text = characteristic.UUID.UUIDString;
    
    CBCharacteristicProperties p = characteristic.properties;
    NSString *title = @"";
    for (CBDescriptor *d in characteristic.descriptors) {
        if (d.value) {
            title = [title stringByAppendingFormat:@"[%@ %@]", d.UUID, d.value];
        }
    }
    if (p & CBCharacteristicPropertyBroadcast) {
        title = [title stringByAppendingString:@"|广播"];
    }
    if (p & CBCharacteristicPropertyRead) {
        title = [title stringByAppendingString:@"|读"];
    }
    if (p & CBCharacteristicPropertyWriteWithoutResponse) {
        title = [title stringByAppendingString:@"|写无响应"];
    }
    if (p & CBCharacteristicPropertyWrite) {
        title = [title stringByAppendingString:@"|写"];
    }
    if (p & CBCharacteristicPropertyNotify) {
        title = [title stringByAppendingString:@"|通知"];
    }
    if (p & CBCharacteristicPropertyIndicate) {
        title = [title stringByAppendingString:@"|声明"];
    }
    if (p & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        title = [title stringByAppendingString:@"|验证的"];
    }
    if (p & CBCharacteristicPropertyExtendedProperties) {
        title = [title stringByAppendingString:@"|拓展"];
    }

    cell.detailTextLabel.text = title;;
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"[%@db]SERVICE UUID: %@", self.peripheral.exRSSI, self.peripheral.services[section].UUID.UUIDString];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[ATCharacteristicController vcWithBluetooth:self.bluetooth
                                                                                   peripheral:self.peripheral
                                                                               characteristic:self.peripheral.services[indexPath.section].characteristics[indexPath.row]]
                                         animated:YES];
}

#pragma mark - getter
@end
