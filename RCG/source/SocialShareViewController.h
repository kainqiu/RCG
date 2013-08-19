//
//  SocialShareViewController.h
//  RCG
//
//  Created by Kain Qiu on 7/26/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialShareViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UITextViewDelegate> {
    NSString *tumblrAccessText;
    NSString *tumblrAccessSecret;
}

- (IBAction)fbLogin:(id)sender;
- (IBAction)twitterLogin:(id)sender;
- (IBAction)tumblrLogin:(id)sender;
- (IBAction)postToSelected:(id)sender;
- (IBAction)getTumblrHostname:(id)sender;
//@property (strong, nonatomic) IBOutlet UITextView *comments;
@property (strong, nonatomic) NSString *URL;
- (void)loginFailed;


@end
