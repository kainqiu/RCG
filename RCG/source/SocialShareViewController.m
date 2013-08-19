//
//  SocialShareViewController.m
//  RCG
//
//  Created by Kain Qiu on 7/26/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//


// TO DO
// 1. add all alerts to success and failure
// 2. change tumblr api_key, register a new app
// 3. change twitter params name
// 4. register a new FB app ID
// 5. pop the current view after sharing : -popViewControllerAnimated:

#import "SocialShareViewController.h"
// for tumblr
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OAAsynchronousDataFetcher.h"
#import "OAServiceTicket.h"
#import "OADataFetcher.h"
#import "AFJSONRequestOperation.h"

// for twitter
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

// for fb
#import <FacebookSDK/FacebookSDK.h>
#import "RCGAppDelegate.h"

#define TUMBLR_CONSUMER_KEY  @"4NzU6ommj832ozancmJitHG5RQDKU2YaNhMEUm9X0wLLlh7Fli"
#define TUMBLR_CONSUMER_SECRET  @"gpWZx7lABUNMhoWceO2xUQTYYDXUCDSh0A5zGjM8lYtmYQsTRE"
#define TUMBLR_REQUEST_TOKEN_URL  @"http://www.tumblr.com/oauth/request_token"
#define TUMBLR_ACCESS_TOKEN_URL  @"http://www.tumblr.com/oauth/access_token"
#define TUMBLR_AUTHORIZE_URL  @"http://www.tumblr.com/oauth/authorize?oauth_token=%@"
#define TUMBLR_BASE_URL @"http://api.tumblr.com/v2/user/iostestrcg.tumblr.com/info"
#define TUMBLR_USER_INFO @"http://api.tumblr.com/v2/user/info"
#define TUMBLR_USER_LOGOUT @"http://www.tumblr.com/logout"

@interface SocialShareViewController ()
// for tumblr
@property (strong, nonatomic) OAConsumer *tumblrConsumer;
@property (strong, nonatomic) OAToken *tumblrAccessToken;

// for twitter
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSArray *accounts;
@property BOOL twitterHasShared;
// for fb
@property (strong, nonatomic) IBOutlet FBProfilePictureView *fbProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *fbUserName;
@property (strong, nonatomic) IBOutlet UITextField *fbUserEmail;

// switch button
@property (strong, nonatomic) IBOutlet UISwitch *fbSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *tumblrSwitch;

// test upload string
@property (strong, nonatomic) NSString *fbString;
@property (strong, nonatomic) NSString *twitterString;
@property (strong, nonatomic) NSString *tumblrString;

@property (strong, nonatomic) NSString *tumblrHostName;

//@property (strong, nonatomic) IBOutlet UITextView *review;
@property (strong, nonatomic) IBOutlet UITextField *tumblrHostnameTextfield;

@property (strong, nonatomic) UITextView *review;

// property for face navigation bar and button to remove tumblr login
@property (strong, nonatomic) UIWebView *tumblrLoginWebView;
@property (strong, nonatomic) UIView *tumblrFakeNavBar;
@property (strong, nonatomic) UIButton *tumblrFakeBackButton;


@end

@implementation SocialShareViewController

@synthesize review;

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
	// Do any additional setup after loading the view.
    // fb
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionStateChanged:)
                                                 name:FBTestSessionStateChangedNotification
                                               object:nil];
    
    // set switch to default off
    [self.fbSwitch setOn:NO];
    [self.twitterSwitch setOn:NO];
    [self.tumblrSwitch setOn:NO];
    // set initial string
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height > 480) {
        NSLog(@"big screen");
        self.review = [[UITextView alloc] initWithFrame:CGRectMake(20, 40, 280, 280)];
    } else {
        self.review = [[UITextView alloc] initWithFrame:CGRectMake(20, 40, 280, 225)];
    }
//    self.review = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 280, 280)];
    self.review.delegate = self;
    [[self.review layer] setBorderWidth:1.0f];
//    [[self.review layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [self.review.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [[self.review layer] setCornerRadius:4];
    self.review.clipsToBounds = YES;
    [self.review.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.review.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.review.layer setShadowOpacity:1.0];
    [self.review.layer setShadowRadius:0.3];
