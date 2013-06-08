//
//  FirstViewController.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "FirstViewController.h"
#import "Organization.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize organization_name;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view, typically from a nib.
    Organization *the_organization = [[Organization alloc] init];
    the_organization.name = @"The Ally Coalition";

    organization_name.text = the_organization.name;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goToSecond:(id)sender {
    [((UITabBarController *)(self.parentViewController)) setSelectedIndex:1];
}

@end
