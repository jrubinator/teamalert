//
//  SCCMembership.h
//  TeamAlert
//
//  Created by Jonathan Rubin on 5/29/14.
//  Copyright (c) 2014 Soccer Coach Coach. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCCContact.h"
#import "SCCTeam.h"

@interface SCCMembership : NSManagedObject

@property (nonatomic, copy) NSString * phone;
@property (nonatomic, copy) NSString * email;

@property (nonatomic, copy) SCCContact * contact;
@property (nonatomic, copy) SCCTeam    * team;


@end
