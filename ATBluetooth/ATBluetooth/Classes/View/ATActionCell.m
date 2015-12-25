//
//  ATActionCell.m
//  ATBluetooth
//
//  Created by 敖然 on 15/12/22.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATActionCell.h"

@implementation ATActionCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (IBAction)didClickButton:(id)sender {
    if (self.didClickButton) {
        self.didClickButton(self, sender);
    }
}


@end
