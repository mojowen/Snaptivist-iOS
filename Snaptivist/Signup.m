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
@dynamic photo_path;

@synthesize didError,isSyncing;

-(id)init{
    self = [super init];
    self.isSyncing = NO;
    self.didError = NO;
    
    return self;
}

-(NSString *)fileName {
    NSLog(@"%@ %@",self.firstName,self.lastName);
    if( self.firstName == nil )
        return [NSString stringWithFormat:@"tmp_%@.png",self.photo_date];
    else
        return [NSString stringWithFormat:@"%@_%@_%@.png",self.firstName,self.lastName,self.photo_date];

}
-(NSString *)filePath {
    if( self.photo_path != nil )
        return self.photo_path;
    else {

        NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        return [NSString stringWithFormat:@"%@/%@",
                              documentsDirectory,[self fileName]];
    }
}
-(void)savePhoto:(UIImage *)image {
    [UIImagePNGRepresentation(image) writeToFile:[self filePath] atomically:YES];
    self.photo_path = [self filePath];
}
-(void)resavePhoto{
    if( self.photo_path != nil ) {
        NSString *tmp_filepath = self.photo_path;
        self.photo_path = nil;

        [[NSFileManager defaultManager] moveItemAtPath:tmp_filepath toPath:[self filePath] error:nil];
        self.photo_path = [self filePath];
    }
}
-(UIImage *)loadPhoto {
    if( self.photo_path != nil)
        return [UIImage imageWithContentsOfFile:[self filePath]];
    else
        return [UIImage imageNamed:@"user-placeholder.png"];
}
-(void)deletePhoto {
    if( self.photo_path != nil ) {
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:[self filePath] error:nil];        
    }
}
-(NSString *)toString{
    return [[NSArray arrayWithObjects:self.firstName,self.lastName,self.email,self.zip,self.reps,self.friends,self.photo_date,nil] componentsJoinedByString:@
            "\t"];
}
-(void)logSignup {
    // http://stackoverflow.com/questions/5075416/objective-c-checking-file-exist-at-path
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *logFile = [NSString stringWithFormat:@"%@/all_signups.txt",documentsDirectory];
    NSString *signupString = [NSString stringWithFormat:@"%@\n",[self toString]];
    
    if ( ! [fileManager fileExistsAtPath:logFile]){
        [signupString writeToFile:logFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {

        NSFileHandle *aFileHandle;
        
        aFileHandle = [NSFileHandle fileHandleForWritingAtPath:logFile];
        
        [aFileHandle truncateFileAtOffset:[aFileHandle seekToEndOfFile]];
        
        [aFileHandle writeData:[[self toString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
}
@end
