//
//  ATTextInputController.h
//  ATBluetooth
//
//  Created by 敖然 on 15/12/22.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ATTextInputCompletion)(NSString *text);
@interface ATTextInputController : UIViewController


+ (instancetype)VCWithType:(BOOL)isHex completion:(ATTextInputCompletion)completion;
@end
