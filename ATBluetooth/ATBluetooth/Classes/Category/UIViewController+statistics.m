//
//  UIViewController+statistics.m
//  ATBluetooth
//
//  Created by 敖然 on 15/11/20.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "UIViewController+statistics.h"
#import <MobClick.h>
#import <Aspects/Aspects.h>

@implementation UIViewController (statistics)
+ (void)load {
    [MobClick startWithAppkey:@"564ee55ee0f55aeda3002696" reportPolicy:BATCH channelId:@"App Store"];
    [self aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
//        ATLog(@"View Controller %@ will appear animated: %tu", aspectInfo.instance, animated);
        [MobClick beginLogPageView:NSStringFromClass([aspectInfo.instance class])];
    } error:NULL];
    [self aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
//        ATLog(@"View Controller %@ will disappear animated: %tu", aspectInfo.instance, animated);
        [MobClick endLogPageView:NSStringFromClass([aspectInfo.instance class])];
    } error:NULL];
}
@end
