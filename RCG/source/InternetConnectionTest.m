//
//  InternetConnectionTest.m
//  RCG
//
//  Created by Jonathan Ritchey on 8/6/13.
//  Copyright (c) 2013 Imulogy. All rights reserved.
//

#import "InternetConnectionTest.h"

@implementation InternetConnectionTest

// http://www.thewindtradition.org/wp-content/iOSClientValidationFile.dat
// length: 320
+ (BOOL) isConnectionValidWithTestURL:(NSString *) testURL ofNSDataLength:(int) expectedLength
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:testURL]];
    int nsdataLength = [data length];
    return nsdataLength == expectedLength;
}

@end
