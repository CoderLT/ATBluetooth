//
//  ATCharacteristicController.m
//  ATBluetooth
//
//  Created by 敖然 on 15/11/19.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATCharacteristicController.h"
#import "NSDate+Util.h"
#import "CBPeripheral+RSSI.h"
#import "UIView+Common.h"
#import "ATTextInputController.h"
#import "ATActionCell.h"
#import "ATLogCell.h"
#import "ATPropertyModel.h"
#import "ATLogController.h"
#import "ATBlueoothTool.h"


#define channelOnCharacteristicView ([NSString stringWithFormat:@"%p", self])

@interface ATCharacteristicController ()
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIButton *info;
@property (nonatomic, strong) NSMutableArray<ATPropertyModel *> *propertys;
@property (nonatomic, assign) ATDataEncoding enCoding;

@end

@implementation ATCharacteristicController
+ (instancetype)vcWithBluetooth:(BabyBluetooth *)bluetooth peripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic logs:(NSMutableArray<ATBTData *> *)logs {
    ATCharacteristicController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    vc.bluetooth = bluetooth;
    vc.peripheral = peripheral;
    vc.characteristic = characteristic;
    vc.logs = logs;
    return vc;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    // 设置读取Descriptor的委托
    [self.bluetooth setBlockOnReadValueForDescriptorsAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateTitleLabel];
    }];
    //读取服务
    self.bluetooth.channel(channelOnCharacteristicView).characteristicDetails(self.peripheral, self.characteristic);
    [self updateTitleLabel];
    
    [self initData];
}