//    [self.review setBackgroundColor:[UIColor colorWithRed:235.0 green:191.0 blue:120.0 alpha:0.5]];
    [self.review setFont:[UIFont systemFontOfSize:14]];
    self.review.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.review];
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    //view.image = [UIImage imageNamed:@"splashpage.png"];
    view.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    view.alpha = 0.3;
    
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
    
    // set twitte share to non-share
    self.twitterHasShared = NO;


    NSLog(@"url %@", self.URL);
//    [self.review becomeFirstResponder];
    
//    
//    [self.comments setDelegate:self];
//    [self.comments setReturnKeyType:UIReturnKeyDone];
    //self.tumblrHostName = @"iostestrcg.tumblr.com";
    
    /*
     // logout tumblr first (remember to delete!!!!!)
     NSURL *url = [NSURL URLWithString:TUMBLR_USER_LOGOUT];
     
     OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
     consumer:self.tumblrConsumer
     token:self.tumblrAccessToken   // we don't have a Token yet
     realm:nil   // our service provider doesn't specify a realm
     signatureProvider:nil]; // use the default method, HMAC-SHA1
     
     [request setHTTPMethod:@"POST"];
     
     OADataFetcher *fetcher = [[OADataFetcher alloc] init];
     
     [fetcher fetchDataWithRequest:request
     delegate:self
     didFinishSelector:@selector(logoutTokenTicket:didFinishWithData:)
     didFailSelector:@selector(logoutTokenTicket:didFailWithError:)];
     */
    
    // clear NSUserDefault of tumblr hostname url (remember to delete!!!!!)
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"tumblrHostname"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    
    //fb logout
    //[FBSession.activeSession closeAndClearTokenInformation];
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showAlert:(NSString *)title withMsg:(NSString *)message {
    // show alert, success to post to tumblr
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [alert show];
}

// alert view for dealing with alert notification

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([[alertView title] isEqual:@"Tumblr Domain"]) {
        NSLog(@"alert view hostname is %@", [alertView textFieldAtIndex:0].text);
        self.tumblrHostName = [alertView textFieldAtIndex:0].text;
        
        [[NSUserDefaults standardUserDefaults] setObject:[alertView textFieldAtIndex:0].text forKey:@"tumblrHostname"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

//----------------------------------------------------------------------------
// post to Tumblr

// clear NSUserDefaults for tumblr hostname url
- (IBAction)resetTumblrHostname:(id)sender {
    [self tumblrLogout];
    [self.tumblrSwitch setOn:NO];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tumblr Domain" message:@"Input full url of your hostname" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void) tumblrLogout {
    NSURL *url = [NSURL URLWithString:TUMBLR_USER_LOGOUT];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.tumblrConsumer
                                                                      token:self.tumblrAccessToken   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(logoutTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(logoutTokenTicket:didFailWithError:)];
}

// logout button pressed
- (IBAction)logout:(id)sender {
    
    NSURL *url = [NSURL URLWithString:TUMBLR_USER_LOGOUT];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.tumblrConsumer
                                                                      token:self.tumblrAccessToken   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(logoutTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(logoutTokenTicket:didFailWithError:)];
}

// logout successful block
- (void)logoutTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    if (ticket.didSucceed)
    {
        NSLog(@"Logged out");
    }
}

// logout failure block
- (void)logoutTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error
{
    NSLog(@"Logout failed - %@", error.description);
}


-(void) postToTumblr
{
    NSLog(@"access token is %@", self.tumblrAccessToken.description);
    NSString *hostnameUrl = [[NSUserDefaults standardUserDefaults] objectForKey: @"tumblrHostname"];
    
    // construct post url of user hostname
    NSString *postURLStr = @"http://api.tumblr.com/v2/blog/";
    postURLStr = [postURLStr stringByAppendingString:hostnameUrl];
    postURLStr = [postURLStr stringByAppendingString:@"/post"];
    NSURL *postURL = [NSURL URLWithString:postURLStr];
    OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:postURL
                                                                    consumer:self.tumblrConsumer
                                                                       token:self.tumblrAccessToken
                                                                       realm:nil
                                                           signatureProvider:nil];
    [oRequest setHTTPMethod:@"POST"];
    
    [oRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // pure text post
    //    OARequestParameter *statusParam1 = [[OARequestParameter alloc] initWithName:@"body"
    //                                                                         value:@"<p><a href='www.google.com'>google</a></p>"];
    //    OARequestParameter *statusParam2 = [[OARequestParameter alloc] initWithName:@"title"
    //                                                                         value:@"sent from ios title"];
    //    OARequestParameter *statusParam3 = [[OARequestParameter alloc] initWithName:@"type"
    //                                                                          value:@"text"];
    
    // link post
    OARequestParameter *statusParam1 = [[OARequestParameter alloc] initWithName:@"title"
                                                                          value:@"Radical Change Group!"];
    OARequestParameter *statusParam2 = [[OARequestParameter alloc] initWithName:@"url"
                                                                          value:self.URL];
    OARequestParameter *statusParam3 = [[OARequestParameter alloc] initWithName:@"description"
                                                                          value:self.review.text];
    // specify type of post. Type by default if text
    OARequestParameter *statusParam4 = [[OARequestParameter alloc] initWithName:@"type"
                                                                          value:@"link"];
    
    NSArray *params = [NSArray arrayWithObjects:statusParam1,statusParam2,statusParam3,statusParam4, nil];
    [oRequest setParameters:params];
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(sendStatusTicket:didFinishWithData:)
                                                                                   didFailSelector:@selector(sendStatusTicket:didFailWithError:)];
    NSLog(@"URL = %@",[oRequest.URL absoluteString]);
    
    [fetcher start];
}


