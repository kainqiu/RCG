//
//  RCGAppDelegate.m
//  RCG
//
//  Created by Daniel Ho on 7/24/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "RCGAppDelegate.h"
#import <dispatch/dispatch.h>
#import "RSSPodcastParser.h"
#import <Parse/Parse.h>
#import <GooglePlus/GooglePlus.h>

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

//#ifndef DEBUG
//[QBSettings useProductionEnvironmentForPushNotifications:YES];
//#endif

#import "WatchSeriesTableViewController.h"
#import "AudioStreamer.h"
#import "InternetConnectionTest.h"

// facebook stuff
#import <FacebookSDK/FacebookSDK.h>
#import "SocialShareViewController.h"

NSString *const FBTestSessionStateChangedNotification =
@"com.facebook.FBTest:FBTestSessionStateChangedNotification";

@interface RCGAppDelegate ()
@property (strong, nonatomic) UINavigationController* navController;

@end
// end of fb

@implementation RCGAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize audioStreamer;
@synthesize streamPath;
@synthesize uiIsVisible;
@synthesize isPlaying;
@synthesize seriesNumber;

@synthesize podcastDictionary;
@synthesize blogArray;


// fb stuff
@synthesize navController = _navController;
@synthesize mainViewController = _mainViewController;
// end of fb


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // set the background of tab bar
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    tabBar.autoresizesSubviews = NO;
    tabBar.clipsToBounds = YES;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    
//    tabBarItem1.title = @"Home";
//    tabBarItem2.title = @"Blogs";
//    tabBarItem3.title = @"Settings";
//    tabBarItem4.title = @"Feedback";
    tabBarItem1.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem3.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem4.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"tabbarHome.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarHome.png"]];
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"tabbarBlogs.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarBlogs.png"]];
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"tabbarSettings.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarSettings.png"]];
    [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:@"tabbarFeedback.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarFeedback.png"]];
    
    
    // Change the tab bar background
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbarBackground.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabselected.png"]];
    
    // Change the title color of tab bar items
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       [UIColor whiteColor], UITextAttributeTextColor,
//                                                       nil] forState:UIControlStateNormal];
//    UIColor *titleHighlightedColor = [UIColor colorWithRed:153/255.0 green:192/255.0 blue:48/255.0 alpha:1.0];
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       titleHighlightedColor, UITextAttributeTextColor,
//                                                       nil] forState:UIControlStateHighlighted];
    
    
    
    // stop spinning on status bar
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    NSLog(@"jr testing...");
	self.uiIsVisible = YES;
    NSDictionary *credentialStorage =
    [[NSURLCredentialStorage sharedCredentialStorage] allCredentials];
    NSLog(@"Credentials: %@", credentialStorage);
//	[viewController createTimers:YES];
//	[viewController forceUIUpdate];
    // Override point for customization after app launch
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(presentAlertWithTitle:)
	 name:ASPresentAlertWithTitleNotification
	 object:nil];
    
    
	[[NSThread currentThread] setName:@"Main Thread"];
//    UIImage* tabBarBackground = [UIImage imageNamed:@"lownavbar.png"];
//    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    
//    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor grayColor] }
//                                             forState:UIControlStateNormal];
//    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor] }
//                                             forState:UIControlStateHighlighted];

    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    // setup parse.
    // todo: replace with custom application ID and key.
    [Parse setApplicationId:@"rOjVWE27JoaafjXS7RkuYqUIuyy7l9j0PiOQ5w55"
                  clientKey:@"remro4LMFgCZfFP54lecYjmNvZqUZTUJXZTULMwk"];
    
    [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation addUniqueObject:@"announcements" forKey:@"channels"];
//    [currentInstallation saveInBackground];
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation addUniqueObject:@"newContent" forKey:@"channels"];
//    [currentInstallation saveInBackground];
    
    
    self.fullScreenIsPlaying = NO;
    
    self.episodeNumber = -1;

    self.isInternetConnectionValid = [InternetConnectionTest isConnectionValidWithTestURL:@"http://www.thewindtradition.org/wp-content/iOSClientValidationFile.dat" ofNSDataLength:320];

    // parse podcast urls
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"podcast_dictionary"] == nil) {
        RSSPodcastParser *rss = [[RSSPodcastParser alloc] initWithURL:@"http://www.radicalchangegroup.com/feed/"];
        dispatch_queue_t parseQueue = dispatch_queue_create("fetchAndParse", NULL);
        dispatch_async(parseQueue, ^
        {
            // start spinning on status bar
            //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [rss startParsingCache:^(BOOL success,NSDictionary *cachedDictionary)
             {
                 if ( success )
                 {
                     [self processRSSFeedDictionary:cachedDictionary];
                 }
                 
                 if ( self.isInternetConnectionValid )
                 {
                     [rss startParsing:^(BOOL success,NSDictionary *dictionary)
                     {
                          if ( success )
                          {
                              [self processRSSFeedDictionary:dictionary];
                          }
                          else
                          {
                              NSLog(@"something went wrong.");
                          }
                     }];
                 }
             }];
        });
//    }

}

