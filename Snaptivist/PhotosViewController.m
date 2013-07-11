//
//  FirstViewController.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "PhotosViewController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotosViewController ()

- (void)setupAVCapture;
- (void)teardownAVCapture;
- (void)unload;

@end



@implementation PhotosViewController

@synthesize savedPhotos, photoNumber,isUsingFrontFacingCamera,stillImageOutput,videoDataOutput,previewView,videoDataOutputQueue,previewLayer,effectiveScale,flashView;

- (void)viewDidLoad
{
    savedPhotos = [NSArray arrayWithObjects:self.pic1,self.pic2,self.pic3,self.pic4,nil];
    photoNumber = 0;
    self.filmStrip.hidden = YES;
    SnaptivistTabs *parent = [self tabController];

    [super viewDidLoad];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];

    if( parent.signup.photo_path != nil ) {
        [self hideSplash];
        [self assignPhoto:[parent.signup loadPhoto]];
    }
    
    // styling the photos
    self.pic1.layer.borderColor = [UIColor colorWithRed:132/255.0f green:131/255.0f blue:131/255.0f alpha:1.0f].CGColor;
    self.pic1.layer.borderWidth = 1.0;
    
    self.pic2.layer.borderColor = [UIColor colorWithRed:132/255.0f green:131/255.0f blue:131/255.0f alpha:1.0f].CGColor;
    self.pic2.layer.borderWidth = 1.0;
    
    self.pic3.layer.borderColor = [UIColor colorWithRed:132/255.0f green:131/255.0f blue:131/255.0f alpha:1.0f].CGColor;
    self.pic3.layer.borderWidth = 1.0;
    
    self.pic4.layer.borderColor = [UIColor colorWithRed:132/255.0f green:131/255.0f blue:131/255.0f alpha:1.0f].CGColor;
    self.pic4.layer.borderWidth = 1.0;

}
-(void)viewDidAppear:(BOOL)animated {
    if( photoNumber > 0 ) {
        [self prepForTake];
    }
}
-(void)unload {
    self.pic1 = nil;
    self.pic2 = nil;
    self.pic3 = nil;
    self.pic4 = nil;
    savedPhotos = nil;
    self.camera = nil;
    self.filmStrip = nil;
}
- (void)didReceiveMemoryWarning
{
    [self unload];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goToForm:(id)sender {
    SnaptivistTabs *parent = [self tabController];
    [parent goToForm];
}
- (IBAction)launchCamera:(id)sender {
    [self hideSplash];
    [self prepForTake];
}
- (IBAction)relaunchCamera:(id)sender {
    [self prepForTake];
}

-(IBAction)takePhotos:(id)sender {
    [self flash];
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [self takePicture]; // This method will assign photo asynchronously - after it's complete
    else
        [self assignPhoto:self.camera.image]; // No camera - just use what ever is camera's default image
}
-(IBAction)setPhoto:(id)sender {

    SnaptivistTabs *parent = [self tabController];

    UIImageWriteToSavedPhotosAlbum(self.camera.image, nil, nil, nil);
    [parent.signup savePhoto:self.camera.image];
    
    self.camera = nil;
    savedPhotos = nil;
    [self unload];
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

- (void)setupAVCapture
{
	NSError *error = nil;

	AVCaptureSession *session = [AVCaptureSession new];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    [session setSessionPreset:AVCaptureSessionPreset640x480];
	else
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
	
    // Select a video device, make an input
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	
	if ( [session canAddInput:deviceInput] )
		[session addInput:deviceInput];
	
    // Make a still image output
	stillImageOutput = [AVCaptureStillImageOutput new];

	if ( [session canAddOutput:stillImageOutput] )
		[session addOutput:stillImageOutput];
	
    // Make a video data output
	videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
	
    if ( [session canAddOutput:videoDataOutput] )
		[session addOutput:videoDataOutput];
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
	
	effectiveScale = 1.0;

    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    if( [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft )
        [previewLayer.connection setVideoOrientation: AVCaptureVideoOrientationLandscapeRight];
    else
        [previewLayer.connection setVideoOrientation: AVCaptureVideoOrientationLandscapeLeft];

    

    
	CALayer *rootLayer = [previewView layer];
	[rootLayer setMasksToBounds:YES];
	[previewLayer setFrame:[rootLayer bounds]];
	[rootLayer addSublayer:previewLayer];
	[session startRunning];

    if( isUsingFrontFacingCamera )
        [self switchCameraSide:NO];

bail:
	if (error) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
		[self teardownAVCapture];
	}
}

// clean up capture setup
- (void)teardownAVCapture
{
	if (videoDataOutputQueue)
		dispatch_release(videoDataOutputQueue);
	[previewLayer removeFromSuperlayer];
}

// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
	});
}

