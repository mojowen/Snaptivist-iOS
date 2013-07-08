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

@synthesize context,signup,parent,reps;


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    parent = [self tabController];

    if( buttonIndex == 0 ) {
        [parent.signup setSendTweet:@NO];
        [parent goToFinished];
    } else {
        UITextField *zip = [alertView textFieldAtIndex:0];
        parent.signup.zip = zip.text;
        [self viewDidLoad];
        [self setReps];
    }
    
}

- (void)viewDidLoad
{
    parent = [self tabController];
    context = parent.context;
    signup = parent.signup;
    
    reps = [self fetchReps: signup.zip];
    self.header.text = [NSString stringWithFormat:@"3. Sweet. Now let‘s tweet at the reps & senators for zipcode %@",signup.zip];
    
    if ( signup.twitter == nil || [signup.twitter length] < 1)
        self.message.text = [NSString stringWithFormat:@"@congress %@ from your district asks you to sponsor Safe Schools #MostNights #SoundOff",signup.firstName];
    else
        self.message.text = [NSString stringWithFormat:@"@congress @%@ from your district asks you to sponsor Safe Schools #MostNights #SoundOff",signup.twitter];

    if( reps.count < 2 ) {
        NSString *message = [NSString stringWithFormat:@"%@ didn't work - want to enter a new one?", signup.zip];

        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:@"Can't Find Reps" message:message delegate:self cancelButtonTitle:@"Skip this" otherButtonTitles:@"Try New Zip", nil];

        passwordAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

        [passwordAlert show];
    }

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{

    [self setReps];
}
-(void)unload {
    self.repImage0 = nil;
    self.repImage1 = nil;
    self.repImage2 = nil;
    self.repName0 = nil;
    self.repName1 = nil;
    self.repName2 = nil;
    self.repBGImage1 = nil;
    self.repBGImage1 = nil;
    self.signup = nil;
}
- (void)didReceiveMemoryWarning
{
    [self unload];
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
    [parent.signup setSendTweet:@YES];
    [NSTimer scheduledTimerWithTimeInterval:0.3f
                                     target:self
                                   selector:@selector(nextStep)
                                   userInfo:nil
                                    repeats:NO];

}
-(void)nextStep {
    [self unload];
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
-(void)setReps {
    if( [reps count] == 4 )
        self.scrollView.frame = CGRectMake(60.0f,436.0f,920.0f,321.0f);
    
    if( [reps count] > 4 ) {
        self.scrollView.frame = CGRectMake(60.0f,436.0f,920.0f,321.0f);
        
        if( [reps count] == 5 )
            self.scrollView.contentSize = CGSizeMake(1100.0f, 300.0f);
        if( [reps count] == 6 )
            self.scrollView.contentSize = CGSizeMake(1260.0f, 300.0f);
        if( [reps count] == 7 )
            self.scrollView.contentSize = CGSizeMake(1500.0f, 300.0f);
    }
    
    if( [reps count] >= 2 ) {
        NSMutableArray *all_reps = [[NSMutableArray alloc] init];
        NSInteger i = 0;
        
        for( Rep *rep in reps) {
            NSString *repImagePath = [rep.bioguide stringByAppendingString:@".jpg"];
            [all_reps addObject:rep.bioguide];
            
            switch ( i ) {
                case 0: {
                    [self.repImage0 setImage: [UIImage imageNamed:repImagePath] ];
                    [self.repName0 setText: rep.name];
                    break;
                }
                case 1: {
                    [self.repImage1 setImage: [UIImage imageNamed:repImagePath] ];
                    [self.repName1 setText: rep.name];
                    break;
                }
                case 2: {
                    [self.repImage2 setImage: [UIImage imageNamed:repImagePath] ];
                    [self.repName2 setText: rep.name];
                    break;
                }
                default: {
                    UIImageView *repImage = [[UIImageView alloc] initWithFrame:self.repImage2.frame ];
                    [repImage setImage: [UIImage imageNamed:repImagePath]];
                    
                    UILabel *repLabel = [[UILabel alloc] initWithFrame:self.repName2.frame ];
                    [repLabel setText: rep.name];
                    [repLabel setBackgroundColor:[UIColor clearColor] ];
                    [repLabel setTextColor: self.repName2.textColor];
                    [repLabel setTextAlignment: self.repName2.textAlignment];
                    [repLabel setFont: self.repName2.font];
                    [repLabel setAdjustsFontSizeToFitWidth: self.repName2.adjustsFontSizeToFitWidth];
                    [repLabel setAdjustsLetterSpacingToFitWidth: self.repName2.adjustsLetterSpacingToFitWidth ];
                    
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
        if( [reps count] < 3 ) {
            self.repBGImage2.hidden =YES;
            self.repImage2.hidden = YES;
            self.repName2.hidden = YES;
            [self.repName1 setFrame:CGRectOffset( self.repName1.frame, 200.0f, 0.0f)];
            [self.repImage1 setFrame:CGRectOffset( self.repImage1.frame, 200.0f, 0.0f)];
            [self.repBGImage1 setFrame:CGRectOffset( self.repBGImage1.frame, 200.0f, 0.0f)];
        }
        
        parent.signup.reps = [all_reps componentsJoinedByString:@","];
    }
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