#pragma mark - actions
- (IBAction)didClickLog:(id)sender {
    [self.navigationController pushViewController:[ATLogController vcWithLogs:self.logs] animated:YES];
}
- (IBAction)didClickRightItem:(UIBarButtonItem *)item {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择编码类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Hex(十六进制)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.enCoding = ATDataEncodingHex;
        item.title = @"Hex";
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"UTF-8" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.enCoding = ATDataEncodingUTF8;
        item.title = @"UTF-8";
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"GB18030(中文)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.enCoding = ATDataEncodingGB18030;
        item.title = @"GB18030";
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}
- (void)initData {
    if (self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        ATPropertyModel *property = [[ATPropertyModel alloc] init];
        property.property = CBCharacteristicPropertyWriteWithoutResponse;
        property.title = @"写无回复";
        property.rightTitle = @"写数据";
        __weak typeof(self) weakSelf = self;
        [property setRightAction:^(ATPropertyModel *property) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.navigationController pushViewController:[ATTextInputController VCWithType:(self.enCoding == ATDataEncodingHex) completion:^(NSString *text) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf send:text property:property];
            }] animated:YES];
        }];
        [property setDataAction:^(ATPropertyModel *property, NSUInteger index, ATBTData *data) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [property.dataList removeObject:data];
            [strongSelf send:data.text property:property];
        }];
        [self.propertys addObject:property];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyWrite) {
        ATPropertyModel *property = [[ATPropertyModel alloc] init];
        property.property = CBCharacteristicPropertyWrite;
        property.title = @"写";
        property.rightTitle = @"写数据";
        __weak typeof(self) weakSelf = self;
        [property setRightAction:^(ATPropertyModel *property) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.navigationController pushViewController:[ATTextInputController VCWithType:(self.enCoding == ATDataEncodingHex) completion:^(NSString *text) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf send:text property:property];
            }] animated:YES];
        }];
        [property setDataAction:^(ATPropertyModel *property, NSUInteger index, ATBTData *data) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [property.dataList removeObject:data];
            [strongSelf send:data.text property:property];
        }];
        [self.propertys addObject:property];
        //设置写数据成功的block
        [self.bluetooth setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
            ATLog(@"%@ write: %@",characteristic.UUID, characteristic.value);
            [SVProgressHUD showInfoWithStatus:@"写成功"];
        }];
    }
    if (self.characteristic.properties & (CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify | CBCharacteristicPropertyIndicate)) {
        ATPropertyModel *property = [[ATPropertyModel alloc] init];
        property.property = (self.characteristic.properties & (CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify | CBCharacteristicPropertyIndicate));
        property.title = [ATBlueoothTool properties:property.property separator:@"&"];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(property) weakProperty = property;
        if (self.characteristic.properties & CBCharacteristicPropertyRead) {
            property.leftTitle = @"读取数据";
            [property setLeftAction:^(ATPropertyModel *property) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.bluetooth.readValueForCharacteristic();
                [strongSelf.peripheral readValueForCharacteristic:strongSelf.characteristic];
            }];
            // 监听读取数据
            [self.bluetooth setBlockOnReadValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                __strong typeof(weakProperty) strongProperty = weakProperty;
                [strongSelf read:characteristics.value property:strongProperty];
            }];
        }
        if (self.characteristic.properties & (CBCharacteristicPropertyNotify | CBCharacteristicPropertyIndicate)) {
            property.rightTitle = @"订阅通知";
            [property setRightAction:^(ATPropertyModel *property) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.peripheral.state != CBPeripheralStateConnected) {
                    [SVProgressHUD showErrorWithStatus:@"peripheral已经断开连接，请重新连接"];
                    return;
                }
                if (strongSelf.characteristic.isNotifying) {
                    [strongSelf.bluetooth cancelNotify:strongSelf.peripheral characteristic:strongSelf.characteristic];
                } else {
                    [strongSelf.bluetooth notify:strongSelf.peripheral characteristic:strongSelf.characteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf read:characteristics.value property:property];
                    }];
                }
            }];
            // 监听通知状态
            [self.bluetooth setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
                ATLog(@"uid:%@, isNotifying:%@",characteristic.UUID, characteristic.isNotifying ? @"on" : @"off");
                __strong typeof(weakSelf) strongSelf = weakSelf;
                property.rightTitle = characteristic.isNotifying ? @"取消订阅通知" : @"订阅通知";
                [strongSelf.tableView reloadData];
            }];
        }
        [self.propertys addObject:property];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyBroadcast) {
        ATPropertyModel *property = [[ATPropertyModel alloc] init];
        property.property = CBCharacteristicPropertyBroadcast;
        property.title = @"广播";
        [self.propertys addObject:property];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        ATPropertyModel *property = [[ATPropertyModel alloc] init];
        property.property = CBCharacteristicPropertyAuthenticatedSignedWrites;
        property.title = @"验证的";
        [self.propertys addObject:property];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyExtendedProperties) {
        ATPropertyModel *property = [[ATPropertyModel alloc] init];
        property.property = CBCharacteristicPropertyExtendedProperties;
        property.title = @"拓展";
        [self.propertys addObject:property];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyNotifyEncryptionRequired) {
        ATPropertyModel *property = [[ATPropertyModel alloc] init];
        property.property = CBCharacteristicPropertyNotifyEncryptionRequired;
        property.title = @"加密通知";
        [self.propertys addObject:property];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyIndicateEncryptionRequired) {
        ATPropertyModel *property = [[ATPropertyModel alloc] init];
        property.property = CBCharacteristicPropertyIndicateEncryptionRequired;
        property.title = @"加密声明";
        [self.propertys addObject:property];
    }
    [self.tableView reloadData];
}
- (void)updateTitleLabel {
    NSString *userDesc;
    for (CBDescriptor *d in self.characteristic.descriptors) {
        if ([d.UUID.UUIDString isEqualToString:CBUUIDCharacteristicUserDescriptionString]) {
            userDesc = d.value;
        }
    }
    
    NSMutableAttributedString *header = [[NSMutableAttributedString alloc] initWithString:userDesc?:@""];
    NSString *title = [NSString stringWithFormat:@"属性: %@", [ATBlueoothTool properties:self.characteristic.properties separator:@"|"]];
    for (CBDescriptor *d in self.characteristic.descriptors) {
        if (d.value) {
            title = [title stringByAppendingFormat:@"\r\n%@ : %@", d.UUID, d.value];
        }
    }
    NSAttributedString *desc = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"UUID : %@\r\n%@",
                                                                           self.characteristic.UUID.UUIDString, title]
                                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                                            NSForegroundColorAttributeName : [UIColor colorWithWhite:(0x87/255.0) alpha:1.0f]}];
    [header appendAttributedString:[[NSAttributedString alloc] initWithString:header.mutableString.length ? @"\r\n" : @""]];
    [header appendAttributedString:desc];
    [self.header setAttributedText:header];
    self.info.hidden = (title.length <= 0);
}
- (IBAction)didClickinfo:(id)sender {
    if (self.tableView.tableHeaderView.height == 68) {
        CGFloat height = [self.header sizeThatFits:CGSizeMake(self.header.width, MAXFLOAT)].height;
        self.tableView.tableHeaderView.height = height + 32;
    }
    else {
        self.tableView.tableHeaderView.height = 68;
    }
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
}
- (void)read:(NSData *)data property:(ATPropertyModel *)property {
    if (data.length <= 0) {
        return;
    }
    ATBTDataR *logData = [ATBTDataR dataWithValue:data encoding:self.enCoding];
    [property.dataList insertObject:logData atIndex:0];
    if (property.dataList.count > 5) {
        [property.dataList removeLastObject];
    }
    [self.logs addObject:logData];
    [self.tableView reloadData];
}
- (void)send:(NSString *)content property:(ATPropertyModel *)property {
    if (content.length <= 0) {
        return;
    }
    NSData *data;
    ATBTDataW *logData;
    switch (self.enCoding) {
        case ATDataEncodingHex: {
            content = [content uppercaseString];
            content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (content.length <= 0) {
                return;
            }
            NSMutableString *logContent = [NSMutableString string];
            char *myBuffer = (char *)malloc((int)[content length] / 2 + 1);
            bzero(myBuffer, [content length] / 2 + 1);
            for (int i = 0; i < (int)([content length] - 1); i += 2) {
                unsigned int anInt;
                NSString * hexCharStr = [content substringWithRange:NSMakeRange(i, 2)];
                NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
                [scanner scanHexInt:&anInt];
                myBuffer[i / 2] = (char)anInt;
                [logContent appendFormat:@"%@%@", logContent.length ? @" " : @"", hexCharStr];
            }
            data = [NSData dataWithBytes:myBuffer length:sizeof([content length] / 2 + 1)];
            logData = [ATBTDataW dataWithText:logContent];
            break;
        }
        case ATDataEncodingUTF8: {
            data = [content dataUsingEncoding:NSUTF8StringEncoding];
            logData = [ATBTDataW dataWithText:content];
            break;
        }
        case ATDataEncodingGB18030: {
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            data = [content dataUsingEncoding:enc];
            logData = [ATBTDataW dataWithText:content];
            break;
        }
        case ATDataProtobuf: {
            
            break;
        }
    }
    
    [property.dataList insertObject:logData atIndex:0];
    if (property.dataList.count > 5) {
        [property.dataList removeLastObject];
    }
    [self.logs addObject:logData];

    NSInteger start = 0;
    while (start < data.length) {
        NSUInteger bufCount = MIN(20, data.length - start);
        [self.peripheral writeValue:[data subdataWithRange:NSMakeRange(start, bufCount)]
                  forCharacteristic:self.characteristic
                               type:property.property == CBCharacteristicPropertyWrite ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse];
        start += bufCount;
    }
    
    [self.tableView reloadData];
}
#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.propertys.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ATPropertyModel *property = self.propertys[section];
    return ((property.leftTitle || property.rightTitle) ? 1 + property.dataList.count : 0);
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.propertys[section].title;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ATPropertyModel *property = self.propertys[indexPath.section];
    if (indexPath.row == 0) {
        ATActionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATActionCell class])];
        [cell.leftButton setTitle:property.leftTitle forState:UIControlStateNormal];
        [cell.rightButton setTitle:property.rightTitle forState:UIControlStateNormal];
        [cell setDidClickButton:^(ATActionCell *cell, UIButton *button) {
            if (cell.leftButton == button) {
                if (property.leftAction) {
                    property.leftAction(property);
                }
            }
            else if (cell.rightButton == button) {
                if (property.rightAction) {
                    property.rightAction(property);
                }
            }
        }];
        return cell;
    }
    else {
        ATLogCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATLogCell class])];
        ATBTData *data = property.dataList[indexPath.row - 1];
        cell.titleLabel.text = [data.date stringWithFormat:@"mm:ss.SSS"];
        cell.detailLabel.text = data.text;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ATPropertyModel *property = self.propertys[indexPath.section];
    if (indexPath.row >= 1 && indexPath.row < property.dataList.count + 1) {
        ATBTData *data = property.dataList[indexPath.row - 1];
        if (property.dataAction) {
            property.dataAction(property, indexPath.row - 1, data);
        }
    }
}

#pragma mark - getter
- (NSMutableArray<ATPropertyModel *> *)propertys {
    if (!_propertys) {
        _propertys = [NSMutableArray array];
    }
    return _propertys;
}
@end
