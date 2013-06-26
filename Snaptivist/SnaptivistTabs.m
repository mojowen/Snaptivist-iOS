//
//  SnaptivistTabs.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "SnaptivistTabs.h"

@implementation SnaptivistTabs

@synthesize context,signup,reps,photosViewController,formViewController,finishedViewController,repsViewController;

-(void)viewDidLoad {

    context = [[self appDelegate] managedObjectContext];

    signup = [NSEntityDescription insertNewObjectForEntityForName:@"Signup" inManagedObjectContext:context];

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

    [self goToPhoto];

    [super viewDidLoad];

}
// Commands for changing tabs - includes validation logic for moving between sections
-(void)goToPhoto {
    [self setChildFrame:photosViewController];
}
-(void)goToForm {
    [self setChildFrame:formViewController];
}
-(void)goToReps {
    if( ! [signup.zip isEqual:@""] ) {
        [self setChildFrame:repsViewController];
    }
}
-(void)goToFinished {
    [self setChildFrame:finishedViewController];
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
    if( [self.view.subviews count] > 0 ) {
        [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    }

    [self.view addSubview:viewController.view];
    [self.view sendSubviewToBack:viewController.view];
    viewController.view.frame = self.view.frame;
}

@end
