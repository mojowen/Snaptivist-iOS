//
//  SnaptivistTabs.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "SnaptivistTabs.h"

@implementation SnaptivistTabs

@synthesize context,signup;

-(void)viewDidLoad {
    
    context = [[self appDelegate] managedObjectContext];

    // Am going to need to move this object up - probably to tabs object
    signup = [NSEntityDescription insertNewObjectForEntityForName:@"Signup" inManagedObjectContext:context];

    [super viewDidLoad];
}

#pragma mark - Private methods
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
