//
//  Settings.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/26/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "Settings.h"
#import "Signup.h"

@interface Settings ()

@end

@implementation Settings

@synthesize context,signups;

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
    context = [[self appDelegate] managedObjectContext];
    [self loadSignups];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)syncNow:(id)sender {

    self.syncButton.hidden = YES;
    int count = 1;

    for (Signup *signup in signups) {
        [self saveSoundOff:signup];
        NSString *label = [NSString stringWithFormat: @"Saving %u of %lu...", count, (unsigned long)[signups count]];
        self.numberOfSignups.text = label;
        count += 1;
    }
    self.numberOfSignups.text = @"Synced";
}

#pragma mark - Private methods
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(void)loadSignups {
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Signup" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
            
    NSError *error;
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"email.lenght > 0"];
    array = [array filteredArrayUsingPredicate:bPredicate];
    if (array != nil && array.count != 0 ) {
        signups = array;
        NSString *label = [NSString stringWithFormat: @"%lu Sign Ups", (unsigned long)[signups count]];
        
        self.numberOfSignups.text = label;
        self.syncButton.hidden = NO;
    } else {
        self.numberOfSignups.text = @"No signups to sync";
    }
    NSError *saveError = nil;
    [context save:&saveError];
}
-(void)saveSoundOff:(Signup *)signup {
    
    NSDictionary *signupParams = [NSDictionary
                   dictionaryWithObjectsAndKeys:
                        signup.firstName,@"firstName",
                        signup.lastName, @"lastName",
                        signup.email,@"email",
                        signup.twitter, @"twitter",
                        signup.friends, @"friends",
                        signup.zip, @"zip",
                        nil];

    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:signupParams,@"signup", nil];

    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:5050"]];
    
    [objectManager.HTTPClient setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [objectManager.HTTPClient
         postPath:@"/save"
         parameters:queryParams
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [context deleteObject:signup];
         }
         failure:^(AFHTTPRequestOperation *operation, id responseObject) {
         }
     ];
}


@end
