//
//  WatchSeriesTableViewController.m
//  RCG
//
//  Created by Daniel Ho on 7/24/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "WatchSeriesTableViewController.h"
#import "PlayPodcastCell.h"
#import "AudioStreamer.h"
#import "PodcastUrl.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "RCGAppDelegate.h"
#import "OverlayObj.h"
#import "SocialShareViewController.h"
#import "ViewPodcastTableViewController.h"



@interface WatchSeriesTableViewController ()
@property (nonatomic, strong) UIButton *currentButton;
@end

@implementation WatchSeriesTableViewController
@synthesize seriesName;
@synthesize episodeList;
@synthesize seriesInfo;
@synthesize seriesNumber;
@synthesize currentButton;

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
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(delegate.audioStreamer) {
        streamer = delegate.audioStreamer;
        NSLog(@"progress %f", delegate.audioStreamer.progress);
    }
//    NSLog(@"series info %@", seriesInfo.description);
//    NSLog(@"series name %@", self.seriesName);
    self.title = self.seriesName;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1){
        return [[seriesInfo objectAtIndex:0] count];
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"seriesHeader";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [self setUpSeriesHeaderCell:cell];
        return cell;
    } else if (indexPath.section == 1){
        static NSString *CellIdentifier = @"episode";
        PlayPodcastCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 45, 45)];
        [playButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [playButton setTag:indexPath.row];
        if (indexPath.row == delegate.episodeNumber && delegate.isPlaying == YES && delegate.seriesName == seriesName) {
            [self setButton:playButton ImageNamed:@"pausebutton.png"];
        } else {
            [self setButton:playButton ImageNamed:@"PlayButton2.png"];
        }
        cell.playButton = playButton;
        [cell addSubview:cell.playButton];
        [cell.nameLabel removeFromSuperview];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 200, 45)];
        label.text = [[seriesInfo objectAtIndex:1] objectAtIndex:([[seriesInfo objectAtIndex:1] count] - indexPath.row - 1)];
        label.font = [UIFont fontWithName:@"System" size:6];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 2;
//            label.adjustsFontSizeToFitWidth = YES;
        cell.nameLabel = label;
        [cell addSubview:cell.nameLabel];
        if (cell.slider != nil) {
            [cell.slider removeFromSuperview];
        }
        cell.slider = [[UISlider alloc] initWithFrame:CGRectMake(80, 60, 200, 20)];
        cell.slider.minimumValue = 0.0f;
        cell.slider.maximumValue = 100.0f;
        if (delegate.audioStreamer != nil && indexPath.row == delegate.episodeNumber && delegate.seriesName == seriesName) {
            cell.slider.value = 100 * delegate.audioStreamer.progress / delegate.audioStreamer.duration;
        } else
            cell.slider.value = 0.0f;
        
        [cell.slider setContinuous:TRUE];
        [cell.slider setTag:indexPath.row];
        [cell.slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:cell.slider];
