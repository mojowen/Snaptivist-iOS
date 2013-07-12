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

@synthesize s3,context,signups,outstandingSync,readyToSync,keepSyncing,limit,loadedSignups,totalSignups;

- (void)viewDidLoad
{
    context = [[self appDelegate] managedObjectContext];

    self.noPhoto = NO;
    limit = 100;

    self.numberOfSignups.text = @"Loading...";
    signups = [[NSMutableArray alloc] init];
    readyToSync = [[NSMutableArray alloc] init];
    
    [self setUpPicker];

    [self.collectionView setBackgroundColor:[UIColor clearColor]];

    [self launchReachability];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated {
    [self.activity startAnimating];

    [self loadSignups];
    [self.activity stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendEmail:(id)sender {
    [self displayComposerSheet];
}
-(IBAction)noPhotoSync:(id)sender {
    self.noPhoto = YES;
    [self disableSync];
    self.errors.hidden = NO;
    self.errors.text = @"Syncing without photos - signups will be deleted from the app but still available as photos";
    [self.syncButton sendActionsForControlEvents: UIControlEventTouchUpInside];
}
- (IBAction)removeRepsZips:(id)sender {
    [[self appDelegate] clearZipRepStore];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                          message:@"We've reloaded all of the reps and zips"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    [myAlertView show];
}
-(IBAction)syncNow:(id)sender {
    [self disableSync];
    [self beginSync];
}
-(void)beginSync {
    if( [readyToSync count] == 0 ) {
        readyToSync = [self.signups mutableCopy];
//        keepSyncing = YES;
    }

    outstandingSync = [readyToSync count];
    self.errors.text = nil;
    NSArray *batchOfSignups;
    int batch_size = 5;
    

    if( outstandingSync > batch_size ) {
        outstandingSync = [readyToSync count];
        batchOfSignups  = [readyToSync subarrayWithRange:NSMakeRange(0,batch_size)];
    } else{
        batchOfSignups = [readyToSync copy];
    }
    
    for (Signup *signup in batchOfSignups) {
        [self saveSignup:signup];
    }

}
-(void)disableSync {
    self.noPhotoSync.enabled = NO;
    self.syncButton.enabled = NO;
    [self.activity startAnimating];
    
    self.syncDisabled = YES;
    [self.myPickerView setUserInteractionEnabled:NO];
    [self.syncButton setAlpha:0.3f];
    [self.myPickerView setAlpha:0.3f];

}
-(void)enableSync {
    self.noPhotoSync.enabled = YES;
    self.syncButton.enabled = YES;
    [self.activity stopAnimating];

    self.syncDisabled = NO;
    self.noPhoto = NO;
    
    [self.syncButton setTitle:@"Sync All" forState:UIControlStateNormal];
    [readyToSync removeAllObjects];
    [self.myPickerView setUserInteractionEnabled:YES];
    [self.syncButton setAlpha:1.0f];
    [self.myPickerView setAlpha:1.0f];
}


#pragma mark - Private methods
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(void)loadSignups {
    if( [signups count] <  limit ) {
        [self.activity startAnimating];
        
        NSFetchRequest *request = [self createSigupRequest];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"photo_date" ascending:NO];
        [request setSortDescriptors:@[sortDescriptor]];
        
                
        [request setFetchLimit:limit - [signups count] ];
        [request setFetchOffset: [signups count]];
        
        NSLog(@"Loading %d ",limit - [signups count]);
        
        NSError *error;
        NSArray *array = [self.context executeFetchRequest:request error:&error];
        
        if (array != nil ) {
            [signups addObjectsFromArray:array];
            [self.collectionView reloadData];
            

            [self updateLabelFromDB];

            self.syncButton.hidden = NO;
            self.noPhotoSync.hidden = NO;
            
        } else {
            self.numberOfSignups.text = @"No Singups";
        }
        [self.activity stopAnimating];
    }
}
-(NSFetchRequest *)createSigupRequest {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Signup" inManagedObjectContext:self.context];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@" email.length > 0 "];
    [request setPredicate:predicate];
    return request;
}
-(void)updateLabelFromDB {
    totalSignups = [self countSignups];
    loadedSignups = [signups count];
    [self updateLabel:loadedSignups withTotal:totalSignups];
}
-(void)decreaseLabel {
    totalSignups += -1;
    loadedSignups += -1;
    [self updateLabel:loadedSignups withTotal:totalSignups];
}
-(void) updateLabel:(int)theLoadedSignups withTotal: (int)theTotalSignups  {
    NSString *label;
    if( theLoadedSignups == 1 )
        label = [NSString stringWithFormat: @"%d Sign Up", theLoadedSignups];
    else if ( totalSignups < limit )
        label = [NSString stringWithFormat: @"%d Sign Ups", theLoadedSignups];
    else
        label = [NSString stringWithFormat: @"%d/%d Sign Ups",theLoadedSignups,theTotalSignups];
    
    self.numberOfSignups.text = label;
}
-(int)countSignups {
    return [self.context countForFetchRequest:[self createSigupRequest] error:nil];
}
-(SignupCell *)getSignupCell:(int)pos {
    NSIndexPath *index = [NSIndexPath indexPathForRow:pos inSection:0];
    return (SignupCell *)[self.collectionView cellForItemAtIndexPath:index];
}
- (IBAction)removeSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(Signup *)getNextSignup {
    return _.find(readyToSync, ^BOOL (Signup *signup) { return ! signup.isSyncing; } );
}
-(void)deleteSignup:(Signup *)signup {

    NSUInteger index = _.indexOf( signups, signup);
    NSUInteger ready_index = _.indexOf( readyToSync, signup);
    [[self getSignupCell:index] hideFromView];

    [context deleteObject:signup];
    [context save:nil];
    
    NSLog(@"delete being called on %@",signup.firstName);
    if( signup.isSyncing )
        [readyToSync removeObjectAtIndex:ready_index];
    else
        [signups removeObjectAtIndex:index];

    [self decreaseLabel];
}
-(void)finishedSync {
    Signup *nextToSync = [self getNextSignup];

    if( nextToSync != nil ) {
        [self saveSignup:nextToSync];
    }

    outstandingSync--;


    NSLog(@"outstanding sync %u",outstandingSync);
    
    if( outstandingSync < 1 && keepSyncing ) {
        [self loadSignups];
        if( [signups count] == 0 ) {
            keepSyncing = NO;
            [self enableSync];
        } else {
            [self beginSync];
        }
    } else if ( outstandingSync < 1 ) {
        signups = [_.filter( signups, ^BOOL (Signup *signup) { return ! signup.isSyncing && signup.firstName != nil; } ) mutableCopy];
        [self enableSync];
        [self loadSignups];
    }
}
-(void)errorSignup:(Signup *)signup {

    signup.isSyncing = NO;
    signup.didError = YES;
    NSUInteger index = _.indexOf( signups, signup);
    SignupCell *cell = [self getSignupCell:index];
    [cell setErrorState];

    NSLog(@"error signup calld on %@",signup);
    
    NSUInteger ready_index = _.indexOf( readyToSync, signup);
    [readyToSync removeObjectAtIndex:ready_index];
}
-(void)s3Upload:(Signup *)signup {
    NSLog(@"Amazon uploading");
    
    if( s3 == nil)
        s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    
    NSString *photoName = [signup fileName];

    NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:signup.photo_path];
    
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
    signup.isSyncing = YES;

    NSUInteger index = _.indexOf( signups, signup);
    [[self getSignupCell:index] setSyncState];

    if( signup.photo_path == nil || self.noPhoto )
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

    if( signup.photo_path != nil )
        [signupParams setObject:signup.photo_path forKey:@"photo_path"];
    
    NSLog(@"Posting signup %@",signup.photo_path);

    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:signupParams,@"signup", nil];

    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    [objectManager.HTTPClient setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    NSLog(@"%@",queryParams);
    [objectManager.HTTPClient
         postPath:@"/save"
        parameters:queryParams
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self deleteSignup:signup];
                [self finishedSync];
        }
        failure:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"post errors %@",signup.firstName);
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
 -(void)removeFromSet:(Signup *)signup {
     if( [readyToSync count] != 0 ) {

         NSUInteger index = _.indexOf( readyToSync, signup);

         [readyToSync removeObjectAtIndex:index];
         
         if( [readyToSync count] == 0 )
             [self.syncButton setTitle:@"Sync All" forState:UIControlStateNormal];
         else
             [self.syncButton setTitle:[NSString stringWithFormat:@"Sync %lu",(unsigned long)[readyToSync count]] forState:UIControlStateNormal];
     }

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
    // If you want to add additional styles to cell states - do it in cell clearState method
    return [cell initializeCellwithParent:self andSignup: [signups objectAtIndex:indexPath.row]];
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
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}
-(void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"Backup of Signups"];
    
    // Set up recipients
    // NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
    // NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    // NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
    
    // [picker setToRecipients:toRecipients];
    // [picker setCcRecipients:ccRecipients];
    // [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *logFile = [NSString stringWithFormat:@"%@/all_signups.txt",documentsDirectory];

    NSData *myData = [NSData dataWithContentsOfFile:logFile];
    [picker addAttachmentData:myData mimeType:@"text/plain" fileName:@"all_signups.txt"];
    
    // Fill out the email body text
    NSString *emailBody = @"All Signups on This iPad, tab separated";
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentModalViewController:picker animated:YES];
}

- (void)viewDidUnload {
    [self setActivity:nil];
    [self setSignups:nil];
    [self setEvents:nil];
    [self setReadyToSync:nil];
    [super viewDidUnload];
}
@end

