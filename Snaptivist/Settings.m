//
//  Settings.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/26/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//
#import "Settings.h"
#import "SignupCell.h"

@interface Settings ()


@end

@implementation Settings

@synthesize s3,context,signups,outstandingSync,nextToSync,readyToSync;

- (void)viewDidLoad
{
    context = [[self appDelegate] managedObjectContext];

    self.noPhoto = NO;

    [self loadSignups];
    [self setUpPicker];
    readyToSync = [[NSMutableArray alloc] init];

    [self.collectionView setBackgroundColor:[UIColor clearColor]];

    [self launchReachability];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)noPhotoSync:(id)sender {
    self.noPhoto = YES;
    [self disableSync];
    self.errors.hidden = NO;
    self.errors.text = @"Syncing without photos - signups will be deleted from the app but still available as photos";
    [self.syncButton sendActionsForControlEvents: UIControlEventTouchUpInside];
}
-(IBAction)syncNow:(id)sender {

    [self disableSync];

    if( [readyToSync count] == 0 )
        readyToSync = [self.signups mutableCopy];

    outstandingSync = [readyToSync count];
    self.errors.text = nil;
    NSArray *batchOfSignups;
    int batch_size = 5;
    
    if( outstandingSync > batch_size ) {
        outstandingSync = [readyToSync count];
        batchOfSignups  = [readyToSync subarrayWithRange:NSMakeRange(0,batch_size)];
        nextToSync = batch_size;
    } else{
        batchOfSignups = [readyToSync copy];
        nextToSync = -1;
    }

    for (Signup *signup in batchOfSignups) {
        [self saveSignup:signup];
    }
}
-(void)disableSync {
    self.noPhotoSync.enabled = NO;
    self.syncButton.enabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.syncDisabled = YES;
    [self.myPickerView setUserInteractionEnabled:NO];
    [self.syncButton setAlpha:0.3f];
    [self.myPickerView setAlpha:0.3f];

}
-(void)enableSync {
    self.noPhotoSync.enabled = YES;
    self.syncButton.enabled = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    self.syncDisabled = NO;
    self.noPhoto = NO;
    [self.myPickerView setUserInteractionEnabled:YES];
    [self.syncButton setAlpha:1.0f];
    [self.myPickerView setAlpha:1.0f];
}
-(void)launchReachability {
    
    Reachability *reach = [Reachability reachabilityWithHostname:[ [ [BASE_URL
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

    [request setFetchLimit:15];
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
        self.noPhotoSync.hidden = NO;

    } else {
        self.numberOfSignups.text = @"No Singups";
    }
    
}
-(SignupCell *)getSignupCell:(Signup *)signup {
    NSIndexPath *index = [NSIndexPath indexPathForRow:[signups indexOfObject:signup] inSection:0];
    return (SignupCell *)[self.collectionView cellForItemAtIndexPath:index];
}
- (IBAction)removeSettings:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)deleteSignup:(Signup *)signup {
    SignupCell *cell = [self getSignupCell:signup];
    [context deleteObject:signup];
    [context save:nil];
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
        [self.syncButton setTitle:@"Sync All" forState:UIControlStateNormal];
    }
}
-(void)errorSignup:(Signup *)signup {
    SignupCell *cell = [self getSignupCell:signup];
    [cell setErrorState];
}
-(void)startSavingSingup:(Signup *)signup {
    SignupCell *cell = [self getSignupCell:signup];
    NSLog(@"syn starting");
    [cell setSyncState];
}
-(void)s3Upload:(Signup *)signup {
    NSLog(@"Amazon uploading");
    
    if( s3 == nil)
        s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    
    NSString *photoName = [NSString stringWithFormat:@"%@_%@_%@.png",signup.firstName,signup.lastName,signup.photo_date];
    NSData *imageData = signup.photo;
    
    s3.endpoint = [AmazonEndpoints s3Endpoint:US_EAST_1];
    
    // Upload image data.  Remember to set the content type.
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey: photoName
                                                             inBucket:PICTURE_BUCKET];
    por.contentType = @"image/png";
    

    // Convert the image to JPEG data.

    por.data = imageData;
    
    // Put the image data into the specified s3 bucket and object.
    S3PutObjectResponse *response  = [s3 putObject:por];
    if ([response isFinishedLoading]) {
        
        S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
        gpsur.key                     = photoName;
        gpsur.bucket                  = PICTURE_BUCKET;
        gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600 * 24 ];
        
        NSError *error;
        signup.photo_path = [NSString stringWithFormat:@"%@",[self.s3 getPreSignedURL:gpsur error:&error] ];

        if( signup.photo_path == nil || error != nil) {
            [self errorSignup:signup];
            self.errors.text = @"Some errors on the last sync";
            self.errors.hidden = NO;
        } else {
         [self postSignup:signup];
        }
    } else {
        [self errorSignup:signup];
        self.errors.text = @"Some errors on the last sync";
        self.errors.hidden = NO;
    }
    
}
-(void)saveSignup:(Signup *)signup {
    [self startSavingSingup:signup];
    NSLog(@"starting to save a signup");
    if( signup.photo == nil )
        [self postSignup:signup];
    else
        [self s3Upload:signup];
}
-(void)postSignup:(Signup*)signup {
    NSLog(@"Posting signup");

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

    if( signup.reps != nil )
        [signupParams setObject:signup.photo_path forKey:@"photo_path"];
    
    NSLog(@"Posting signup %@",signup.photo_path);

    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:signupParams,@"signup", nil];

    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    [objectManager.HTTPClient setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    NSLog(@"%@",queryParams);
    [objectManager.HTTPClient
         postPath:@"/save"
        parameters:queryParams
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self deleteSignup:signup];
        }
        failure:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self errorSignup:signup];
            [self finishedSync];
            
            self.errors.text = @"Some errors on the last sync";
            self.errors.hidden = NO;
        }
     ];
    
}
-(int)addToSet:(Signup *)signup {
    [readyToSync addObject:signup];
    [self.syncButton setTitle:[NSString stringWithFormat:@"Sync %lu",(unsigned long)[readyToSync count]] forState:UIControlStateNormal];
    return [readyToSync count] -1;
}
 -(void)removeFromSet:(int)signup {
     [readyToSync removeObjectAtIndex:signup];
     
     if( [readyToSync count] == 0 )
         [self.syncButton setTitle:@"Sync All" forState:UIControlStateNormal];
     else
         [self.syncButton setTitle:[NSString stringWithFormat:@"Sync %lu",(unsigned long)[readyToSync count]] forState:UIControlStateNormal];

 }

