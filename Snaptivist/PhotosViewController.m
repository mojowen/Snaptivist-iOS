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

@synthesize savedPhotos, photoNumber;

- (void)viewDidLoad
{
    savedPhotos = [NSArray arrayWithObjects:self.pic1,self.pic2,self.pic3,self.pic3,self.pic4,self.pic5, nil];
    photoNumber = 0;

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
    [self prepForTake];
}
- (IBAction)relaunchCamera:(id)sender {
    [self prepForTake];
}

-(IBAction)takePhotos:(id)sender {
    UIButton *newPhoto = [savedPhotos objectAtIndex:photoNumber];
    
    [newPhoto setBackgroundImage:self.camera.image forState:UIControlStateNormal];
    newPhoto.hidden = NO;

    if( photoNumber > 4 ) {
        photoNumber = 0;
    } else {
        photoNumber = photoNumber + 1;
    }

}
-(IBAction)setPhoto:(id)sender {
    SnaptivistTabs *parent = [self tabController];
    NSData *photoData = [NSData dataWithData:UIImagePNGRepresentation(self.camera.image)];
    parent.signup.photo =photoData;
   [parent goToForm];
}
- (IBAction)selectPic1:(id)sender {
    [self selectPhoto:1];
}
- (IBAction)selectPic2:(id)sender {
    [self selectPhoto:2];
}
- (IBAction)selectPic3:(id)sender {
    [self selectPhoto:3];
}
- (IBAction)selectPic4:(id)sender {
    [self selectPhoto:4];
}
- (IBAction)selectPic5:(id)sender {
    [self selectPhoto:5];
}


#pragma mark - Private methods
-(void)selectPhoto:(NSUInteger)photo {
    photo = photo - 1;
    UIImage *selectImage = ((UIButton *)[savedPhotos objectAtIndex:photo] ).currentBackgroundImage;
    [self.camera setImage: selectImage];
    self.takePhoto.hidden = YES;
    self.selectPhoto.hidden = NO;
    self.reLaunchCamera.hidden = NO;
}
-(void)prepForTake {
    self.camera.hidden = NO;
    self.takePhoto.hidden = NO;
    self.selectPhoto.hidden = YES;
    self.reLaunchCamera.hidden = YES;
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
    }
    else
    {
        [self.camera setImage: [UIImage imageNamed:@"no_camera.jpg"] ];
    }
}
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}
@end
