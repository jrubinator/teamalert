//
//  SCCDebug.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 9/28/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#ifndef TeamAlert_SCCDebug_h
#define TeamAlert_SCCDebug_h

#ifdef DEBUG
#   define DLog(...) NSLog(__VA_ARGS__)
#else
#   define DLog(...)
#endif

#endif
