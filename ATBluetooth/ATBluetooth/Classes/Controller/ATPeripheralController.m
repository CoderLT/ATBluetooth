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
#import "UIView+Common.h"
#import "ATBlueoothTool.h"
#import "ATLogController.h"
#import "ATGATTTool.h"

#define channelOnPeropheralView ([NSString stringWithFormat:@"%p", self])
@interface ATPeripheralController ()
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIButton *info;

@property (nonatomic, strong) NSMutableArray<ATBTData *> *logs;
@end

@implementation ATPeripheralController
+ (instancetype)vcWithBluetooth:(BabyBluetooth *)bluetooth peripheral:(CBPeripheral *)peripheral {
    ATPeripheralController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    vc.bluetooth = bluetooth;
    vc.peripheral = peripheral;
    return vc;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.peripheral.state != CBPeripheralStateConnected) {
        [self refresh];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    // 设置设备连接成功的委托, 同一个baby对象，使用不同的channel切换委托回调
    [self.bluetooth setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功", peripheral.name]];
        [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(refresh) object:nil];
    }];
    [self.bluetooth setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败", peripheral.name]];
        [strongSelf performSelector:@selector(refresh) withObject:nil afterDelay:1];
    }];
    [self.bluetooth setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败", peripheral.name]];
        [strongSelf performSelector:@selector(refresh) withObject:nil afterDelay:1];
    }];
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    // 设置发现设备的Services的委托
    [self.bluetooth setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@db] %@", peripheral.exRSSI, peripheral.name]];
        [title appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r\nUUID: %@\r\n%@", peripheral.identifier.UUIDString, peripheral.exAdvertisementData ?:@""]
                                                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                                                   NSForegroundColorAttributeName : [UIColor colorWithWhite:(0x87/255.0) alpha:1.0f]}]];
        [strongSelf.header setAttributedText:title];
        strongSelf.info.hidden = (title.length <= 0);
        [rhythm beats];
    }];
    // 设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        ATLog(@"setBlockOnBeatsBreak call");
    }];
    // 设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        ATLog(@"setBlockOnBeatsOver call");
    }];
    
    // 设置发现设service的Characteristics的委托
    [self.bluetooth setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        ATLog(@"==== service name:%@",service.UUID);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.tableView reloadData];
    }];
    // 设置读取characteristics的委托
    [self.bluetooth setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        ATLog(@"==== characteristic name:%@ value is:%@", characteristics.UUID, characteristics.value);
        if (characteristics.value.length <= 0) {
            return;
        }
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.logs addObject:[ATBTDataR dataWithValue:characteristics.value encoding:ATDataEncodingHex]];
    }];
    // 设置发现characteristics的descriptors的委托
    [self.bluetooth setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        ATLog(@"==== characteristic name:%@ descriptors is:%@",characteristic, characteristic.descriptors);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.tableView reloadData];
    }];
    // 设置读取Descriptor的委托
    [self.bluetooth setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        ATLog(@"==== descriptor :%@", descriptor);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.tableView reloadData];
    }];
    
    // 读取rssi的委托
    [self.bluetooth setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        ATLog(@"setBlockOnDidReadRSSI %@", RSSI);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.peripheral.exRSSI = RSSI;
        [strongSelf.tableView reloadData];
    }];
}
- (void)dealloc {
    [_bluetooth cancelAllPeripheralsConnection];
}
#pragma mark - actions
- (void)refresh {
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"设备：%@--连接中...", self.peripheral.name]];
    [self.bluetooth cancelScan];
    [self.bluetooth cancelAllPeripheralsConnection];
    self.bluetooth.having(self.peripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}
- (IBAction)didClickinfo:(id)sender {
    if (self.tableView.tableHeaderView.height == 68) {
        self.tableView.tableHeaderView.height = [self.header sizeThatFits:CGSizeZero].height + 32;
    }
    else {
        self.tableView.tableHeaderView.height = 68;
    }
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
}
- (IBAction)didClickLog:(id)sender {
    [self.navigationController pushViewController:[ATLogController vcWithLogs:self.logs] animated:YES];
}

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
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self tableView:tableView cellForRowAtIndexPath:indexPath] systemLayoutSizeFittingSize:CGSizeZero].height + 16;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ATPeripheralController"];
    CBCharacteristic *characteristic = self.peripheral.services[indexPath.section].characteristics[indexPath.row];
    NSString *desc = [[ATGATTTool shareInstance] characteristicDesc:characteristic];
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@", desc ?: @"", desc?@" : ":@"", characteristic.UUID.UUIDString];
    
    NSString *title = [NSString stringWithFormat:@"属性: %@", [ATBlueoothTool properties:characteristic.properties separator:@"|"]];
    if (characteristic.value.length > 1) {
        NSString *value = [NSString stringWithUTF8String:characteristic.value.bytes];
        title = [title stringByAppendingFormat:@", %@", value ?: characteristic.value];
    }
    
    for (CBDescriptor *d in characteristic.descriptors) {
        if ([d.UUID.UUIDString isEqualToString:CBUUIDCharacteristicUserDescriptionString]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", d.value, cell.textLabel.text];
        }
        else {
            if (d.value) {
                title = [title stringByAppendingFormat:@"\r\n%@ : %@", d.UUID, d.value];
            }
        }
    }

    cell.detailTextLabel.text = title;
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *desc = [[ATGATTTool shareInstance] serviceDesc:self.peripheral.services[section]];
    return [NSString stringWithFormat:@"%@ : %@", desc ?: @"SERVICE UUID", self.peripheral.services[section].UUID.UUIDString];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[ATCharacteristicController vcWithBluetooth:self.bluetooth
                                                                                   peripheral:self.peripheral
                                                                               characteristic:self.peripheral.services[indexPath.section].characteristics[indexPath.row]
                                                                                         logs:self.logs]
                                         animated:YES];
}

#pragma mark - getter
- (NSMutableArray<ATBTData *> *)logs {
    if (!_logs) {
        _logs = [NSMutableArray array];
    }
    return _logs;
}
@end