- (void) processRSSFeedDictionary: (NSDictionary *)dictionary
{
    self.podcastDictionary = [dictionary mutableCopy];
    self.blogArray = [dictionary objectForKey:@"Blog"];
    [self.podcastDictionary removeObjectForKey:@"Blog"];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.podcastDictionary forKey:@"podcast_dictionary"];
    [[NSUserDefaults standardUserDefaults] setObject:self.blogArray forKey:@"blog_array"];
    
    
    // get all the dictionary set, send notification!
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rssFeedParsed" object:nil];
}

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    [FBProfilePictureView class];
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        self.mainViewController = [[SocialShareViewController alloc] initWithNibName:@"FBTestViewController_iPhone" bundle:nil];
//    } else {
//        self.mainViewController = [[SocialShareViewController alloc] initWithNibName:@"FBTestViewController_iPad" bundle:nil];
//    }
//    self.navController = [[UINavigationController alloc]
//                          initWithRootViewController:self.mainViewController];
//    self.window.rootViewController = self.navController;
//    [self.window makeKeyAndVisible];
//    
//    // See if the app has a valid token for the current state.
//    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
//        // To-do, show logged in view
//        [self showLoginView];
//    } else {
//        // No, display the login page.
//        [self showLoginView];
//    }
//    
//    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
//        // Yes, so just open the session (this won't display any UX).
//        [self openSession];
//    } else {
//        // No, display the login page.
//        [self showLoginView];
//    }
//    
//    return YES;
//    
//}


- (void)dealloc {
//    [viewController release];
//    [window release];
//    [super dealloc];
}

- (void)presentAlertWithTitle:(NSNotification *)notification
{
    NSString *title = [[notification userInfo] objectForKey:@"title"];
    NSString *message = [[notification userInfo] objectForKey:@"message"];
    
    //NSLog(@"Current Thread = %@", [NSThread currentThread]);
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    
    dispatch_async(main_queue, ^{
        
        //NSLog(@"Current Thread (in main queue) = %@", [NSThread currentThread]);
        if (!uiIsVisible) {
#ifdef TARGET_OS_IPHONE
            if(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) {
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                localNotif.alertBody = message;
                localNotif.alertAction = NSLocalizedString(@"Open", @"");
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
//                [localNotif release];
            }
#endif
        }
        else {
#ifdef TARGET_OS_IPHONE
            UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:title
                                   message:message
                                   delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                   otherButtonTitles: nil];
//                                  autorelease
            /*
             [alert
             performSelector:@selector(show)
             onThread:[NSThread mainThread]
             withObject:nil
             waitUntilDone:NO];
             */
            [alert show];
#else
            NSAlert *alert =
            [NSAlert
             alertWithMessageText:title
             defaultButton:NSLocalizedString(@"OK", @"")
             alternateButton:nil
             otherButton:nil
             informativeTextWithFormat:message];
            /*
             [alert
             performSelector:@selector(runModal)
             onThread:[NSThread mainThread]
             withObject:nil
             waitUntilDone:NO];
             */
            [alert runModal];
#endif
        }
    });
}
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	self.uiIsVisible = NO;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	self.uiIsVisible = NO;
//	[viewController createTimers:NO];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	self.uiIsVisible = YES;
//	[viewController createTimers:YES];
//	[viewController forceUIUpdate];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(presentAlertWithTitle:)
	 name:ASPresentAlertWithTitleNotification
	 object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	self.uiIsVisible = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	self.uiIsVisible = NO;
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:ASPresentAlertWithTitleNotification
	 object:nil];
}


// FB stuff--------------------------------------

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            UIViewController *topViewController =
            [self.navController topViewController];
            if ([[topViewController modalViewController]
                 isKindOfClass:[SocialShareViewController class]]) {
                [topViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBTestSessionStateChangedNotification
                                                        object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openSessionWithSuccessBlock:(SuccessBlock)successBlock
{
    NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         if(error) {
             [self sessionStateChanged:session state:state error:error];
         } else {
             NSLog(@"in success block");
             NSLog(@"when open session show session, should has permit email -> %@", session.description);
             if(successBlock) {
                 successBlock();
             }
         }
         NSLog(@"error msg is %@", error.description);
     }];
}

- (void)showLoginView
{
    UIViewController *topViewController = [self.navController topViewController];
    UIViewController *modalViewController;// = [topViewController modalViewController];
    
    // If the login screen is not already displayed, display it. If the login screen is
    // displayed, then getting back here means the login in progress did not successfully
    // complete. In that case, notify the login view so it can update its UI appropriately.
    if (![modalViewController isKindOfClass:[SocialShareViewController class]]) {
        SocialShareViewController* loginViewController = [[SocialShareViewController alloc]
                                                          initWithNibName:@"FBTestLoginViewController"
                                                          bundle:nil];
        [topViewController presentViewController:loginViewController animated:NO completion:nil];
    } else {
        SocialShareViewController* loginViewController =
        (SocialShareViewController*)modalViewController;
        [loginViewController loginFailed];
    }
    //send request test
    //[self sendRequestClicked];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"source application %@", sourceApplication);
    return [FBSession.activeSession handleOpenURL:url];
//    return [GPPURLHandler handleURL:url
//                  sourceApplication:sourceApplication
//                         annotation:annotation];
}

// end of fb stuff ------------------------------------------------

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (self.fullScreenIsPlaying) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
//        if(self.window.rootViewController){
//            UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
//            orientations = [presentedViewController supportedInterfaceOrientations];
//        }
//        return orientations;
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

@end

