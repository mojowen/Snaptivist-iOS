//
//  Signup.h
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Signup : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * reps;
@property (nonatomic, retain) NSString * friends;
@property (nonatomic, retain) NSDate * photo_date;
@property (nonatomic, retain) NSString * photo_path;
@property (nonatomic,retain) NSData * photo;
@property (nonatomic) NSNumber *sendTweet;

-(NSString *)fileName;
-(UIImage *)loadPhoto;
-(void)savePhoto:(UIImage *)image;
-(void)resavePhoto;
-(void)deletePhoto;

@end