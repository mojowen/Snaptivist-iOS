//
//  RepsViewController.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/24/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "RepsViewController.h"

@interface RepBG : UIImageView
@end
@implementation RepBG
@end


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
    }

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
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

    if( [parent.reps count] > 2 ) {
        NSMutableArray *all_reps = [[NSMutableArray alloc] init];
        NSInteger i = 0;
        
        for( Rep *rep in parent.reps) {
            NSString *repImagePath = [rep.bioguide stringByAppendingString:@".jpg"];
            
            switch ( i ) {
                case 0: {
                    [self.repImage0 setImage: [UIImage imageNamed:repImagePath] ];
                    [self.repName0 setText: rep.name];
                    [all_reps addObject:rep.bioguide];
                    break;
                }
                case 1: {
                    [self.repImage1 setImage: [UIImage imageNamed:repImagePath] ];
                    [self.repName1 setText: rep.name];
                    [all_reps addObject:rep.bioguide];
                    break;
                }
                case 2: {
                    [self.repImage2 setImage: [UIImage imageNamed:repImagePath] ];
                    [self.repName2 setText: rep.name];
                    [all_reps addObject:rep.bioguide];
                    break;
                }
                default: {
                    UIImageView *repImage = [[UIImageView alloc] initWithFrame:self.repImage2.frame ];
                    [repImage setImage: [UIImage imageNamed:repImagePath]];
                    
                    UILabel *repLabel = [[UILabel alloc] initWithFrame:self.repName2.frame ];
                    [repLabel setText: rep.name];
                    [repLabel setBackgroundColor:[UIColor clearColor] ];
                    
                    RepBG *repBGImage = [[RepBG alloc] initWithFrame:self.repBGImage2.frame ];
                    [repBGImage setImage:self.repBGImage2.image];
                    
                    [self.scrollView addSubview:repBGImage];
                    [self.scrollView addSubview:repLabel];
                    [self.scrollView addSubview:repImage];
                    
                    [self.scrollView bringSubviewToFront:repBGImage];
                    [self.scrollView bringSubviewToFront:repLabel];
                    [self.scrollView bringSubviewToFront:repImage];

                    [repBGImage setFrame:CGRectOffset( repBGImage.frame, 200.0f * (i-2), 0.0f)];
                    [repImage setFrame:CGRectOffset( repImage.frame, 200.0f * (i-2), 0.0f)];
                    [repLabel setFrame:CGRectOffset( repLabel.frame, 200.0f * (i-2), 0.0f)];

                    break;
                }
                    
            }
            i = i + 1;
        }
        
        
        parent.signup.reps = [all_reps componentsJoinedByString:@","];
        [parent.context save:nil];
    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)sendMessage:(id)sender {
    for( id view in self.scrollView.subviews) {
        if( [view isKindOfClass:[RepBG class]] )
        {
            RepBG *bg = view;
            [bg setImage: [UIImage imageNamed: @"rep_bg_blue.png"]];
        }
    }
    [NSTimer scheduledTimerWithTimeInterval:0.3f
                                     target:self
                                   selector:@selector(nextStep)
                                   userInfo:nil
                                    repeats:NO];

}
-(void)nextStep {
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


- (void)viewDidUnload {
    [self setRepBGImage2:nil];
    [super viewDidUnload];
}
@end
