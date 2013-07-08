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

    signup = nil;
    
    [photosViewController removeFromParentViewController];
    [repsViewController removeFromParentViewController];
    [formViewController removeFromParentViewController];
    [finishedViewController removeFromParentViewController];
    finishedViewController = nil;
    formViewController = nil;
    repsViewController = nil;
    photosViewController = nil;

    [self getStarted];
    [self goToPhoto];
    

}
-(void)goToPhoto {
    [self setChildFrame:photosViewController];
    [self setButton:self.photosButton];
}
-(void)goToForm {
    [self setChildFrame:formViewController];
    [self setButton:self.formButton];
}
-(void)goToReps {
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
- (IBAction)cancelButton:(id)sender {
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Are You Sure?"
                                                          message:@"All your data will be lost."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"I'm sure", nil];
    [myAlertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if( buttonIndex == 0 ) {
    } else {
       [self startOver];
    }
}

#pragma mark - Private methods
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)setChildFrame:(UIViewController *)viewController {

    if( [self.view.subviews count] > 0 ) {
        [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    }

    [self showButtons];
    self.allyLogo.hidden = NO;
    [self.view addSubview:viewController.view];
    [self.view sendSubviewToBack:viewController.view];
    viewController.view.frame = self.view.frame;
}
-(void)setButton:(UIButton *) button {

    [activeButton setBackgroundImage:inactiveImage forState:UIControlStateNormal];
    [button setBackgroundImage:activeImage forState:UIControlStateNormal];
    activeButton = button;
}

@end
