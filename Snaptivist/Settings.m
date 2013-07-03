//
//  Settings.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/26/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

@interface Save : NSObject

@property  NSString *success;
@property NSDictionary *signup;

@end

@implementation Save
@synthesize success,signup;

@end


#import "Settings.h"

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
    NSString *base_URL = @"http://snaptivist.herokuapp.com";
//    NSString *base_URL = @"http://192.168.2.5:5050";

    self.objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:base_URL]];


    
    RKObjectMapping *saveMapping = [RKObjectMapping mappingForClass:[Save class]];
    [saveMapping addAttributeMappingsFromDictionary:@{
     @"success" : @"success",
     @"signup" : @"signup"
     }];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:saveMapping
                                                                                        pathPattern:nil
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:responseDescriptor];
    

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
    NSMutableDictionary *signupParams = [NSMutableDictionary
                                  dictionaryWithObjectsAndKeys:
                                  signup.firstName,@"firstName",
                                  signup.lastName, @"lastName",
                                  signup.email,@"email",
                                  signup.twitter, @"twitter",
                                  signup.zip, @"zip",
                                  signup.photo_date, @"photo_date",
                                  signup.sendTweet, @"sendTweet",
                                  nil];
    if( signup.friends != nil )
        [signupParams setObject:signup.friends forKey:@"friends"];

    if( signup.reps != nil )
        [signupParams setObject:signup.reps forKey:@"reps"];

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

                                               Save *latest = [result firstObject];
                                               if( [latest.success isEqualToString:@"true"] )
                                                   [context deleteObject:signup];
                                               NSLog(@"%@", latest.success);
                                               NSLog(@"%@", latest.signup);
               
                                           }
                                           failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                               NSLog(@"%@",error);
                                           }];

    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started

    
    

    
}


@end
