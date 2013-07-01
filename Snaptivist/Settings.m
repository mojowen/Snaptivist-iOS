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
    self.objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:5050"]];
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
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"email.length > 0"];
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

    NSMutableURLRequest *request;
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

    if( signup.photo != nil ) {
        UIImage *photo = [UIImage imageWithData:signup.photo ];
        request = [ [RKObjectManager sharedManager] multipartFormRequestWithObject:signup method:RKRequestMethodPOST path:@"/save" parameters:queryParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImagePNGRepresentation(photo)
                                        name:@"signup[photo]"
                                    fileName:@"photo.png"
                                    mimeType:@"image/png"];
        }];
    } else {
        request = [ [RKObjectManager sharedManager] requestWithObject:signup method:RKRequestMethodPOST path:@"/save" parameters:queryParams];
    }

    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager]
                                           objectRequestOperationWithRequest:request
                                           success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
//                                               [context deleteObject:signup];
                                           }
                                           failure:nil];

    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started

    
    

    
}


@end
