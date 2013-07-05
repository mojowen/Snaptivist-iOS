//
//  SnaptivistTabs.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "SnaptivistTabs.h"
#import "mach/mach.h"

@implementation SnaptivistTabs

@synthesize context,signup,photosViewController,formViewController,finishedViewController,repsViewController,activeImage,inactiveImage,activeButton;

-(void)viewDidLoad {

    
    activeImage = [UIImage imageNamed:@"sidenav_active.png"];
    inactiveImage = [UIImage imageNamed:@"sidenav_inactive.png"];
    
    [self getStarted];
    
    [super viewDidLoad];

}
-(void)getStarted {
    context = [[self appDelegate] managedObjectContext];

    signup = [NSEntityDescription insertNewObjectForEntityForName:@"Signup" inManagedObjectContext:context];
    signup.photo_date = [NSDate date];
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                  bundle:nil];
    photosViewController = [sb instantiateViewControllerWithIdentifier:@"PhotosViewController"];
    formViewController = [sb instantiateViewControllerWithIdentifier:@"FormViewController"];
    repsViewController = [sb instantiateViewControllerWithIdentifier:@"RepsViewController"];
    finishedViewController = [sb instantiateViewControllerWithIdentifier:@"FinishedViewController"];
    
    [self addChildViewController:photosViewController];
    [self addChildViewController:formViewController];
    [self addChildViewController:repsViewController];
    [self addChildViewController:finishedViewController];
    
    activeButton = self.photosButton;
    
    NSLog(@"Loading snaptivist tabs");


}
-(void)startOver{
    [activeButton setBackgroundImage:inactiveImage forState:UIControlStateNormal];

    NSLog(@"begin start over");
    [self logMemUsage];

    signup = nil;
    
    [photosViewController removeFromParentViewController];
    [repsViewController removeFromParentViewController];
    [formViewController removeFromParentViewController];
    [finishedViewController removeFromParentViewController];
    finishedViewController = nil;
    formViewController = nil;
    repsViewController = nil;
    photosViewController = nil;

    NSLog(@"after removing view controllers");
    [self logMemUsage];

    [self getStarted];
    [self goToPhoto];
    
    NSLog(@" after getstarted");
    [self logMemUsage];

}

// Commands for changing tabs - includes validation logic for moving between sections
-(void)goToPhoto {
    [self setChildFrame:photosViewController];
    [self setButton:self.photosButton];
    self.allyLogo.hidden = NO;
}
-(void)goToForm {
    [self setChildFrame:formViewController];
    [self setButton:self.formButton];
    self.allyLogo.hidden = NO;
}
-(void)goToReps {
    self.allyLogo.hidden = NO;
    if( [signup.zip length] > 4 ) {
        if( [signup.zip length ] != 5 && [signup.email length ] > 1 )
        {
            [signup setSendTweet:@NO];
            [self goToFinished];
        }
        else
        {
            [self setChildFrame:repsViewController];
            [self setButton:self.repsButton];
        }
    } else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"No Zip - No Reps!"
                                                              message:@"You need to enter a valid zip code to see your representatives"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
        [self goToForm];
    }
}
-(void)goToFinished {
    if( [signup.email length] > 1 ) {
        [self setChildFrame:finishedViewController];
        [self setButton:self.finishedButton];
        self.allyLogo.hidden = YES;
    } else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"No Email!"
                                                              message:@"We can't sign you up without an email..."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
        [self goToForm];
    }
}
-(void)hideButtons {
    self.photosButton.hidden = YES;
    self.formButton.hidden = YES;
    self.repsButton.hidden = YES;
    self.finishedButton.hidden = YES;
}
-(void)showButtons {
    self.photosButton.hidden = NO;
    self.formButton.hidden = NO;
    self.repsButton.hidden = NO;
    self.finishedButton.hidden = NO;
}

// Exposed actions for buttons
-(IBAction)goToPhotoAction:(id)sender {
    [self goToPhoto];
}
-(IBAction)goToFormAction:(id)sender {
    [self goToForm];
}
-(IBAction)goToRepsAction:(id)sender {
    [self goToReps];
}
-(IBAction)goToFinishedAction:(id)sender {
    [self goToFinished];
}

#pragma mark - Private methods
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)setChildFrame:(UIViewController *)viewController {
    [self logMemUsage];

    if( [self.view.subviews count] > 0 ) {
        [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    }
    NSLog(@" After remove from superview");
    
    [self logMemUsage];

    [self.view addSubview:viewController.view];
    [self.view sendSubviewToBack:viewController.view];
    viewController.view.frame = self.view.frame;
}
-(void)setButton:(UIButton *) button {

    [activeButton setBackgroundImage:inactiveImage forState:UIControlStateNormal];
    [button setBackgroundImage:activeImage forState:UIControlStateNormal];
    activeButton = button;
}


vm_size_t usedMemory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

vm_size_t freeMemory(void) {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}
-(void)logMemUsage {
    // compute memory usage and log if different by >= 100k
    static long prevMemUsage = 0;
    long curMemUsage = usedMemory();
    long memUsageDiff = curMemUsage - prevMemUsage;
    
//    if (memUsageDiff > 100000 || memUsageDiff < -100000) {
        prevMemUsage = curMemUsage;
        NSLog(@"Memory used %7.1f (%+5.0f), free %7.1f kb", curMemUsage/1000.0f, memUsageDiff/1000.0f, freeMemory()/1000.0f);
//    }
}
@end
