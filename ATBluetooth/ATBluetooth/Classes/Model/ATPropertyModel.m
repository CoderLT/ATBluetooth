//
//  ATPropertyModel.m
//  ATBluetooth
//
//  Created by 敖然 on 15/12/22.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATPropertyModel.h"

@implementation ATPropertyModel

- (NSMutableArray<ATBTData *> *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}
@end
