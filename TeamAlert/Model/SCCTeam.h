//
//  SCCTeam.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 5/29/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SCCTeam : NSManagedObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSSet * members;

@end
