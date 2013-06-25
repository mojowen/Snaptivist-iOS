//
//  RepsViewController.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/24/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "RepsViewController.h"

@interface RepsViewController ()

@end

@implementation RepsViewController

@synthesize context,signup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    SnaptivistTabs *parent = [self tabController];
    context = parent.context;
    signup = parent.signup;
    
    [self fetchReps:signup.zip];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}

-(NSArray *)fetchReps:(NSString *)zip {
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Zip" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"zip_code like %@",zip];

    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [self.context executeFetchRequest:request error:&error];

    Zip *foundZip;
    
    if (array != nil && array.count != 0 )
    {
        foundZip = [array objectAtIndex:0];
    }
    else
    {
        NSLog(@"Could not find zip %@",zip);
    }

    entityDescription = [NSEntityDescription entityForName:@"Rep" inManagedObjectContext:self.context];
    [request setEntity:entityDescription];
    
    predicate = [NSPredicate
                 predicateWithFormat:@"(bioguide = %@) OR (state LIKE %@ AND district = '')",foundZip.bioguide,foundZip.state];
    
    [request setPredicate:predicate];
    
    array = [self.context executeFetchRequest:request error:&error];

    NSLog(@"reps are %@",array);
    
    return array;

}


@end