//        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width - 35, cell.frame.size.height - 35, 30, 30)];
//        [self setButton:shareButton ImageNamed:@"ShareButton.png"];
//        [downloadButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:shareButton];
        
        tableView.separatorColor = [UIColor clearColor];
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        line.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
        [cell addSubview:line];
        
        return cell;
    } else {
        //tableView.separatorColor = [UIColor clearColor];
        static NSString *CellIdentifier = @"shareCell";
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, screenSize.width - 20, 37)];
        if(indexPath.row == 0) {
            [shareButton setTitle:@"Pass it along!" forState:UIControlStateNormal];
        } else {
            [shareButton setTitle:@"Share your RCG experience with us!" forState:UIControlStateNormal];
        }
        //[self setButton:shareButton ImageNamed:@"ShareButton.png"];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareButton setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
        [[shareButton layer] setCornerRadius:6];
        //[[shareButton layer] setBorderColor:[[UIColor blackColor] CGColor]];
        //[[shareButton layer] setBorderWidth:1.0];
        if(indexPath.row == 0) {
            [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [shareButton addTarget:self action:@selector(giveFeedback:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell addSubview:shareButton];
        
        return cell;
    }
    
}

- (void) setUpSeriesHeaderCell:(UITableViewCell *)cell
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 60)];
//    NSString *imgStr = [NSString stringWithFormat:@"%d.jpg", self.seriesNumber];
//    view.image = [UIImage imageNamed:imgStr];
//    view.alpha = 0.1;
//    [cell setBackgroundView:view];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screenSize.width-20, 120)];
    label.text = [[seriesInfo objectAtIndex:3] objectAtIndex:0];
    label.font = [UIFont fontWithName:@"Helvetica" size:14];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [label setBackgroundColor:[UIColor clearColor]];
    [label sizeToFit];
    [cell addSubview:label];
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - 170, cell.frame.size.height - 35, 160, 30)];
    [shareButton setTitle:@"Pass it along!" forState:UIControlStateNormal];
    //[self setButton:shareButton ImageNamed:@"ShareButton.png"];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
    [[shareButton layer] setCornerRadius:6];
    [shareButton addTarget:self action:@selector(reviewButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:shareButton];
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(10, cell.frame.size.height - 35, 80, 30)];
    [self setButton:downloadButton ImageNamed:@"itunes.jpg"];
    [downloadButton addTarget:self action:@selector(downloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:downloadButton];
//    UILabel *downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, cell.frame.size.height - 10, 80, 10)];
//    downloadLabel.text = @"download from iTunes";
//    downloadLabel.font = [UIFont fontWithName:@"Helvetica" size:6];
////    downloadLabel.textColor = [UIColor grayColor];
//    [cell addSubview:downloadLabel];
}

- (void) downloadButtonPressed
{
    NSLog(@"download button pressed");
    NSString *address = @"itms://itunes.apple.com/us/podcast/radical-nlp-mythology-spirituality/id263470927?mt=2";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *cellText = [[seriesInfo objectAtIndex:3] objectAtIndex:0];
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        CGSize constraintSize = CGSizeMake(480.0f, MAXFLOAT);
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        return labelSize.height + 170;
    }
    else if (indexPath.section == 1){
        return 100;
    } else {
        return 45;
    }
}

- (void) reviewButtonPressed
{
    [self performSegueWithIdentifier:@"share" sender:self];
}

-(void)shareButtonPressed
{
    [self performSegueWithIdentifier:@"share" sender:self];
}

- (void) buttonPressed:(id) sender
{
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSLog(@"button pressed");
    NSLog(@"old episode number: %d", delegate.episodeNumber);
    UIButton *button = sender;
    self.currentButton = button;
    int newEpisodeNumber = button.tag;
    if ([currentButton.currentImage isEqual:[UIImage imageNamed:@"PlayButton2.png"]]) {
        if (delegate.episodeNumber == newEpisodeNumber && delegate.seriesName == seriesName) {
            NSLog(@"resume");
            [self setButton:currentButton ImageNamed:@"pausebutton.png"];
            [streamer start];
            delegate.isPlaying = YES;
        } else {
            NSLog(@"start over");
            [self setButton:currentButton ImageNamed:@"pausebutton.png"];
            [self destroyStreamer];
            [self createStreamer:[NSIndexPath indexPathForRow:newEpisodeNumber inSection:0]];
            [streamer start];
            delegate.isPlaying = YES;
            [self.tableView reloadData];
        }
    } else if ([currentButton.currentImage isEqual:[UIImage imageNamed:@"pausebutton.png"]]) {
        NSLog(@"current button is pause");
        [self setButton:currentButton ImageNamed:@"PlayButton2.png"];
        [streamer pause];
        delegate.isPlaying = NO;
    } else {
        NSLog(@"reloading");
        delegate.episodeNumber = newEpisodeNumber;
        [self destroyStreamer];
        [self createStreamer:[NSIndexPath indexPathForRow:delegate.episodeNumber inSection:0]];
        [streamer start];
        delegate.isPlaying = NO;
        [self.tableView reloadData];
    }
    delegate.episodeNumber = newEpisodeNumber;
    delegate.seriesName = seriesName;
    delegate.podcastName = [[seriesInfo objectAtIndex:1] objectAtIndex:[[seriesInfo objectAtIndex:1] count] - delegate.episodeNumber - 1];
    delegate.seriesNumber = self.seriesNumber;
}


