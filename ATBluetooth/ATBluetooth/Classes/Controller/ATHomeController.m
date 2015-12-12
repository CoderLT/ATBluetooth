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

@interface ATHomeController ()
@property (nonatomic, strong) BabyBluetooth *bluetooth;
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripherals;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *peripheralsAD;

@end

@implementation ATHomeController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //停止之前的连接
    [self.bluetooth cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    self.bluetooth.scanForPeripherals().begin();
}
- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    [self.bluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showWithStatus:@"蓝牙打开成功，开始扫描设备"];
        }
        else {
            [SVProgressHUD showInfoWithStatus:@"蓝牙打开失败"];
        }
    }];
    
    //设置扫描到设备的委托
    [self.bluetooth setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        [SVProgressHUD dismiss];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        ATLog(@"搜索到了设备:%@ - %@db", peripheral.name, RSSI);
        peripheral.exRSSI = RSSI;
        if(![strongSelf.peripherals containsObject:peripheral]) {
            [strongSelf.peripherals addObject:peripheral];
            [strongSelf.peripheralsAD addObject:advertisementData];
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
    //停止之前的连接
    [self.bluetooth cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    self.bluetooth.scanForPeripherals().begin();
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    NSDictionary *ad = self.peripheralsAD[indexPath.row];
    NSString *localName = peripheral.name;
    if ([ad objectForKey:@"kCBAdvDataLocalName"]) {
        localName = [NSString stringWithFormat:@"%@", [ad objectForKey:@"kCBAdvDataLocalName"]];
    }
    cell.textLabel.text = localName;
    NSArray *serviceUUIDs = [ad objectForKey:@"kCBAdvDataServiceUUIDs"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@db] %lu个service, ", peripheral.exRSSI, (unsigned long)serviceUUIDs.count];

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
- (NSMutableArray<NSDictionary *> *)peripheralsAD {
    if (!_peripheralsAD) {
        _peripheralsAD = [NSMutableArray array];
    }
    return _peripheralsAD;
}
@end
