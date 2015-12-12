//
//  ATDefines.h
//  AT
//
//  Created by AT on 14-8-3.
//  Copyright (c) 2014年 AT. All rights reserved.
//

#ifndef _ATDEFINES_H_
#define _ATDEFINES_H_


#ifdef DEBUG
#    define ATLog(...)  NSLog(__VA_ARGS__)
#else
#    define ATLog(...) /* */
#endif
#endif
