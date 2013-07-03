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
    SnaptivistTabs *parent = [self tabController];
    [parent.context save:nil];
    
    if( ! parent.signup.sendTweet.boolValue ) {
        self.finishMessage.text = @"Thank for signing up, keep an eye out for an email from us soon";
    }
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

#pragma mark - Private methods
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}
- (void)viewDidUnload {
    [self setWaiver:nil];
    [super viewDidUnload];
}
@end
