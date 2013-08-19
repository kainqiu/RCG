//
//  ViewBlogViewController.m
//  RCG
//
//  Created by Daniel Ho on 7/27/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "ViewBlogViewController.h"
#import "RCGAppDelegate.h"
#import "ViewPodcastTableViewController.h"
#import <QuartzCore/CoreAnimation.h>


@interface ViewBlogViewController ()
{
    int webViewRowHeight;
}
@property (nonatomic, strong) UIWebView *myWebView;



@end

@implementation ViewBlogViewController
@synthesize name;
@synthesize description;
@synthesize pubdate;
@synthesize content;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"name: %@", self.name);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
//    NSLog(@"content: %@", self.content);
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.audioStreamer != nil) {
        UIBarButtonItem *nowPlayingBtn=[[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingBtnPressed)];
        [self.navigationItem setRightBarButtonItem:nowPlayingBtn];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"name";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, cell.frame.size.height)];
        title.text = self.name;
        title.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
//        [title adjustsFontSizeToFitWidth];
        title.lineBreakMode = NSLineBreakByWordWrapping;

        title.textAlignment = NSTextAlignmentCenter;
        title.numberOfLines = 2;
        [cell addSubview:title];
        return cell;
    } else if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"info";
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 50)];
        info.text = self.pubdate;
        info.font = [UIFont fontWithName:@"Helvetica-Bold" size:9];
        [info adjustsFontSizeToFitWidth];
        info.numberOfLines = 1;
        [cell addSubview:info];
        
//        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - 40, cell.frame.size.height - 35, 30, 30)];
//        [shareButton setImage:[UIImage imageNamed:@"ShareButton.png"] forState:UIControlStateNormal];
//        [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:shareButton];
        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - 170, cell.frame.size.height - 35, 160, 30)];
        [shareButton setTitle:@"Pass it along!" forState:UIControlStateNormal];
        //[self setButton:shareButton ImageNamed:@"ShareButton.png"];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareButton setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
        [[shareButton layer] setCornerRadius:6];
        [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:shareButton];
        return cell;
    } else if (indexPath.row == 2) {
        NSLog(@"set up webViewCell");
        static NSString *CellIdentifier = @"description";
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (self.myWebView) {
            [self.myWebView removeFromSuperview];
        }
        self.myWebView=[[UIWebView alloc] initWithFrame:CGRectMake(10, 0, screenSize.width - 20, webViewRowHeight)];
        //self.myWebView=[[UIWebView alloc] initWithFrame:CGRectZero];
        self.myWebView.delegate=self;
//        self.myWebView.scrollView.scrollEnabled = NO;
//        self.myWebView.scrollView.bounces = NO;
//        self.myWebView.scrollView.pagingEnabled = YES;
        [self.myWebView loadHTMLString:self.content baseURL:nil];
        
        [self.myWebView setBackgroundColor:[UIColor lightGrayColor]];
        [cell addSubview:self.myWebView];
        return cell;
    } else if (indexPath.row == 3) {
        static NSString *CellIdentifier = @"shareCell";
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, screenSize.width - 20, 37)];
        [shareButton setTitle:@"Pass it along!" forState:UIControlStateNormal];
        //[self setButton:shareButton ImageNamed:@"ShareButton.png"];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareButton setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
        [[shareButton layer] setCornerRadius:6];
        //[[shareButton layer] setBorderColor:[[UIColor blackColor] CGColor]];
        //[[shareButton layer] setBorderWidth:1.0];
        [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:shareButton];
        return cell;
    } else {
        static NSString *CellIdentifier = @"shareCell";
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, screenSize.width - 20, 37)];
        [shareButton setTitle:@"Share your RCG experience with us!" forState:UIControlStateNormal];
        //[self setButton:shareButton ImageNamed:@"ShareButton.png"];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareButton setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
        [[shareButton layer] setCornerRadius:6];
        //[[shareButton layer] setBorderColor:[[UIColor blackColor] CGColor]];
        //[[shareButton layer] setBorderWidth:1.0];
        [shareButton addTarget:self action:@selector(giveFeedback:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:shareButton];
        return cell;
    }
   
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.myWebView.scrollView.contentOffset.y > 0  ||  self.myWebView.scrollView.contentOffset.y < 0 )
        self.myWebView.scrollView.contentOffset = CGPointMake(self.myWebView.scrollView.contentOffset.x, 0);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    if (webViewRowHeight == 0) {
        CGRect webViewFrame = webView.frame;
        webViewFrame.size.height = 1;
        webView.frame = webViewFrame;
        CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
        webViewFrame.size = fittingSize;
        // webViewFrame.size.width = 276; Making sure that the webView doesn't get wider than 276 px
        webView.frame = webViewFrame;
        webViewRowHeight = webView.frame.size.height;
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    if (indexPath.row == 0) {
        return 30;
    } else if (indexPath.row == 1) {
        return 60;
    } else if (indexPath.row == 2){
        return webViewRowHeight;
//        NSLog(@"report webView height %f", self.myWebView.frame.size.height);
//        return self.myWebView.frame.size.height;
    } else {
        return 50;
    }
}

-(void) shareButtonPressed
{
    [self performSegueWithIdentifier:@"share" sender:self];
}

-(void) nowPlayingBtnPressed
{
    [self performSegueWithIdentifier:@"nowPlaying" sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"nowPlaying"]) {
        ViewPodcastTableViewController *destViewController = segue.destinationViewController;
        destViewController.isCurrentPodcast = YES;
    }
    
}

- (void)giveFeedback:(id)sender {
    
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:self.name];
        [mailViewController setMessageBody:@"" isHTML:NO];
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"info@radicalchangegroup.com"]];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else {
        NSLog(@"Device is unable to send email in its current state.");
    }
    
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




@end
