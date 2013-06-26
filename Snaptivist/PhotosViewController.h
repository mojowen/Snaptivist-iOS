//
//  FirstViewController.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnaptivistTabs.h"

@interface PhotosViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel  *organization_name;

- (IBAction)goToForm:(id)sender;

@end