- (void)didReceiveAccessToken:(OAServiceTicket *)ticker data:(NSData *)responseData
{
    
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    //[self showAlert:@"Error" withMsg:[error localizedDescription]];
    // ERROR!
}


// delegate for post blog
- (void)sendStatusTicket:(OAServiceTicket *)ticker didFinishWithData:(NSData *)responseData
{
    //  stop spin
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (ticker.didSucceed) {
        NSLog(@"Success tumblr post!");
        [self showAlert:@"Tumblr" withMsg:@"Your update has been posted."];
        [self.review setText:@""];
        [self.tumblrSwitch setOn:NO];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    NSString *responseBody = [[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding];
    
    NSLog(@"Description = %@",responseBody);
    
}


- (void)sendStatusTicket:(OAServiceTicket *)ticker didFailWithError:(NSError *)error
{
    //  stop spin
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self showAlert:@"Error" withMsg:[error localizedDescription]];
    NSLog(@"Error from tumblr = %@",[error localizedDescription]);
        
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)loginTumblr:(id)sender
{
    self.tumblrConsumer = [[OAConsumer alloc] initWithKey:TUMBLR_CONSUMER_KEY secret:TUMBLR_CONSUMER_SECRET];
    
    NSURL *url = [NSURL URLWithString:TUMBLR_REQUEST_TOKEN_URL];
    
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.tumblrConsumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    
    
}
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSString* newStr = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"tumblr login data is %@", newStr.description);
    if (ticket.didSucceed)
    {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        self.tumblrAccessToken= [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSURL *author_url = [NSURL URLWithString:[ NSString stringWithFormat:TUMBLR_AUTHORIZE_URL,self.tumblrAccessToken.key]];
        NSLog(@"accessToken is %@", self.tumblrAccessToken.key.description);
        OAMutableURLRequest  *oaR = [[OAMutableURLRequest alloc] initWithURL:author_url consumer:nil token:nil realm:nil signatureProvider:nil];
        NSLog(@"webview request is %@", oaR.description);
        
        
        // add tumblr login subview
        UIWebView  *webView =[[UIWebView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height, 320, 568)];
        [[[UIApplication sharedApplication] keyWindow] addSubview:webView];
        webView.delegate=self;
        self.tumblrLoginWebView = webView;
        //webView.frame=self.view.bounds;
        //webView.scalesPageToFit = YES;
        [webView loadRequest:oaR];
        
        // add subview fake navigation bar
        UIView *subNavView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.frame];
        [subNavView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
        //[subNavView setBackgroundColor:[UIColor colorWithRed:54.0f/255.0f green:100.0f/255.0f blue:139.0f/255.0f alpha:1.0f]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:subNavView];
        self.tumblrFakeNavBar = subNavView;
        
        // add button to remove webview
        //UIButton* removeTumblrLoginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIButton* removeTumblrLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 54, 30)];
        //[removeTumblrLoginButton setTag:i];
        [removeTumblrLoginButton setBackgroundColor:[UIColor grayColor]];
        [removeTumblrLoginButton setTitle:@"Back" forState:UIControlStateNormal];
        //[removeTumblrLoginButton setBackgroundImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
        removeTumblrLoginButton.titleLabel.textColor = [UIColor whiteColor];
        removeTumblrLoginButton.layer.cornerRadius = 3; // this value vary as per your desire
        removeTumblrLoginButton.clipsToBounds = YES;
        [removeTumblrLoginButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [subNavView addSubview:removeTumblrLoginButton];
        self.tumblrFakeBackButton = removeTumblrLoginButton;
        
//        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        nextBtn.frame = CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, 30, 30);
//        [nextBtn setBackgroundColor:[UIColor redColor]];
//        nextBtn.titleLabel.text = @"next";
//        nextBtn.titleLabel.textColor = [UIColor blackColor];
//        [nextBtn setTitle:@"Next" forState:UIControlStateNormal];
//        [nextBtn addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [subNavView addSubview:nextBtn];
        
//        UIButton *test = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
//        [test setTitle:@"Title" forState:UIControlStateNormal];
//        [test setBackgroundColor:[UIColor redColor]];
//        [test addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
//        [subNavView addSubview:test];
        
        
    }
}


- (void)testAction {
    NSLog(@"Write something...");
}

// handle remove tumblr login view selector
- (void)buttonClicked:(id)sender
{
//    NSLog(@"Button clicked.");
//    [UIView animateWithDuration:0.5
//                     animations:^{
//                         self.view.frame = CGRectMake(0, 480, 320, 480);
//                         self.view.alpha = 0.0;
//                     }
//                     completion:^(BOOL finished){
//                         [self.tumblrLoginWebView removeFromSuperview];
//                         [self.tumblrFakeBackButton removeFromSuperview];
//                         [self.tumblrFakeNavBar removeFromSuperview];
//                     }
//     ];
    [self.tumblrLoginWebView removeFromSuperview];
    [self.tumblrFakeBackButton removeFromSuperview];
    [self.tumblrFakeNavBar removeFromSuperview];
    [self.tumblrSwitch setOn:NO];
}

// This is to get oAuth_verifier from the url

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"in webView should start load with request");
    if([request.description rangeOfString:@"www.radicalchangegroup.com"].location != NSNotFound && [request.description rangeOfString:@"oauth_token"].location == NSNotFound) {
        NSLog(@"string not found");
        [webView removeFromSuperview];
        [self.tumblrSwitch setOn:NO];
        // remove the fake bar and button
        [self.tumblrFakeBackButton removeFromSuperview];
        [self.tumblrFakeNavBar removeFromSuperview];
    }
    NSString *url = [[request URL] absoluteString];
    NSString *keyOne = @"oauth_token";
    NSString *keyTwo = @"oauth_verifier";
    NSRange r1 =[url rangeOfString:keyOne];
    NSRange r2 =[url rangeOfString:keyTwo];
    if (r1.location!=NSNotFound && r2.location!=NSNotFound) {
        NSLog(@"in first if statement");
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"oauth_verifier"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
        }
        if (verifier) {
            NSLog(@"in if statement with verified");
            NSURL* accessTokenUrl = [NSURL URLWithString:@"http://www.tumblr.com/oauth/access_token"];
            OAMutableURLRequest* accessTokenRequest =[[OAMutableURLRequest alloc] initWithURL:accessTokenUrl
                                                                                     consumer:self.tumblrConsumer
                                                                                        token:self.tumblrAccessToken
                                                                                        realm:nil
                                                                            signatureProvider:nil];
            OARequestParameter* verifierParam =[[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
            [accessTokenRequest setHTTPMethod:@"POST"];
            [accessTokenRequest setParameters:[NSArray arrayWithObjects:verifierParam,nil]];
            OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
            [dataFetcher fetchDataWithRequest:accessTokenRequest
                                     delegate:self
                            didFinishSelector:@selector(requestTokenTicketForAuthorization:didFinishWithData:)
                              didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
        } else {
            NSLog(@"in if statement error");
            [self showAlert:@"Tumblr" withMsg:@"Fail to get authenticity."];
            // ERROR!
        }
        [webView removeFromSuperview];
        
        // remove the fake bar and button
        [self.tumblrFakeBackButton removeFromSuperview];
        [self.tumblrFakeNavBar removeFromSuperview];
        return NO;
    }
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

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

- (void)requestTokenTicketForAuthorization:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    if (ticket.didSucceed)
    {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        self.tumblrAccessToken = [self.tumblrAccessToken initWithHTTPResponseBody:responseBody];
        tumblrAccessText=self.tumblrAccessToken.key;
        tumblrAccessSecret=self.tumblrAccessToken.secret;
        NSLog(@"accessSecret is %@", self.tumblrAccessToken.secret);
        
        // do the post!
        //[self postToTumblr];
        
        // add alert view here!!!
        // set user hostname
        if(![[NSUserDefaults standardUserDefaults] objectForKey: @"tumblrHostname"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tumblr Domain" message:@"Input full url of your hostname" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
        
    }
    else
    {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        NSLog(@"Response = %@",responseBody);
    }
}


- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    [self showAlert:@"Error" withMsg:[error localizedDescription]];
    NSLog(@"Error from tumber = %@",[error localizedDescription]);
}

//----------------------------------------------------------------------------
// post to twitter
@synthesize accounts = _accounts;
@synthesize accountStore = _accountStore;

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

- (void)checkUserLogin {
    if ([TWTweetComposeViewController canSendTweet])
    {
        //yes user is logged in
        NSLog(@"user has logged in");
    }
    else{
        NSLog(@"user has not logged in");
        //show tweeet login prompt to user to login
        TWTweetComposeViewController *viewController = [[TWTweetComposeViewController alloc] init];
        
        //hide the tweet screen
        viewController.view.hidden = YES;
        
        //fire tweetComposeView to show "No Twitter Accounts" alert view on iOS5.1
        viewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
            if (result == TWTweetComposeViewControllerResultCancelled) {
                [self dismissModalViewControllerAnimated:NO];
            }
        };
        [self presentModalViewController:viewController animated:NO];
        
        //hide the keyboard
        [viewController.view endEditing:YES];
    }
}

- (void)postImage:(UIImage *)image withStatus:(NSString *)status
{
    if (_accountStore == nil) {
        self.accountStore = [[ACAccountStore alloc] init];
        if (_accounts == nil) {
            ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
                if(granted) {
                    self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
                    NSLog(@"accounts list are %@", self.accounts.description);
                    // set the account as the last obj of the account array, need to change!!!!!
                    self.account = [self.accounts lastObject];
                    NSLog(@"account info is %@", self.account.description);
                    
                    [self uploadPhoto:image withStatus:status];
                }
            }];
        }
    }
}


