//
//  Settings.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/26/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//
#import "Settings.h"
#import "SignupCell.h"
#import "Save.h"

@interface Settings ()


@end

@implementation Settings

@synthesize context,signups,outstandingSync,nextToSync;

- (void)viewDidLoad
{
    context = [[self appDelegate] managedObjectContext];
    NSString *base_URL = @"http://snaptivist.herokuapp.com";
//    NSString *base_URL = @"http://192.168.2.5:5050";
    
    
    Reachability *reach = [Reachability reachabilityWithHostname:[ [ [base_URL
                                                                      stringByReplacingOccurrencesOfString:@"http://"
                                                                      withString:@""]
                                                                    componentsSeparatedByString:@":"]
                                                                  objectAtIndex:0]];

    // set the blocks
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@" unreachable");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self disableSync];
            self.errors.text = @"No connection detected";
            self.errors.hidden = NO;
        });
    };
    
    reach.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@" reachable");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enableSync];
            self.errors.hidden = YES;
            self.errors.text = nil;
        });
    };
    
    // start the notifier which will cause the reachability object to retain itself!
    [reach startNotifier];
    
    
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
    [self setUpPicker];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)syncNow:(id)sender {

    [self disableSync];
    outstandingSync = [signups count];
    self.errors.text = nil;
    NSArray *batchOfSignups;

    if( outstandingSync > 10 ) {
        batchOfSignups  = [signups subarrayWithRange:NSMakeRange(0,10)];
        nextToSync = 10;
    } else{
        batchOfSignups = [signups copy];
        nextToSync = -1;
    }

    for (Signup *signup in batchOfSignups) {
        [self saveSignup:signup];
    }
}
-(void)disableSync {
    self.syncButton.enabled = NO;
    self.syncDisabled = YES;
    [self.myPickerView setUserInteractionEnabled:NO];
    [self.syncButton setAlpha:0.3f];
    [self.myPickerView setAlpha:0.3f];

}
-(void)enableSync {
    self.syncButton.enabled = YES;
    self.syncDisabled = NO;
    [self.myPickerView setUserInteractionEnabled:YES];
    [self.syncButton setAlpha:1.0f];
    [self.myPickerView setAlpha:1.0f];
}
#pragma mark - Private methods
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(void)loadSignups {
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Signup" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"photo_date" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];

    [request setEntity:entityDescription];
            
    NSError *error;
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"email.length > 0"];
    array = [array filteredArrayUsingPredicate:bPredicate];
    if (array != nil ) {
        signups = array;
        [self.collectionView reloadData];

        NSString *label;
        if( array.count == 1 )
            label = [NSString stringWithFormat: @"%lu Sign Up", (unsigned long)[signups count]];
        else
            label = [NSString stringWithFormat: @"%lu Sign Ups", (unsigned long)[signups count]];
        
        self.numberOfSignups.text = label;
        self.syncButton.hidden = NO;
    } else {
        self.numberOfSignups.text = @"No Singups";
    }
    
}
-(SignupCell *)getSignupCell:(Signup *)signup {
    NSIndexPath *index = [NSIndexPath indexPathForRow:[signups indexOfObject:signup] inSection:0];
    return (SignupCell *)[self.collectionView cellForItemAtIndexPath:index];
}
-(void)deleteSignup:(Signup *)signup {
    SignupCell *cell = [self getSignupCell:signup];
    [context deleteObject:signup];
    [cell removeFromSuperview];
    [cell clearState];
}
-(void)finishedSync {
    
    if( nextToSync != -1 && nextToSync < [signups count ] ) {
        [self saveSignup:(Signup *)[signups objectAtIndex: nextToSync]];
        NSLog(@"Syncing %u named %@",nextToSync, ((Signup *)[signups objectAtIndex: nextToSync]).firstName);
        nextToSync++;
    }
    else {
        nextToSync = -1;
    }

    outstandingSync--;
    NSLog(@"outstanding sync %u",outstandingSync);
    
    if( outstandingSync < 1 ) {
        [self enableSync];
        [self loadSignups];
    }
}
-(void)errorSignup:(Signup *)signup {
    SignupCell *cell = [self getSignupCell:signup];
    [cell setErrorState];
}
-(void)startSavingSingup:(Signup *)signup {
    SignupCell *cell = [self getSignupCell:signup];
    [cell setSyncState ];
}
-(void)saveSignup:(Signup *)signup {
    [self startSavingSingup:signup];

    NSMutableURLRequest *request;
    NSMutableDictionary *signupParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             signup.firstName,@"firstName",
                                             signup.lastName, @"lastName",
                                             signup.email,@"email",
                                             signup.twitter, @"twitter",
                                             signup.zip, @"zip",
                                             signup.photo_date, @"photo_date",
                                             signup.sendTweet, @"sendTweet",
                                             self.event, @"event",
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
                                               if( [latest.success isEqualToString:@"true"] ) {
                                                   [self deleteSignup:signup];
                                               } else {
                                                   [self errorSignup:signup];
                                                   self.errors.text = @"Some errors on the last sync";
                                                   self.errors.hidden = NO;
                                               }
                                              [self finishedSync];
                                               //NSLog(@"%@", latest.success);
             //                                  NSLog(@"%@", latest.signup);
               
                                           }
                                           failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                               [self errorSignup:signup];
                                               [self finishedSync];

                                               self.errors.text = @"Some errors on the last sync";
                                               self.errors.hidden = NO;
                                             //  NSLog(@"%@", error);
                                           }];

    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
    
}


// Picker stuff
#pragma mark -
#pragma mark UIPickerViewDataSource
-(void)setUpPicker {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tour_dates" ofType:@"txt"];
    NSString *fh = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:NULL];
    self.events = [fh componentsSeparatedByString:@"\n"];
    self.myPickerView.showsSelectionIndicator = YES;
//    NSInteger i = 3;
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"MM/dd/yyyy"];
//
//    for (NSString *event in self.events) {
//        NSArray *eventSplit = [event componentsSeparatedByString:@"\t"];
//        NSDate *date = [format dateFromString: [eventSplit objectAtIndex:0]];
//        NSDate *today =[NSDate date];
//
//        if( date > today )
//            break;
//        i = i +1;
//    }
//    
//    [self.myPickerView selectRow:i inComponent:0 animated:YES];
    self.event = [self.events objectAtIndex:0];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.events objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.events count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.event = [self.events objectAtIndex:[pickerView selectedRowInComponent:0]];
}


// Cell View Stuff

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [signups count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"cell";

    SignupCell *cell = [cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.parent = self;
    cell.signup = [signups objectAtIndex:indexPath.row];

    
    if( cell.signup.photo != nil ) {
        [cell.photo setImage:[UIImage imageWithData:cell.signup.photo scale:0.05f] forState:UIControlStateNormal];
    } else {
        [cell.photo setImage:[UIImage imageNamed:@"user-placeholder.png"] forState:UIControlStateNormal];
    }
    
    [cell setBackgroundColor:[UIColor redColor]];
    
    cell.label.text = [NSString stringWithFormat:@"%@",cell.signup.firstName];

    return cell;
}



@end

