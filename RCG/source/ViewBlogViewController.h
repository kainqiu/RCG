//
//  ViewBlogViewController.h
//  RCG
//
//  Created by Daniel Ho on 7/27/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewBlogViewController : UITableViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *pubdate;
@property (nonatomic, strong) NSString *content;

@end