// ios 6 way to upload photo
- (void)uploadPhoto:(UIImage *)image withStatus:(NSString *)status
{
    ACAccountType *twitterType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler =
    ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        //  stop spin
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
                // show success alert view
                // should occur on main thread!!!
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlert:@"Twitter" withMsg:@"Your update has been posted."];
                    [self.review setText:@""];
                    [self.twitterSwitch setOn:NO];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    self.twitterHasShared = YES;
                });
            }
            else {
                NSLog(@"[ERROR] Server responded: status code %d %@", statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                if([[NSString stringWithFormat:@"%i", statusCode] isEqual:@"403"]) {
                    NSLog(@"error 403, duplicated post!!!!!!");
                    [self showAlert:@"Error" withMsg:@"Duplicate post on Twitter"];
                }
            }
        }
        else {
            [self showAlert:@"Error" withMsg:[error localizedDescription]];
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
            // link below is different btw pure text post and photo post
            // post photo to twiiter using: @"https://api.twitter.com" @"/1.1/statuses/update_with_media.json"
            NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
            NSDictionary *params = @{@"status" : status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            // upload photo
            //            NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
            //            [request addMultipartData:imageData
            //                             withName:@"media[]"
            //                                 type:@"image/jpeg"
            //                             filename:@"image.jpg"];
            // assuming using the last account of twitter account! need to change!!!!
            [request setAccount:[accounts lastObject]];
            [request performRequestWithHandler:requestHandler];
            
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
            [self showAlert:@"Error" withMsg:[error localizedDescription]];
        }
    };
    
    [self.accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:accountStoreHandler];
}


