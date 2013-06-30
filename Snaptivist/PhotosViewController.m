//
//  FirstViewController.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "PhotosViewController.h"

@interface PhotosViewController ()

@end

@implementation PhotosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goToForm:(id)sender {
    SnaptivistTabs *parent = [self tabController];
    [parent goToForm];
}
- (IBAction)launchCamera:(id)sender {
    self.background.hidden = YES;
    self.launchCamera.hidden = YES;
    self.noPhoto.hidden = YES;
    
    self.camera.hidden = NO;
    self.takePhoto.hidden = NO;
}

#pragma mark - Private methods
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}
@end
