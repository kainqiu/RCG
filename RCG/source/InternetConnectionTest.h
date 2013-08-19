//
//  InternetConnectionTest.h
//  RCG
//
//  Created by Jonathan Ritchey on 8/6/13.
//  Copyright (c) 2013 Imulogy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InternetConnectionTest : NSObject

// tests whether internet connection is valid by fetching a file from a known host and verifying
// its size. this will let us know whether we've been re-directed to a wifi login page, or have
// actually reached our intended host.
//
// Expected use:
//
// bool isInternetConnectionValid =
//    [InternetConnectionTest isConnectionValidWithTestURL:
//     @"http://www.thewindtradition.org/wp-content/iOSClientValidationFile.dat"
//     ofNSDataLength:320];

+ (BOOL) isConnectionValidWithTestURL:(NSString *) testURL ofNSDataLength:(int) size;

@end
