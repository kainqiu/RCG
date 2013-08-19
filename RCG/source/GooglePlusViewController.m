//
//  GooglePlusViewController.m
//  RCG
//
//  Created by Daniel Ho on 8/2/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "GooglePlusViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "RCGAppDelegate.h"
#import <GooglePlus/GooglePlus.h>

@interface GooglePlusViewController ()
- (IBAction)signIn:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *signedInLabel;

@end

@implementation GooglePlusViewController

@synthesize signInButton;

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
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    // You previously set kClientId in the "Initialize the Google+ client" step
    static NSString * const kClientId = @"569632773135.apps.googleusercontent.com";

    signIn.clientID = kClientId;
    signIn.scopes = [NSArray arrayWithObjects:
                     kGTLAuthScopePlusLogin, // defined in GTLPlusConstants.h
                     nil];
    signIn.delegate = self;
    self.signedInLabel.hidden = YES;
    
    [signIn trySilentAuthentication];
	// Do any additional setup after loading the view.
    
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        // Do some error handling here.
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

-(void)refreshInterfaceBasedOnSignIn
{
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        self.signInButton.hidden = YES;
        self.signedInLabel.hidden = NO;
        // add refresh button
        
        // Perform other actions here, such as showing a sign-out button
    } else {
        self.signInButton.hidden = NO;
        self.signedInLabel.hidden = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"sign out"
                                                  style:UIBarButtonItemStyleBordered
                                                  target:self
                                                  action:@selector(signOut:)];
        // Perform other actions here
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn:(id)sender {
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [signIn authenticate];
}

- (IBAction)signOut:(id)sender {
    [[GPPSignIn sharedInstance] signOut];
}


- (void)disconnect {
    [[GPPSignIn sharedInstance] disconnect];
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSLog(@"Received error %@", error);
    } else {
        // The user is signed out and disconnected.
        // Clean up user data as specified by the Google+ terms.
    }
}
- (IBAction)didTapShare:(id)sender {
    id<GPPShareBuilder> shareBuilder = [[GPPShare sharedInstance] shareDialog];
    [shareBuilder setURLToShare:[NSURL URLWithString:@"https://www.radicalchangegroup.com"]];
    [shareBuilder setPrefillText:@"Dear Mr. Mahipal Lunia or Mr. Arman Darini or Mr. Sergey Berezin, "];
//    [shareBuilder setTitle:@"Testing!"
//               description:@"Testing the new google circles in the rcg iOS app!"
//              thumbnailURL:[NSURL URLWithString:@"https://www.radicalchangegroup.com"]];
    NSString *copyStringverse = @"publisherrcg@gmail.com";
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyStringverse];
    [shareBuilder open];
}
@end
