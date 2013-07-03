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

@synthesize context,signup,parent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    parent = [self tabController];

    if( buttonIndex == 0 ) {
        [parent.signup setSendTweet:@NO];
        [parent goToFinished];
    } else {
        UITextField *zip = [alertView textFieldAtIndex:0];
        parent.signup.zip = zip.text;
        [self viewDidLoad];
    }
    
}

- (void)viewDidLoad
{
    parent = [self tabController];
    context = parent.context;
    signup = parent.signup;
    
    parent.reps = [self fetchReps: signup.zip];
    
    if ( signup.twitter == nil || [signup.twitter length] < 1)
        self.message.text = [NSString stringWithFormat:@"%@ from your district asks you to cosponsor Safe Schools laws #SoundOff",signup.firstName];
    else
        self.message.text = [NSString stringWithFormat:@"@%@ from your district asks you to cosponsor Safe Schools laws #SoundOff",signup.twitter];

    if( parent.reps.count == 0 ) {
        NSString *message = [NSString stringWithFormat:@"%@ didn't work - want to enter a new one?", signup.zip];

        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:@"Can't Find Reps" message:message delegate:self cancelButtonTitle:@"Skip this" otherButtonTitles:@"Try New Zip", nil];

        passwordAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

        [passwordAlert show];
    } else {
        NSMutableArray *all_reps = [[NSMutableArray alloc] init];
        
        Rep *rep0 = [parent.reps objectAtIndex:0];
        NSString *repImagePath = [rep0.bioguide stringByAppendingString:@".jpg"];
        [self.repImage0 setImage: [UIImage imageNamed:repImagePath] ];
        [self.repName0 setText: rep0.name];
        [all_reps addObject:rep0.bioguide];
        
        Rep *rep1 = [parent.reps objectAtIndex:1];
        repImagePath = [rep1.bioguide stringByAppendingString:@".jpg"];
        [self.repImage1 setImage: [UIImage imageNamed:repImagePath] ];
        [self.repName1 setText: rep1.name];
        [all_reps addObject:rep1.bioguide];
        
        if( [parent.reps count] > 2 ) {
            Rep *rep2 = [parent.reps objectAtIndex:2];
            repImagePath = [rep2.bioguide stringByAppendingString:@".jpg"];
            [self.repImage2 setImage: [UIImage imageNamed:repImagePath] ];
            [self.repName2 setText: rep2.name];
            [all_reps addObject:rep2.bioguide];

            self.repName2.hidden = NO;
            self.repImage2.hidden = NO;
        }
        
        if( [parent.reps count] > 3 ) {
            Rep *rep3 = [parent.reps objectAtIndex:3];
            repImagePath = [rep3.bioguide stringByAppendingString:@".jpg"];
            [self.repImage3 setImage: [UIImage imageNamed:repImagePath] ];
            [self.repName3 setText: rep3.name];
            [all_reps addObject:rep3.bioguide];

            self.repName3.hidden = NO;
            self.repImage3.hidden = NO;
        }
        
        if( [parent.reps count] > 4 ) {
            Rep *rep4 = [parent.reps objectAtIndex:4];
            repImagePath = [rep4.bioguide stringByAppendingString:@".jpg"];
            [self.repImage4 setImage: [UIImage imageNamed:repImagePath] ];
            [self.repName4 setText: rep4.name];
            [all_reps addObject:rep4.bioguide];

            self.repName4.hidden = NO;
            self.repImage4.hidden = NO;
        }

        if( [parent.reps count] > 5 ) {
            Rep *rep5 = [parent.reps objectAtIndex:5];
            repImagePath = [rep5.bioguide stringByAppendingString:@".jpg"];
            [self.repImage5 setImage: [UIImage imageNamed:repImagePath] ];
            [self.repName5 setText: rep5.name];
            [all_reps addObject:rep5.bioguide];

            self.repName5.hidden = NO;
            self.repImage5.hidden = NO;
        }
        
        if( [parent.reps count] > 6 ) {
            Rep *rep6 = [parent.reps objectAtIndex:6];
            repImagePath = [rep6.bioguide stringByAppendingString:@".jpg"];
            [self.repImage6 setImage: [UIImage imageNamed:repImagePath] ];
            [self.repName6 setText: rep6.name];
            [all_reps addObject:rep6.bioguide];

            self.repName6.hidden = NO;
            self.repImage6.hidden = NO;
        }
        parent.signup.reps = [all_reps componentsJoinedByString:@","];
        [parent.context save:nil];
    }

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{

    if( [parent.reps count] > 3 )
            self.disclaimer.hidden = NO;

    if( [parent.reps count] == 4 )
        self.scrollView.frame = CGRectMake(157.0f,436.0f,710.0f,321.0f);

    if( [parent.reps count] > 4 ) {
        self.scrollView.frame = CGRectMake(157.0f,436.0f,710.0f,321.0f);

        if( [parent.reps count] == 5 )
            self.scrollView.contentSize = CGSizeMake(1100.0f, 300.0f);
        if( [parent.reps count] == 6 )
            self.scrollView.contentSize = CGSizeMake(1300.0f, 300.0f);
        if( [parent.reps count] == 7 )
            self.scrollView.contentSize = CGSizeMake(1500.0f, 300.0f);
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)sendMessage:(id)sender {
    [[self tabController] goToFinished];
}
-(IBAction)noMessage:(id)sender {
    [parent.signup setSendTweet:@NO];
    [parent goToFinished];
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
    NSArray *zipArray;
    
    if (array != nil && array.count == 1 )
    {
        foundZip = [array objectAtIndex:0];
        zipArray = [NSArray arrayWithObject:foundZip.bioguide];
    }
    else if (array != nil && array.count == 2 )
    {
        foundZip = [array objectAtIndex:0];
        Zip *foundZip2 = [array objectAtIndex:1];
        zipArray = [NSArray arrayWithObjects:foundZip.bioguide,foundZip2.bioguide,nil];
    }
    else if (array != nil && array.count == 3 )
    {
        foundZip = [array objectAtIndex:0];
        Zip *foundZip2 = [array objectAtIndex:1];
        Zip *foundZip3 = [array objectAtIndex:2];
        zipArray = [NSArray arrayWithObjects:foundZip.bioguide,foundZip2.bioguide,foundZip3.bioguide,nil];
    }
    else if (array != nil && array.count == 4 )
    {
        foundZip = [array objectAtIndex:0];
        Zip *foundZip2 = [array objectAtIndex:1];
        Zip *foundZip3 = [array objectAtIndex:2];
        Zip *foundZip4 = [array objectAtIndex:3];
        zipArray = [NSArray arrayWithObjects:foundZip.bioguide,foundZip2.bioguide,foundZip3.bioguide,foundZip4.bioguide,nil];
    }
    else if (array != nil && array.count == 5 )
    {
        foundZip = [array objectAtIndex:0];
        Zip *foundZip2 = [array objectAtIndex:1];
        Zip *foundZip3 = [array objectAtIndex:2];
        Zip *foundZip4 = [array objectAtIndex:3];
        Zip *foundZip5 = [array objectAtIndex:4];
        zipArray = [NSArray arrayWithObjects:foundZip.bioguide,foundZip2.bioguide,foundZip3.bioguide,foundZip4.bioguide,foundZip5.bioguide,nil];
    }
    else
    {
        NSLog(@"Couldn't find %@",zip);
        return zipArray;
    }

    entityDescription = [NSEntityDescription entityForName:@"Rep" inManagedObjectContext:self.context];
    [request setEntity:entityDescription];
    
    predicate = [NSPredicate
                 predicateWithFormat:@"(bioguide IN(%@) ) OR (state LIKE %@ AND district = '')",zipArray,foundZip.state];
    
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"chamber" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    array = [self.context executeFetchRequest:request error:&error];
    
    return array;

}


@end
