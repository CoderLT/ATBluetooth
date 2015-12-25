//
//  ATBlueoothTool.h
//  ATBluetooth
//
//  Created by 敖然 on 15/12/23.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ATBlueoothTool : NSObject

+ (NSString *)properties:(CBCharacteristicProperties)properties separator:(NSString *)separator;
@end
