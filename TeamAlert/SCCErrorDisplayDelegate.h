//
//  SCCErrorDisplayDelegate.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 9/25/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCCErrorDisplayDelegate <NSObject>

-(void)showErrorMessage:(NSString *)message;

@end
