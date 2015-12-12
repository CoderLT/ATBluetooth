//
//  ATCharacteristicController.m
//  ATBluetooth
//
//  Created by 敖然 on 15/11/19.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATCharacteristicController.h"
#import "NSDate+Util.h"
#import "ATTextView.h"

#define channelOnCharacteristicView @"CharacteristicView"
@interface ATCharacteristicController ()
@property (nonatomic, strong) NSMutableString *receiveText;
@property (weak, nonatomic) IBOutlet ATTextView *sendTextView;
@property (weak, nonatomic) IBOutlet UITextView *recieveTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

@end

@implementation ATCharacteristicController
+ (instancetype)vcWithBluetooth:(BabyBluetooth *)bluetooth peripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    ATCharacteristicController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    vc.bluetooth = bluetooth;
    vc.peripheral = peripheral;
    vc.characteristic = characteristic;
    return vc;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.characteristic) {
        [self.bluetooth cancelNotify:self.peripheral characteristic:self.characteristic];
    }
    [self.displayLink invalidate];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sendTextView.placeholder = @"请输入要发送的类容";
    self.sendTextView.font = [UIFont systemFontOfSize:12.0f];
    
    __weak typeof(self) weakSelf = self;
    // 设置读取Descriptor的委托
    [self.bluetooth setBlockOnReadValueForDescriptorsAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateTitleLabel];
    }];
    //设置写数据成功的block
    [self.bluetooth setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        ATLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
        [SVProgressHUD showInfoWithStatus:@"写成功"];
    }];
    //设置通知状态改变的block
    [self.bluetooth setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        ATLog(@"uid:%@, isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    }];
    //读取服务
    self.bluetooth.channel(channelOnCharacteristicView).characteristicDetails(self.peripheral, self.characteristic);
    [self didClickNotify:self.navigationItem.rightBarButtonItem];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self updateTitleLabel];
}

#pragma mark - actions
- (IBAction)segmentChange:(UISegmentedControl *)sender {
    
}
- (void)updateTitleLabel {
    CBCharacteristicProperties p = self.characteristic.properties;
    NSString *title = @"";
    for (CBDescriptor *d in self.characteristic.descriptors) {
        if (d.value) {
            title = [title stringByAppendingFormat:@"[%@]", d.value];
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
    self.titleLabel.text = title;
}
- (IBAction)didClickSend:(id)sender {
    NSString *content = self.sendTextView.text;
    if (content.length <= 0) {
        return;
    }
    self.sendTextView.text = nil;
    NSData *data;
    if (self.segment.selectedSegmentIndex == 0) {
        content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (content.length <= 0) {
            return;
        }
        char *myBuffer = (char *)malloc((int)[content length] / 2 + 1);
        bzero(myBuffer, [content length] / 2 + 1);
        for (int i = 0; i < (int)([content length] - 1); i += 2) {
            unsigned int anInt;
            NSString * hexCharStr = [content substringWithRange:NSMakeRange(i, 2)];
            NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
            myBuffer[i / 2] = (char)anInt;
        }
        data = [NSData dataWithBytes:myBuffer length:sizeof([content length] / 2 + 1)];
    }
    else {
        data = [content dataUsingEncoding: NSUTF8StringEncoding];
    }
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}
- (IBAction)didClickNotify:(UIBarButtonItem *)sender {
    if (self.peripheral.state != CBPeripheralStateConnected) {
        [SVProgressHUD showErrorWithStatus:@"peripheral已经断开连接，请重新连接"];
        return;
    }
    if (self.characteristic.properties & CBCharacteristicPropertyNotify || self.characteristic.properties & CBCharacteristicPropertyIndicate) {
        if (self.characteristic.isNotifying) {
            [self.bluetooth cancelNotify:self.peripheral characteristic:self.characteristic];
            [sender setTitle:@"通知"];
            [self.displayLink setPaused:YES];
        } else {
            __weak typeof(self) weakSelf = self;
            [self.bluetooth notify:self.peripheral characteristic:self.characteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    ATLog(@"read: %@", characteristics.value);
                    NSMutableString *string = [NSMutableString stringWithFormat:@"\r\n%@", [[NSDate date] stringWithFormat:@"mm.ss.SSS - "]];
                    if (strongSelf.segment.selectedSegmentIndex == 0) {
                        Byte *byte = (Byte *)characteristics.value.bytes;
                        NSUInteger lenght = characteristics.value.length;
                        while (lenght--) {
                            [string appendFormat:@" %02X", *byte++];
                        }
                    }
                    else {
                        [string appendString:[[NSString alloc] initWithData:characteristics.value encoding:NSASCIIStringEncoding]];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.receiveText appendString:string];
                    });
                });
            }];
            [sender setTitle:@"取消通知"];
            [self.displayLink setPaused:NO];
        }
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"这个characteristic没有notify的权限"];
        return;
    }
}
- (void)updateDisplay {
    self.recieveTextView.text = [NSString stringWithFormat:@"%@\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n", self.receiveText];
    [self.recieveTextView scrollRangeToVisible:NSMakeRange(self.recieveTextView.text.length - 1, 1)];
}
#pragma mark - getter
- (NSMutableString *)receiveText {
    if (!_receiveText) {
        _receiveText = [NSMutableString string];
    }
    return _receiveText;
}
- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay)];
        _displayLink.frameInterval = 10;
    }
    return _displayLink;
}
@end