// Picker stuff
#pragma mark -
#pragma mark UIPickerViewDataSource
-(void)setUpPicker {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tour_dates" ofType:@"txt"];
    NSString *fh = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:NULL];
    self.events = [fh componentsSeparatedByString:@"\n"];
    self.myPickerView.showsSelectionIndicator = YES;
    int i = -1;

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [format setDateFormat:@"MM/dd/yyyy"];
    [format setLocale:usLocale];
    NSDate *today =[NSDate date];

    for (NSString *event in self.events) {
        NSArray *eventSplit = [event componentsSeparatedByString:@"\t"];
        NSDate *date = [format dateFromString: [eventSplit objectAtIndex:0]];

        if( [date compare:today] == NSOrderedDescending )
            break;
        i++;
    }
    if( i < 0 )
        i = 0;
    [self.myPickerView selectRow:i inComponent:0 animated:YES];
    self.event = [self.events objectAtIndex:i];
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

    if( cell.signup.photo == nil )
        [cell.photo setImage:[UIImage imageNamed:@"user-placeholder.png"] forState:UIControlStateNormal];
    else
        [cell.photo setImage:[UIImage imageWithData:cell.signup.photo scale:0.05f] forState:UIControlStateNormal];

    [cell setBackgroundColor:[UIColor redColor]];
    
    cell.label.text = [NSString stringWithFormat:@"%@",cell.signup.firstName];

    return cell;
}




@end

