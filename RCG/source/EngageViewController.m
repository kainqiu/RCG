//
//  EngageViewController.m
//  RCG
//
//  Created by Daniel Ho on 8/4/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "EngageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface EngageViewController ()
- (IBAction)email:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *shareRCGCommunityFBButton;
@property (strong, nonatomic) IBOutlet UIButton *shareViaEmail;

@end

@implementation EngageViewController

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
    self.shareRCGCommunityFBButton.backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    self.shareViaEmail.backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    [self.shareRCGCommunityFBButton setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.shareViaEmail setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.shareRCGCommunityFBButton.layer.cornerRadius = 6; // this value vary as per your desire
    self.shareRCGCommunityFBButton.clipsToBounds = YES;
    self.shareViaEmail.layer.cornerRadius = 6; // this value vary as per your desire
    self.shareViaEmail.clipsToBounds = YES;
    
//    self.shareViaEmail.titleLabel.textAlignment = UITextAlignmentCenter;
//    [self.shareViaEmail sizeToFit];
//    CGRect frame = self.shareViaEmail.frame;
//    frame.size.width += 70; //l + r padding
//    self.shareViaEmail.frame = frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(  NSError*)error {
    NSLog(@"in didFinishWithResult:");
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"sent");
            break;
        case MFMailComposeResultFailed: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error sending email!",@"Error sending email!")
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Bummer",@"Bummer")
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)email:(id)sender {
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"My Story"];
        [mailViewController setMessageBody:@"" isHTML:NO];
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"info@radicalchangegroup.com"]];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else {
        NSLog(@"Device is unable to send email in its current state.");
    }
}
@end
