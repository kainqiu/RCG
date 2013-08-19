//
//  FBPagePostViewController.m
//  RCG
//
//  Created by Kain Qiu on 8/6/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "FBPagePostViewController.h"

// for fb
#import <FacebookSDK/FacebookSDK.h>
#import "RCGAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface FBPagePostViewController ()
{
    BOOL isLoggedIn;
}
//@property (strong, nonatomic) IBOutlet UISwitch *fbPageLoginSwitch;
//@property (strong, nonatomic) IBOutlet UITextView *comment;
@property (strong, nonatomic) NSString *postURL;
@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) IBOutlet UIButton *logIn;
@property (strong, nonatomic) UITextView *comment;
@property (strong, nonatomic) IBOutlet UIButton *goToFBPage;
- (IBAction)goToFB:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *post;

@end

@implementation FBPagePostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // logout first
    //[FBSession.activeSession closeAndClearTokenInformation];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height > 480) {
        NSLog(@"big screen");
        self.comment = [[UITextView alloc] initWithFrame:CGRectMake(20, 40, 280, 280)];
    } else {
        self.comment = [[UITextView alloc] initWithFrame:CGRectMake(20, 40, 280, 225)];
    }
    //    self.comment = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 280, 280)];
    self.comment.delegate = self;
    [[self.comment layer] setBorderWidth:1.0f];
    //    [[self.comment layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [self.comment.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [[self.comment layer] setCornerRadius:4];
    self.comment.clipsToBounds = YES;
    [self.comment.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.comment.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.comment.layer setShadowOpacity:1.0];
    [self.comment.layer setShadowRadius:0.3];
    [self.comment setFont:[UIFont systemFontOfSize:14]];
    self.comment.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.comment];
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    //view.image = [UIImage imageNamed:@"splashpage.png"];
    view.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    view.alpha = 0.3;
    
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
	// Do any additional setup after loading the view.
    
    //    [self.fbPageLoginSwitch setOn:NO];
    if ([self isLogin]) {
        isLoggedIn = YES;
        self.logIn.hidden = YES;
        self.goToFBPage.hidden = NO;
        self.post.hidden = NO;
    }
    else {
        isLoggedIn = NO;
        self.goToFBPage.hidden = YES;
        self.post.hidden = YES;
        self.logIn.hidden = NO;
    }
    
    self.postURL = @"www.google.com";
    self.commentText = @"hey check this link!";
    
    // set the size of each button
//    CGRect seeFBPageFrame = self.goToFBPage.frame;
//    seeFBPageFrame.size = CGSizeMake(150, 70);
//    self.goToFBPage.frame = seeFBPageFrame;
//    
//    CGRect postFrame = self.post.frame;
//    postFrame.size = CGSizeMake(150, 70);
//    self.post.frame = postFrame;
//    
//    CGRect loginFrame = self.logIn.frame;
//    loginFrame.size = CGSizeMake(150, 70);
//    self.logIn.frame = loginFrame;
    
    self.goToFBPage.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.goToFBPage.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.goToFBPage setTitle: @"See the RCG community\non Facebook" forState: UIControlStateNormal];
    
    // set the button color
    self.goToFBPage.backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    self.post.backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    self.logIn.backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    [self.goToFBPage setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.post setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.logIn setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    self.goToFBPage.layer.cornerRadius = 6; // this value vary as per your desire
    self.goToFBPage.clipsToBounds = YES;
    self.post.layer.cornerRadius = 6; // this value vary as per your desire
    self.post.clipsToBounds = YES;
    self.logIn.layer.cornerRadius = 6; // this value vary as per your desire
    self.logIn.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// ------------- facebook group post --------------

//- (IBAction)fbLogin:(id)sender {
//    [self fbPerformLogin];
//}
- (IBAction)login:(id)sender {
    [self fbPerformLogin];
}

//
//- (IBAction)triggerPostPage:(id)sender {
//    [self fbPostToPage];
//}
- (IBAction)post:(id)sender {
    [self fbPostToPage];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)isLogin {
    return FBSession.activeSession.isOpen == YES;
}


- (void) fbPerformLogin {
    if(isLoggedIn == NO && ![self isLogin]) {
        RCGAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate openSessionWithSuccessBlock:^{
            if ([self isLogin]) {
                NSLog(@"session is open");
                self.logIn.hidden = YES;
                self.goToFBPage.hidden = NO;
                isLoggedIn = YES;
                self.post.hidden = NO;
            } else {
                NSLog(@"session not open when login");
            }
        }];
        
    } else {
        NSLog(@"has already logged in");
        self.logIn.hidden = YES;
        isLoggedIn = YES;
        self.post.hidden = NO;
        self.goToFBPage.hidden = NO;
    }
}


