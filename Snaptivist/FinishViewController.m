//
//  FinishViewController.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/27/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "FinishViewController.h"

@interface FinishViewController ()

@end

@implementation FinishViewController


- (void)viewDidLoad
{
    SnaptivistTabs *parent = [self tabController];
    NSError *error;
    [parent.signup logSignup];
    if (![parent.context save:&error])
    {
        // Update to handle the
        NSLog(@"Unresolved error %@", error);
        exit(-1);  // Fail
    } else {
        NSLog(@"saved it");
    }

    
    self.finishMessage.text = @"Thank for signing up, keep an eye out for an email from us soon";
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction) showWaiver:(id)sender {
    self.waiver.hidden = NO;
}
-(IBAction) startOver:(id)sender {
    [(SnaptivistTabs *)[self tabController] startOver];
}

#pragma mark - Private methods
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}
- (void)viewDidUnload {
    [self setWaiver:nil];
    [super viewDidUnload];
}
@end