- (IBAction)postToTwitter:(id)sender {
    [self checkUserLogin];
    [self postImage:[UIImage imageNamed:@"Default.png"] withStatus:self.twitterString];
}

//----------------------------------------------------------------------------
// post to facebook

- (IBAction)postPhoto:(id)sender {
    //[self uploadPhotoToFB:[UIImage imageNamed:@"Default.png"]];
    [self uploadPhotoToTimeline:[UIImage imageNamed:@"Default.png"]];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
}


// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else {
                                                    NSLog(@"permission error is %@", error.description);
                                                }
                                                //For this example, ignore errors (such as if user cancels).
                                            }];
    } else {
        action();
    }
    
}

- (void) uploadPhotoToTimeline:(UIImage *)img {
    
//    [self performPublishAction:^{
//        
//        [FBRequestConnection startForUploadPhoto:img
//                               completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                   [self showAlert:@"Photo Post" result:result error:error];
//                                   //self.buttonPostPhoto.enabled = YES;
//                               }];
//        
//        //self.buttonPostPhoto.enabled = NO;
//    }];

    [self performPublishAction:^{
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:self.URL forKey:@"link"];
        [params setObject:self.review.text forKey:@"message"];
        
        
        [FBRequestConnection startForPostWithGraphPath:@"me/feed"
                                 graphObject:[NSDictionary dictionaryWithDictionary:params]
                           completionHandler:
         ^(FBRequestConnection *connection, id result, NSError *error) {
             //  stop spin
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             
             if (!error) {
                 [[[UIAlertView alloc] initWithTitle:@"Facebook"
                                             message:@"Your update has been posted."
                                            delegate:self
                                   cancelButtonTitle:@"Continue"
                                   otherButtonTitles:nil] show];
                 [self.review setText:@""];
                 [self.fbSwitch setOn:NO];
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             } else {
                 NSLog(@"post error is %@", error.description);
                 [[[UIAlertView alloc] initWithTitle:@"Error"
                                             message:@"Your update has failed to post."
                                            delegate:nil
                                   cancelButtonTitle:@"Continue"
                                   otherButtonTitles:nil] show];
                 NSLog(@"error is %@", error.description);
             }
         }
         ];
        
    }];
}

// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertTitle = @"Error";
        if (error.fberrorShouldNotifyUser ||
            error.fberrorCategory == FBErrorCategoryPermissions ||
            error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
            alertMsg = error.fberrorUserMessage;
        } else {
            alertMsg = @"Operation failed due to a connection problem, retry later.";
        }
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.", message];
        NSString *postId = [resultDict valueForKey:@"id"];
        if (!postId) {
            postId = [resultDict valueForKey:@"postId"];
        }
        if (postId) {
            alertMsg = [NSString stringWithFormat:@"%@\nPost ID: %@", alertMsg, postId];
        }
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

// this method is not used
- (void) uploadPhotoToFB:(UIImage *)image {
    NSLog(@"I'm in upload photo");
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:@"test to post photo to FB thru objective c" forKey:@"message"];
    [params setObject:UIImagePNGRepresentation(image) forKey:@"photo"];
    //BOOL _shareToFbBtn.enabled = NO; //for not allowing multiple hits
    
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error)
     {
         /*
          if (error)
          {
          //showing an alert for failure
          //[self alertWithTitle:@"Facebook" message:@"Unable to share the photo please try later."];
          NSLog(@"fail to upload photo to fb");
          }
          else
          {
          //showing an alert for success
          //[UIUtils alertWithTitle:@"Facebook" message:@"Shared the photo successfully"];
          NSLog(@"success to upload photo to fb");
          }
          // _shareToFbBtn.enabled = YES;
          */
         
         NSString *alertText;
         if (error) {
             NSLog(@"fail to upload photo to fb");
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             NSLog(@"success to upload photo to fb");
             alertText = [NSString stringWithFormat:
                          @"Posted action, id: %@",
                          [result objectForKey:@"id"]];
         }
         // Show the result in an alert
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK!"
                           otherButtonTitles:nil] show];
     }];
}

// logout user
-(void)logoutButtonWasPressed:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
//                 self.userNameLabel.text = user.name;
//                 self.userProfileImage.profileID = user.id;
                 // print user basic info
                 NSLog(@"user id is %@", user.id.description);
                 NSLog(@"user info is %@", user.description);
                 NSLog(@"user email is %@", [[user objectForKey:@"email"] description]);
                 //---notification test---
                 //                 NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 //                                                @"Check out this awesome app.",  @"message",
                 //                                                user.id, @"to",
                 //                                                nil];
                 
                 //[[FacebookSDK facebook] dialog:@"apprequests" andParams:params andDelegate:self];
             }
         }];
    }
}

- (void)sessionStateChanged:(NSNotification*)notification {
    [self populateUserDetails];
}

- (IBAction)performLogin:(id)sender {
    //[self.spinner startAnimating];
    
    RCGAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSessionWithSuccessBlock:nil];
}

