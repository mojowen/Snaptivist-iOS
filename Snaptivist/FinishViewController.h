//
//  FinishViewController.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/27/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnaptivistTabs.h"

@interface FinishViewController : UIViewController

@property (nonatomic,weak) IBOutlet UILabel *finishMessage;

@property (weak, nonatomic) IBOutlet UITextView *waiver;

-(IBAction)showWaiver:(id)sender;
-(IBAction)startOver:(id)sender;
@end
