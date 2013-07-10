//
//  Constants_off.h
//  Snaptivist
//
//  Created by Scott Duncombe on 7/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <Foundation/Foundation.h>


// This file is not included in the git repository and is a good place for storing files
// Change the file name to Constants.h to fix

#define ACCESS_KEY_ID          @"YOUR ID"
#define SECRET_KEY             @"YOUR SECRET"

#define PICTURE_BUCKET         @"YOUR BUCKET"

#define CREDENTIALS_ERROR_TITLE    @"Missing Credentials"
#define CREDENTIALS_ERROR_MESSAGE  @"AWS Credentials not configured correctly.  Please review the README file."

#ifdef DEBUG
    #define BASE_URL    @"http://local-endpoint"
#else
    #define BASE_URL    @"http://production-endpoint"
#endif



// Change this file
@interface Constants : NSObject

@end