- (BOOL)isLogin {
    return FBSession.activeSession.isOpen == YES;
}

- (IBAction)postToFB:(id)sender {
    if([self isLogin]) {
        NSLog(@"in postToFB logged in");
        [self uploadPhotoToTimeline:[UIImage imageNamed:@"Default.png"]];
    } else {
        [self showAlert:@"Facebook" withMsg:@"Not logged in."];
    }
}


- (void)loginFailed {
    
}

//--------------------------------------------------------
// switch on -> login
- (IBAction)fbLogin:(id)sender {
    if([self.fbSwitch isOn] && ![self isLogin]) {
        RCGAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate openSessionWithSuccessBlock:nil];
    }
}

- (IBAction)twitterLogin:(id)sender {
    if([self.twitterSwitch isOn]) {
        [self checkUserLogin];
    }
}

- (IBAction)tumblrLogin:(id)sender {
    
//    // set user hostname
//    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Enter year" message:@"alert message"
//                                        delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
//    alertTextField=[UITextfiled alloc]initwithFrame:CGRectFrame:(5,25,200,35)]; //set the frame as you need.
//    alertTextField.Placeholder=@"Enter Value";
//    alertTextField.keyboardType=UIKeyboardTypeAlphabet;
//    alertTextField.clearsOnBeginEditing=YES;
//    alertTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
//    alertTextField.keyboardAppearance=UIKeyboardAppearanceAlert;
//    [myAlert addSubview:alertTextFiedl];
//    [alertTextField release];
//    [myAlert show];
    
    // tumblr login
    if([self.tumblrSwitch isOn]) {
        self.tumblrConsumer = [[OAConsumer alloc] initWithKey:TUMBLR_CONSUMER_KEY secret:TUMBLR_CONSUMER_SECRET];
        
        NSURL *url = [NSURL URLWithString:TUMBLR_REQUEST_TOKEN_URL];
        
        
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                       consumer:self.tumblrConsumer
                                                                          token:nil   // we don't have a Token yet
                                                                          realm:nil   // our service provider doesn't specify a realm
                                                              signatureProvider:nil]; // use the default method, HMAC-SHA1
        
        [request setHTTPMethod:@"POST"];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        
        [fetcher fetchDataWithRequest:request
                             delegate:self
                    didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                      didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    }

}

// set tumblr hostname
- (IBAction)getTumblrHostname:(id)sender {
    self.tumblrHostName = self.tumblrHostnameTextfield.text;
}


//----------------------------------------------------------
// post for all the social media chosen
- (IBAction)postToSelected:(id)sender {
    [self.review resignFirstResponder];
    
    // check if none of the social network is chosen
    if(![self.fbSwitch isOn] && ![self.twitterSwitch isOn] && ![self.tumblrSwitch isOn]) {
        [self showAlert:@"Error" withMsg:@"No social networks selected."];
    } else {
        if([self.review.text isEqualToString:@""]) {
            [self showAlert:@"Error" withMsg:@"Blank message."];
        } else {
            // start spinning status bar
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            // if error 403 for twitter: probably post the same thing twice!!!!
            NSString *postStr = self.review.text;
            postStr = [postStr stringByAppendingString:@" http://www.radicalchangegroup.com/"];
            if (self.URL == nil) 
                self.URL = @"http://www.radicalchangegroup.com/";
            NSLog(@"post string %@", postStr);
            self.fbString = postStr;
            self.twitterString = postStr;
            self.tumblrString = postStr;
            if([self.twitterSwitch isOn]) {
                if(self.twitterHasShared) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    [self showAlert:@"Error" withMsg:@"Already shared! Go checking other contents and share again."];
                } else {
                    NSLog(@"twitterSwitch is on");
                    [self postImage:[UIImage imageNamed:@"Default.png"] withStatus:self.twitterString];
                }
            } else NSLog(@"twitterSwitch is off");
            
            if([self.fbSwitch isOn]) {
                NSLog(@"fbSwitch is on");
                if([self isLogin]) {
                    NSLog(@"in postToFB logged in");
                    [self uploadPhotoToTimeline:[UIImage imageNamed:@"Default.png"]];
                } else {
                    [self showAlert:@"Facebook" withMsg:@"Not logged in."];
                }
            } else NSLog(@"fbSwitch is off");
            if([self.tumblrSwitch isOn]) {
                [self postToTumblr];
            }
        }
    }
}




@end