//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{

        RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];

        [streamer stop];
        [delegate.audioStreamer stop];
        [progressUpdateTimer invalidate];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer:(NSIndexPath *)indexPath
{
	if (streamer)
	{
		return;
	}
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.streamPath = indexPath;
    NSString *urlString = [[seriesInfo objectAtIndex:0] objectAtIndex:indexPath.row];
    //NSlog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
	streamer = [[AudioStreamer alloc] initWithURL:url];
//	RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.audioStreamer = streamer;
    progressUpdateTimer = nil;
	progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];

}


- (void) sliderMoved:(UISlider *)aSlider
{
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger tag = [aSlider tag];
    if (tag == delegate.episodeNumber) {
        if (streamer.duration)
        {
            double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
            aSlider.value = 100 * streamer.progress / streamer.duration;
            NSLog(@"sider adjusted");
            [streamer seekToTime:newSeekTime];
            [streamer start];
        }
    } else {
        aSlider.value = 0.0;
    }
    
    
}

//
// setButtonImageNamed:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    imageNamed - the name of the image to set on the play button.
//
- (void)setButton:(UIButton *)button ImageNamed:(NSString *)imageName
{
	if (!imageName)
	{
		imageName = @"PlayButton2.png";
	}
	currentImageName = imageName;
	
	UIImage *image = [UIImage imageNamed:imageName];
	
	[button.layer removeAllAnimations];
//    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setImage:image forState:0];
    
//	if ([imageName isEqual:@"loadingbutton.png"])
//	{
//		[self spinButton];
//	}
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress
{
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:delegate.episodeNumber inSection:1];
    PlayPodcastCell *cell = (PlayPodcastCell *)[self.tableView cellForRowAtIndexPath:indexPath];

	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
        double sliderValue = 100 * progress/duration;
        if ( sliderValue > 99.5) {
            NSLog(@"End of stream detected in watch series");
            if (delegate.episodeNumber < [[seriesInfo objectAtIndex:0] count] - 1) {
                delegate.episodeNumber += 1;
                [self setButton:cell.playButton ImageNamed:@"pausebutton.png"];
                [self destroyStreamer];
                [self createStreamer:[NSIndexPath indexPathForRow:delegate.episodeNumber inSection:0]];
                [streamer start];
                delegate.isPlaying = YES;
                delegate.podcastName = [[seriesInfo objectAtIndex:1] objectAtIndex:[[seriesInfo objectAtIndex:1] count] - delegate.episodeNumber - 1];
                [self.tableView reloadData];
            }
            
        }
		if (duration > 0)
		{
			[cell.slider setEnabled:YES];
			[cell.slider setValue:100 * progress / duration];
		}
		else
		{
			[cell.slider setEnabled:NO];
		}
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
        [self performSegueWithIdentifier:@"podcastDetail" sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];

    
    if ([[segue identifier] isEqualToString:@"share"]) {
        
    } else if ([[segue identifier] isEqualToString:@"podcastDetail"]) {
        NSIndexPath *indexPath = sender;
        ViewPodcastTableViewController *destViewController = segue.destinationViewController;
        if (delegate.episodeNumber == indexPath.row && self.seriesName == delegate.seriesName) {
            destViewController.isCurrentPodcast = YES;
            NSLog(@"is current podcast");
        } else {
            destViewController.isCurrentPodcast = NO;
            NSLog(@"is not current podcast");
        }
        destViewController.podcastName = [[seriesInfo objectAtIndex:1] objectAtIndex:[[seriesInfo objectAtIndex:1] count] - indexPath.row - 1];
        destViewController.seriesName = self.seriesName;
        destViewController.episodeNumber = indexPath.row;
        destViewController.seriesNumber = self.seriesNumber;
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



- (void)giveFeedback:(id)sender {
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:self.seriesName];
        [mailViewController setMessageBody:@"" isHTML:NO];
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"info@radicalchangegroup.com"]];
        [mailViewController becomeFirstResponder];
        
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else {
        NSLog(@"Device is unable to send email in its current state.");
    }
    
}


@end
