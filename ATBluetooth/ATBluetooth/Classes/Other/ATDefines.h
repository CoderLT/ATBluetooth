//
//  ATDefines.h
//  AT
//
//  Created by AT on 14-8-3.
//  Copyright (c) 2014年 AT. All rights reserved.
//

#ifndef _ATDEFINES_H_
#define _ATDEFINES_H_

#define APP_UPDATE ([NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8", ITUNES_ID])
#define APP_COMMENT ([NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?mt=8&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software&id=%@", ITUNES_ID])
#define ITUNES_ID @"1061019771"

#ifdef DEBUG
#    define ATLog(...)  NSLog(__VA_ARGS__)
#else
#    define ATLog(...) /* */
#endif
#endif
