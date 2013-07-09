//
//  Signup.m
//  Snaptivist
//
//  Created by Scott Duncombe on 6/8/13.
//  Copyright (c) 2013 Scott Duncombe. All rights reserved.
//

#import "Signup.h"


@implementation Signup

@dynamic firstName;
@dynamic lastName;
@dynamic email;
@dynamic twitter;
@dynamic zip;
@dynamic friends;
@dynamic reps;
@dynamic photo_date;
@dynamic sendTweet;
@dynamic photo;
@dynamic photo_path;

-(NSString *)fileName {
    return [NSString stringWithFormat:@"%@_%@_%@.png",self.firstName,self.lastName,self.photo_date];
}
-(NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [NSString stringWithFormat:@"%@/photos/%@",
                          documentsDirectory,[self fileName]];
}
-(void)savePhoto:(UIImage *)image {
    [UIImagePNGRepresentation(image) writeToFile:[self filePath] atomically:YES];
}
-(UIImage *)loadPhoto {
    if( self.photo_path != nil)
        return [UIImage imageWithContentsOfFile:[self filePath]];
    else if( self.photo == nil)
        return [UIImage imageWithData:self.photo];
    else
        return [UIImage imageNamed:@"user-placeholder.png"];
}
-(void)deletePhoto {
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:[self filePath] error:nil];
}
@end
