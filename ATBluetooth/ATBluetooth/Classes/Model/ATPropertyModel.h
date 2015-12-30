//
//  ATPropertyModel.h
//  ATBluetooth
//
//  Created by 敖然 on 15/12/22.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ATBTData.h"

@interface ATPropertyModel : NSObject
@property (nonatomic, weak) CBCharacteristic *characteristic;
@property (nonatomic, assign) CBCharacteristicProperties property;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *leftTitle;
@property (nonatomic, copy) NSString *rightTitle;
@property (nonatomic, copy) void(^leftAction)(ATPropertyModel *property);
@property (nonatomic, copy) void(^rightAction)(ATPropertyModel *property);
@property (nonatomic, strong) NSMutableArray<ATBTData *> *dataList;
@property (nonatomic, copy) void(^dataAction)(ATPropertyModel *property, NSUInteger index, ATBTData *data);
@end
