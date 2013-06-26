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

@synthesize context,signup,repImage0, repImage1,repImage2,repName0,repName1,repName2;

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
    
    parent.reps = [self fetchReps:signup.zip];

    // TODO: Something if reps are zero

    Rep *rep0 = [parent.reps objectAtIndex:0];
    NSString *repImagePath = [rep0.bioguide stringByAppendingString:@".jpg"];
    [repImage0 setImage: [UIImage imageNamed:repImagePath] ];
    [repName0 setText: rep0.name];
    
    Rep *rep1 = [parent.reps objectAtIndex:1];
    repImagePath = [rep1.bioguide stringByAppendingString:@".jpg"];
    [repImage1 setImage: [UIImage imageNamed:repImagePath] ];
    [repName1 setText: rep1.name];
    
    if( [parent.reps count] > 2 ) {

        Rep *rep2 = [parent.reps objectAtIndex:2];
        repImagePath = [rep2.bioguide stringByAppendingString:@".jpg"];
        [repImage2 setImage: [UIImage imageNamed:repImagePath] ];
        [repName2 setText: rep2.name];
    } else {
        repName2.hidden = YES;
        repImage2.hidden = YES;
    }
    
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
    
    return array;

}


@end