- (void) performPublishActionToPage:(void (^)(void)) action {
    
    if ([[FBSession activeSession]isOpen]) {
        NSLog(@"asking for permission");
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] == NSNotFound) {
            // if we don't already have the permission, then we request it now
            NSLog(@"publish_stream permission is nil");
            
            [FBSession.activeSession requestNewPublishPermissions:@[@"publish_stream"]
                                                  defaultAudience:FBSessionDefaultAudienceFriends
                                                completionHandler:^(FBSession *session, NSError *error) {
                                                    if (!error) {
                                                        if([FBSession.activeSession.permissions indexOfObject:@"manage_pages"] == NSNotFound) {
                                                            NSLog(@"manage_pages permission is nil");
                                                            [FBSession.activeSession requestNewPublishPermissions:@[@"manage_pages"]
                                                                                                  defaultAudience:FBSessionDefaultAudienceFriends
                                                                                                completionHandler:^(FBSession *session, NSError *error) {
                                                                                                    if (!error) {
                                                                                                        action();
                                                                                                    } else {
                                                                                                        NSLog(@"manage_pages page permission error is %@", error.description);
                                                                                                    }
                                                                                                    //For this example, ignore errors (such as if user cancels).
                                                                                                }];
                                                        } else {
                                                            action();
                                                        }
                                                    } else {
                                                        NSLog(@"publish_stream permission error is %@", error.description);
                                                    }
                                                    //NSLog(@"publish_stream permission error is %@", error.description);
                                                    
                                                    //For this example, ignore errors (such as if user cancels).
                                                }];
        } else {
            NSLog(@"has publish_stream ");
            if([FBSession.activeSession.permissions indexOfObject:@"manage_pages"] == NSNotFound) {
                [FBSession.activeSession requestNewPublishPermissions:@[@"manage_pages"]
                                                      defaultAudience:FBSessionDefaultAudienceFriends
                                                    completionHandler:^(FBSession *session, NSError *error) {
                                                        if (!error) {
                                                            action();
                                                        } else {
                                                            NSLog(@"manage_pages page permission error is %@", error.description);
                                                        }
                                                        //For this example, ignore errors (such as if user cancels).
                                                    }];
            } else {
                action();
            }
        }
    } else {
        NSLog(@"no session open");
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_stream", @"manage_pages", nil]
                                           defaultAudience:FBSessionDefaultAudienceOnlyMe
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (!error) {
                                                 NSLog(@"new session open, no error");
                                                 NSLog(@"new session info is %@", session.description);
                                                 action();
                                             }else{
                                                 NSLog(@"new session error is %@", error);
                                                 //action();
                                                 
                                             }
                                             NSLog(@"what happened");
                                         }];
    }
}

- (void) fbPostToPage {
    if(![self.comment.text isEqualToString:@""]) {
    [self performPublishActionToPage:^{
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        //NSString *msg = @"blah";
        [params setObject:self.comment.text forKey:@"message"];
        //[params setObject:self.postURL forKey:@"link"];
        
        
        [FBRequestConnection startForPostWithGraphPath:@"153952204800449/feed"
                                           graphObject:[NSDictionary dictionaryWithDictionary:params]
                                     completionHandler:
         ^(FBRequestConnection *connection, id result, NSError *error) {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             if (!error) {
                 NSLog(@"in success post to page");
                 [self.comment setText:@""];
                 [[[UIAlertView alloc] initWithTitle:@"Facebook"
                                             message:@"Your update has been posted."
                                            delegate:self
                                   cancelButtonTitle:@"Continue"
                                   otherButtonTitles:nil] show];
             } else {
                 if(error.code == 5) {
                     // if error code is 5
                     NSLog(@"error code is 5, re-login");
                     // clear the session
                     if (FBSession.activeSession.isOpen) {
                         NSLog(@"clear fb session");
                         [FBSession.activeSession closeAndClearTokenInformation];
                         
                         // clear cookie
                         NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                         NSArray* facebookCookies = [cookies cookiesForURL:
                                                     [NSURL URLWithString:@"http://login.facebook.com"]];
                         for (NSHTTPCookie* cookie in facebookCookies) {
                             [cookies deleteCookie:cookie];
                         }
                     } else {
                         NSLog(@"there is no session open");
                     }
                     // login again
                     RCGAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
                     [appDelegate openSessionWithSuccessBlock:^{
                         // post msg again for switching user
                         //-------------------------------------------------------------
                         
                         NSMutableDictionary *params = [NSMutableDictionary dictionary];
                         //NSString *msg = @"second time login";
                         [params setObject:self.comment.text forKey:@"message"];
                         //[params setObject:self.postURL forKey:@"link"];
                         
                         
                         [FBRequestConnection startForPostWithGraphPath:@"153952204800449/feed"
                                                            graphObject:[NSDictionary dictionaryWithDictionary:params]
                                                      completionHandler:
                          ^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSLog(@"in success post to page");
                                  [self.comment setText:@""];
                                  [[[UIAlertView alloc] initWithTitle:@"Facebook"
                                                              message:@"Your update has been posted."
                                                             delegate:self
                                                    cancelButtonTitle:@"Continue"
                                                    otherButtonTitles:nil] show];
                              } else {
                                  
                                  NSLog(@"inner post error is %@", error.description);
                                  [[[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Your update has failed to post."
                                                             delegate:nil
                                                    cancelButtonTitle:@"Continue"
                                                    otherButtonTitles:nil] show];
                              }
                          }];
                     }];
                     //-------------------------------------------------------------
                     
                 } else {
                     NSLog(@"outter post error is %@", error.description);
                     [[[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:@"Your update has fialed to post."
                                                delegate:nil
                                       cancelButtonTitle:@"Continue"
                                       otherButtonTitles:nil] show];
                 }
             }
         }];
    }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Blank message." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
    }
}

// ------------- end of facebook group post --------------


-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSLog(@"text view should %@", textView.text);
    
    return [textView resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"text view did %@", textView.text);
    [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (IBAction)goToFB:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/pages/Radical-Change-Group-Test/153952204800449"];
    
    [[UIApplication sharedApplication] openURL:url];
}
@end
