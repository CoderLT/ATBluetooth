//
//  ATActionCell.h
//  ATBluetooth
//
//  Created by 敖然 on 15/12/22.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATActionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (nonatomic, copy) void(^didClickButton)(ATActionCell *cell, UIButton *button);
@end
