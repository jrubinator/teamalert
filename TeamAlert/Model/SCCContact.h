//
//  SCCContact.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 5/29/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SCCContact : NSManagedObject

@property (nonatomic) int recordID;
@property (nonatomic, copy) NSString * firstName;
@property (nonatomic, copy) NSString * lastName;

@property (nonatomic, copy) NSSet * memberships;

@end
