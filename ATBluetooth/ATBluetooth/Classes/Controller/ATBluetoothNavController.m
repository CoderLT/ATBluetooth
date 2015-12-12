//
//  ATBluetoothNavController.m
//  AT
//
//  Created by AT on 15/4/24.
//  Copyright (c) 2015年 AT. All rights reserved.
//

#import "ATBluetoothNavController.h"

@implementation ATBluetoothNavController
+ (void)initialize
{
    // 设置导航栏背景颜色\文字颜色
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setTintColor:[UIColor colorWithWhite:0x44/255.0f alpha:1.0f]];
    [navBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0x44/255.0f alpha:1.0f],
                                      NSFontAttributeName : [UIFont systemFontOfSize:20]}];
    // 清除分割线
    [navBar setShadowImage:[UIImage new]];
    
    // 设置按钮文字颜色
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    [item setTintColor:[UIColor colorWithWhite:0x44/255.0f alpha:1.0f]];
    [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0x44/255.0f alpha:1.0f],
                                    NSFontAttributeName : [UIFont systemFontOfSize:16]}
                        forState:UIControlStateNormal];
}

@end
