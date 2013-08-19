//
//  GooglePlusViewController.h
//  RCG
//
//  Created by Daniel Ho on 8/2/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@class GPPSignInButton;

@interface GooglePlusViewController : UIViewController <GPPSignInDelegate>

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;


- (IBAction)didTapShare:(id)sender;

@end
