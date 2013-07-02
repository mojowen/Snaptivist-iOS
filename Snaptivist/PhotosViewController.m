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

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@interface UIImage (RotationMethods)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
@end

@implementation UIImage (RotationMethods)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
	CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}
@end;

@interface PhotosViewController ()

- (void)setupAVCapture;
- (void)teardownAVCapture;

@end



@implementation PhotosViewController

@synthesize savedPhotos, photoNumber,isUsingFrontFacingCamera,stillImageOutput,videoDataOutput,previewView,videoDataOutputQueue,previewLayer,effectiveScale,flashView;

- (void)viewDidLoad
{
    savedPhotos = [NSArray arrayWithObjects:self.pic1,self.pic2,self.pic3,self.pic4,self.pic5, nil];
    photoNumber = 0;
    self.filmStrip.hidden = YES;

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRotate:)
                                                name:@"UIDeviceOrientationDidChangeNotification"
                                              object:nil];
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

    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [self takePicture]; // This method will assign photo asynchronously - after it's complete
    else
        [self assignPhoto]; // No camera - just use what ever is camera's default image
}
-(IBAction)setPhoto:(id)sender {
    [self teardownAVCapture];
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
	
    isUsingFrontFacingCamera = NO;
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
    if( previewLayer == nil )
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
                [self.camera setImage:[UIImage imageWithData:jpegData]];
                [self assignPhoto];
            }

          }
	 ];
}
-(void)assignPhoto {
    UIButton *newPhoto = [savedPhotos objectAtIndex:photoNumber];
    
    UIImage *newImage = [self resizeImage:self.camera.image newSize:CGSizeMake(1024.0f, 764.0f)];
    
    [newPhoto setBackgroundImage:newImage forState:UIControlStateNormal];
    newPhoto.hidden = NO;
    
    if( photoNumber == 4 ) {
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
    if( previewLayer != nil )
    {
        if( [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft )
            [previewLayer.connection setVideoOrientation: AVCaptureVideoOrientationLandscapeRight];
        else
            [previewLayer.connection setVideoOrientation: AVCaptureVideoOrientationLandscapeLeft];
    }
}
- (IBAction)switchCameras:(id)sender
{
	AVCaptureDevicePosition desiredPosition;
	if (isUsingFrontFacingCamera)
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

            if( [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft )
                [previewLayer.connection setVideoOrientation: AVCaptureVideoOrientationLandscapeRight];
            else
                [previewLayer.connection setVideoOrientation: AVCaptureVideoOrientationLandscapeLeft];
        
			break;
		}
	}
	isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
}
- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mark - Private methods
-(void)selectPhoto:(NSUInteger)photo {
    previewLayer.hidden = YES;
    photo = photo - 1;
    UIImage *selectImage = ((UIButton *)[savedPhotos objectAtIndex:photo] ).currentBackgroundImage;
    self.camera.hidden = NO;
    [self.camera setImage: selectImage];
    self.takePhoto.hidden = YES;
    self.switchCamera.hidden = YES;

    self.selectPhoto.hidden = NO;
    self.reLaunchCamera.hidden = NO;
    [self.view bringSubviewToFront:self.selectPhoto];
    [self.view bringSubviewToFront:self.reLaunchCamera];

}
-(void)prepForTake {
    previewLayer.hidden = NO;
    self.previewView.hidden = NO;
    self.takePhoto.hidden = NO;
    self.switchCamera.hidden = NO;
    
    [self.view bringSubviewToFront:self.switchCamera];
    [self.view bringSubviewToFront:self.takePhoto];
    
    self.selectPhoto.hidden = YES;
    self.reLaunchCamera.hidden = YES;
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
      	[self setupAVCapture];
    else
        self.camera.hidden = NO;
        self.filmStrip.hidden = NO;
        [self.camera setImage: [UIImage imageNamed:@"no_camera.jpg"] ];
}
-(SnaptivistTabs *)tabController {
    return ((SnaptivistTabs *)(self.parentViewController));
}
- (void)viewDidUnload {
    [self setFilmStrip:nil];
    [super viewDidUnload];
}
@end
