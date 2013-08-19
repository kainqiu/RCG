//
//  HomeTableViewController.m
//  RCG
//
//  Created by Daniel Ho on 7/24/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "HomeTableViewController.h"
#import "PodcastUrl.h"
#import "WatchSeriesTableViewController.h"
#import "RCGAppDelegate.h"
#import "ViewPodcastTableViewController.h"
#import "BasicTableCell.h"
#import <QuartzCore/CoreAnimation.h>
#import <AVFoundation/AVFoundation.h>


@interface HomeTableViewController ()
{
    NSArray *seriesList;
}

@property (nonatomic, strong) NSMutableDictionary *podcastDictionary;
@property (nonatomic, strong) UIWebView *videoView;

@end

@implementation HomeTableViewController

@synthesize podcastDictionary;


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContents) name:@"rssFeedParsed" object:nil];

    
    podcastDictionary = [(NSMutableDictionary *)[NSUserDefaults standardUserDefaults] objectForKey:@"podcast_dictionary"];
    //NSMutableDictionary *blogs = [(NSMutableDictionary *)[NSUserDefaults standardUserDefaults] objectForKey:@"blog_array"];
    seriesList = [podcastDictionary allKeys];
    NSLog(@"seriesList is %@", seriesList.description);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeStarted:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:@"UIMoviePlayerControllerWillExitFullscreenNotification" object:nil];
}

-(void) youTubeStarted:(NSNotification*) notif {
    NSLog(@"youtube started");
    RCGAppDelegate* appDelegate = (RCGAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.fullScreenIsPlaying = YES;
}
-(void) youTubeFinished:(NSNotification*) notif {
    NSLog(@"youtube ended");
    RCGAppDelegate* appDelegate = (RCGAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.fullScreenIsPlaying = NO;
}


- (void) refreshContents
{
    // [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // do whatever needs to be done to refresh the table contents here....
    NSLog(@"HomeTableViewController:refreshContents");
    podcastDictionary = [(NSMutableDictionary *)[NSUserDefaults standardUserDefaults] objectForKey:@"podcast_dictionary"];
    //NSMutableDictionary *blogs = [(NSMutableDictionary *)[NSUserDefaults standardUserDefaults] objectForKey:@"blog_array"];
    seriesList = [podcastDictionary allKeys];
    
    [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
//    NSLog(@"refresh podcast: %@", podcastDictionary.description);
//    NSLog(@"refresh series list: %@", seriesList.description);
//    NSLog(@"refresh blogs: %@", blogs.description);
    
    
    //[self.tableView reloadRowsAtIndexPaths:withRowAnimation:]
    
}

- (void) refreshTableView
{
    [self.tableView reloadData];
}

-(void)refreshButtonWasPressed:(id)sender {
    [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
    NSLog(@"refresh finished");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.audioStreamer != nil) {
        UIBarButtonItem *nowPlayingBtn=[[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingBtnPressed)];
        [self.navigationItem setRightBarButtonItem:nowPlayingBtn];
        self.title = @"RCG";
    }
    
}

-(void) nowPlayingBtnPressed
{
    [self performSegueWithIdentifier:@"nowPlaying" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else
        return seriesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        static NSString *CellIdentifier = @"StarterGuide";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        /*
        NSString *videoURL = @"http://www.youtube.com/embed/oK_KegX2XDQ";
        
        self.videoView = [[UIWebView alloc] initWithFrame:CGRectMake(40, 50, 240, 128)];
        self.videoView.backgroundColor = [UIColor clearColor];
        self.videoView.opaque = NO;
        self.videoView.delegate = self;
        [cell addSubview:self.videoView];
//        cell.contentView.backgroundColor=[UIColor colorWithRed:0.95 green:0.74 blue:0.54 alpha:1];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        BOOL ok;
        NSError *setCategoryError = nil;
        ok = [audioSession setCategory:AVAudioSessionCategoryPlayback
                                 error:&setCategoryError];
        if (!ok) {
            NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
        }
        NSString *videoHTML = [NSString stringWithFormat:@"\
                               <html>\
                               <head>\
                               <style type=\"text/css\">\
                               iframe {position:absolute; top:50%%; margin-top:-130px;}\
                               body {background-color:#000; margin:0;}\
                               </style>\
                               </head>\
                               <body>\
                               <iframe width=\"100%%\" height=\"240px\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
                               </body>\
                               </html>", videoURL];
        
        [self.videoView loadHTMLString:videoHTML baseURL:nil];
         */
        
        UIButton *newButton = [[UIButton alloc] initWithFrame:CGRectMake((screenSize.width - 120)/2, 185, 120, 30)];
        [newButton setTitle:@"Learn More" forState:UIControlStateNormal];
        [newButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [newButton setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
        //[[newButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[newButton layer] setCornerRadius:6];
        //[[newButton layer] setBorderWidth:1.0];
        [newButton addTarget:self action:@selector(newToRCG) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:newButton];
        return cell;
    } else {
        static NSString *CellIdentifier = @"Series";
        BasicTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell.label != nil)
            [cell.label removeFromSuperview];
        cell.label = [[UILabel alloc] initWithFrame:CGRectMake(130, 10, 160, 60)];
        cell.label.text = [seriesList objectAtIndex:indexPath.row];
        cell.label.font = [UIFont fontWithName:@"System" size:12];
        //label.adjustsFontSizeToFitWidth = YES;
        cell.label.lineBreakMode = NSLineBreakByWordWrapping;
        cell.label.numberOfLines = 0;
        [cell addSubview:cell.label];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 5, 120, 70)];
        NSString *imgStr = [NSString stringWithFormat:@"%d.jpg", indexPath.row+1];
        //NSLog(@"index %@", imgStr);
        imageView.image = [UIImage imageNamed:imgStr];
        [cell addSubview:imageView];
        
        return cell;
        
    }

}

-(void)newToRCG
{
    [self performSegueWithIdentifier:@"newToRCG" sender:self];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        return 80;
    }
    else {
        return 260;
    }
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
    if (indexPath.section != 0) {
        [self performSegueWithIdentifier:@"goToSeries" sender:indexPath];

    }
    
//    [self performSegueWithIdentifier:@"goToSeries" sender:indexPath];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = sender;
    if ([[segue identifier] isEqualToString:@"goToSeries"]) {
        WatchSeriesTableViewController *destViewController = segue.destinationViewController;
        NSString *seriesName = [seriesList objectAtIndex:indexPath.row];
        destViewController.seriesName = seriesName;
        destViewController.seriesInfo = [podcastDictionary objectForKey:seriesName];
        destViewController.seriesNumber = indexPath.row + 1;
    } else if ([[segue identifier] isEqualToString:@"nowPlaying"]) {
        ViewPodcastTableViewController *destViewController = segue.destinationViewController;
        destViewController.isCurrentPodcast = YES;
    }
}

//-(BOOL) shouldAutorotate {
//    return NO;
//}
//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationPortrait;
//}


@end