// main action method to take a still image -- if face detection has been turned on and a face has been detected
// the square overlay will be composited on top of the captured image and saved to the camera roll
- (void)takePicture
{
	// Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
	[stillImageConnection setVideoOrientation:avcaptureOrientation];
	[stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
		
    // set the appropriate pixel format / image type output setting depending on if we'll need an uncompressed image for
    // the possiblity of drawing the red square over top or if we're just writing a jpeg to the camera roll which is the trival case
    NSLog(@"beginning capture");

	[stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
        completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (error) {
                [self displayErrorOnMainQueue:error withMessage:@"Take picture failed"];
                NSLog(@"failed");
            } else {
                NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                float scale = 0.2f;
                UIImage *capturedImage = [[UIImage imageWithData:jpegData scale:scale] fixOrientation];

                NSLog(@"orientation on capture %d",capturedImage.imageOrientation);
                [self assignPhoto:capturedImage];
            }

          }
	 ];
}
- (void)flash
{
    // do flash bulb like animation
    flashView = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [flashView setAlpha:1.f];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                         flashView = nil;
                     }
     ];
}
-(void)assignPhoto:(UIImage *)image {
    UIButton *newPhoto = [savedPhotos objectAtIndex:photoNumber];

    [newPhoto setImage:image forState:UIControlStateNormal];
    newPhoto.hidden = NO;
    
    if( photoNumber == 3 ) {
        photoNumber = 0;
    } else {
        photoNumber = photoNumber + 1;
    }
}

// utility routing used during image capture to set up capture orientation
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = deviceOrientation;
        if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
            result = AVCaptureVideoOrientationLandscapeRight;
        else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
            result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}
- (void) didRotate:(NSNotification *)notification {

    if( [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft )
        [previewLayer.connection setVideoOrientation: AVCaptureVideoOrientationLandscapeRight];
    else
        [previewLayer.connection setVideoOrientation: AVCaptureVideoOrientationLandscapeLeft];
}
- (IBAction)switchCameras:(id)sender
{
    [self switchCameraSide:isUsingFrontFacingCamera];
    isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
}
-(void)switchCameraSide:(BOOL)goBackCamera {
	AVCaptureDevicePosition desiredPosition;
	if (goBackCamera)
		desiredPosition = AVCaptureDevicePositionBack;
	else
		desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[previewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in [[previewLayer session] inputs]) {
				[[previewLayer session] removeInput:oldInput];
			}
			[[previewLayer session] addInput:input];
			[[previewLayer session] commitConfiguration];

			break;
		}
	}
	
}

#pragma mark - Private methods
-(void)selectPhoto:(NSUInteger)photo {
    [self teardownAVCapture];
    
    photo = photo - 1;
    UIImage *selectImage = ((UIButton *)[savedPhotos objectAtIndex:photo] ).currentImage;
        
    self.camera.hidden = NO;
    self.filmStrip.hidden = NO;
    [self.camera setImage: selectImage];
    self.takePhoto.hidden = YES;
    self.switchCamera.hidden = YES;

    self.selectPhoto.hidden = NO;
    self.reLaunchCamera.hidden = NO;
    [self.view bringSubviewToFront:self.camera];
    [self.view bringSubviewToFront:self.selectPhoto];
    [self.view bringSubviewToFront:self.reLaunchCamera];

}
-(void)prepForTake {

    self.previewView.hidden = NO;
    self.takePhoto.hidden = NO;
    self.switchCamera.hidden = NO;
    
    [self.view bringSubviewToFront:self.switchCamera];
    [self.view bringSubviewToFront:self.takePhoto];
    
    self.selectPhoto.hidden = YES;
    self.reLaunchCamera.hidden = YES;
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self setupAVCapture];
    } else {
        self.camera.hidden = NO;
        [self.camera setImage: [UIImage imageNamed:@"no_camera.jpg"] ];
    }
    self.filmStrip.hidden = NO;
}
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}
- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self unload];
    [super viewDidUnload];
}
-(void)hideSplash {
    self.background.hidden = YES;
    self.allyBG.hidden = YES;
    self.launchCamera.hidden = YES;
    self.noPhoto.hidden = YES;
    
    SnaptivistTabs *parent = [self tabController];
//    [parent hideButtons];
    parent.allyLogo.hidden = YES;
}
@end
