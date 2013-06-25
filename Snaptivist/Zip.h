//
//  Zip.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/24/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Zip : NSManagedObject

@property (nonatomic, retain) NSNumber * zip_code;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * bioguide;

@end
