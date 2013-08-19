//
//  ViewPodcastTableViewController.m
//  RCG
//
//  Created by Daniel Ho on 7/26/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "ViewPodcastTableViewController.h"
#import "RCGAppDelegate.h"
#import "AudioStreamer.h"
#import "PlayPodcastCell.h"
#import <CFNetwork/CFNetwork.h>
#import "SocialShareViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface ViewPodcastTableViewController ()
{
	NSTimer *progressUpdateTimer;
}

@property (strong, nonatomic) NSMutableDictionary *podcastDictionary;
@property (strong, nonatomic) AudioStreamer *streamer;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UIButton *button;

@end

@implementation ViewPodcastTableViewController

@synthesize podcastDictionary;
@synthesize streamer;
@synthesize button;
@synthesize isCurrentPodcast;
@synthesize podcastName;
@synthesize seriesName;
@synthesize episodeNumber;
@synthesize seriesNumber;

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
    self.podcastDictionary = [(NSMutableDictionary *)[NSUserDefaults standardUserDefaults] objectForKey:@"podcast_dictionary"];
    //NSLog(@"podcast in view podcastController %@", self.podcastDictionary);
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.streamer = delegate.audioStreamer;
    if (isCurrentPodcast == YES) {
        self.podcastName = delegate.podcastName;
        self.seriesName = delegate.seriesName;
        self.episodeNumber = delegate.episodeNumber;
        self.seriesNumber = delegate.seriesNumber;
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *dummyCell = [[UITableViewCell alloc] init];
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"seriesHeader";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [self setUpSeriesHeaderCell:cell];
        return cell;
    }
    else if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"title";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, screenSize.width, 40)];
        title.text = podcastName;
        title.font = [UIFont fontWithName:@"Helvetica" size:13];
        //        [title adjustsFontSizeToFitWidth];
        title.lineBreakMode = NSLineBreakByWordWrapping;
        
        title.textAlignment = NSTextAlignmentCenter;
        title.numberOfLines = 2;
        [cell addSubview:title];
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(5, 50, 40, 40)];
        [self.button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.button setTag:indexPath.row];
        if (delegate.episodeNumber == episodeNumber && delegate.isPlaying == YES && delegate.seriesName == seriesName) {
            [self setButton:self.button ImageNamed:@"pausebutton.png"];
        } else {
            [self setButton:self.button ImageNamed:@"PlayButton2.png"];
        }
        [cell addSubview:self.button];
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(self.button.frame.origin.x + 50, 50, 200, 20)];
        self.slider.minimumValue = 0.0f;
        self.slider.maximumValue = 100.0f;
        if (delegate.audioStreamer != nil && episodeNumber == delegate.episodeNumber && delegate.seriesName == seriesName) {
            NSLog(@"slider value updated as current");
            self.slider.value = 100 * delegate.audioStreamer.progress / delegate.audioStreamer.duration;
        } else {
            self.slider.value = 0.0f;
            NSLog(@"slider value updated not as current");
        }
            
        [self.slider setContinuous:TRUE];
        [self.slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventTouchUpInside];
        if (delegate.audioStreamer != nil && episodeNumber == delegate.episodeNumber && delegate.seriesName == seriesName) {
            progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        }
        [cell addSubview:self.slider];

        return cell;
    }
    return dummyCell;
}

- (void) setUpSeriesHeaderCell:(UITableViewCell *)cell
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 60)];
//    NSString *imgStr = [NSString stringWithFormat:@"%d.jpg", self.seriesNumber];
//    view.image = [UIImage imageNamed:imgStr];
//    [cell addSubview:view];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screenSize.width-20, 100)];
    label.text = [[[podcastDictionary objectForKey:seriesName] objectAtIndex:3] objectAtIndex:episodeNumber];
    label.font = [UIFont fontWithName:@"Helvetica" size:14];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    //    [label sizeToFit];
    [cell addSubview:label];
    UIButton *reviewButton = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - 170, cell.frame.size.height - 35, 160, 30)];
    [reviewButton setTitle:@"Pass it along!" forState:UIControlStateNormal];
    //[self setButton:reviewButton ImageNamed:@"reviewButton.png"];
    [reviewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [reviewButton setBackgroundColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
    [[reviewButton layer] setCornerRadius:6];

    [reviewButton addTarget:self action:@selector(reviewButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:reviewButton];
    
}


-(void)reviewButtonPressed
{
    [self performSegueWithIdentifier:@"share" sender:self];
}

- (void) buttonPressed:(id) sender
{
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([button.currentImage isEqual:[UIImage imageNamed:@"PlayButton2.png"]]) {
        [self setButton:self.button ImageNamed:@"pausebutton.png"];
        if (delegate.podcastName == self.podcastName) {
            NSLog(@"resume");
            [streamer start];
        }
        //Current podcast is not the one playing
        else {
            NSLog(@"start over");
            delegate.episodeNumber = self.episodeNumber;
            delegate.seriesName = self.seriesName;
            delegate.podcastName = self.podcastName;
            [self destroyStreamer];
            [self createStreamer:episodeNumber];
            [streamer start];
        }
        delegate.isPlaying = YES;
    } else if ([button.currentImage isEqual:[UIImage imageNamed:@"pausebutton.png"]]) {
        NSLog(@"button was pause");
        [self setButton:self.button ImageNamed:@"PlayButton2.png"];
        [streamer pause];
        delegate.isPlaying = NO;
    }
}


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
- (void)setButton:(UIButton *)btn ImageNamed:(NSString *)imageName
{
	if (!imageName)
	{
		imageName = @"PlayButton2.png";
	}
	
	UIImage *image = [UIImage imageNamed:imageName];
	
//	[btn.layer removeAllAnimations];
    //    [button setBackgroundImage:image forState:UIControlStateNormal];
    [btn setImage:image forState:0];
    
    //	if ([imageName isEqual:@"loadingbutton.png"])
    //	{
    //		[self spinButton];
    //	}
}

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
        streamer = nil;
    }
    NSLog(@"streamer destroyed");
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer:(int)episodeNumber
{
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *urlString = [[[self.podcastDictionary objectForKey:self.seriesName] objectAtIndex:0] objectAtIndex:self.episodeNumber];
//    NSLog(@"%@", self.seriesName);
//    NSLog(@"%@", [[self.podcastDictionary objectForKey:self.seriesName] description]);
//    NSLog(@"%@", [[[self.podcastDictionary objectForKey:self.seriesName] objectAtIndex:0] description]);
//    NSLog(@"%@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    streamer = [[AudioStreamer alloc] initWithURL:url];
    //	RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.audioStreamer = streamer;
    progressUpdateTimer = nil;
    progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    delegate.audioStreamer = streamer;
    
}
    

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        return 100;
    }
    else if (indexPath.row == 0){
        NSString *cellText = [[[podcastDictionary objectForKey:seriesName] objectAtIndex:3] objectAtIndex:episodeNumber];
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        CGSize constraintSize = CGSizeMake(480.0f, MAXFLOAT);
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        return labelSize.height + 120;
    }
    return 0;
}

- (void) sliderMoved:(UISlider *)aSlider
{
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (episodeNumber == delegate.episodeNumber && delegate.seriesName == seriesName) {
        NSLog(@"streamer %f", streamer.duration);
        if (streamer.duration)
        {
            double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
            [streamer seekToTime:newSeekTime];
            [streamer start];
            [aSlider setValue:100 * streamer.progress / streamer.duration];
        }
    }
    
}

- (void)updateProgress
{
    RCGAppDelegate *delegate = (RCGAppDelegate *)[[UIApplication sharedApplication] delegate];

	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
        double sliderValue = 100 * progress/duration;
        if ( sliderValue > 99.5) {
            NSLog(@"End of stream detected in view podcast");
            if (delegate.episodeNumber < [[[podcastDictionary objectForKey:seriesName] objectAtIndex:0] count] - 1) {
//                delegate.episodeNumber += 1;
//                [self destroyStreamer];
//                [self createStreamer:delegate.episodeNumber];
//                [streamer start];
//                delegate.isPlaying = YES;
                [self.navigationController popViewControllerAnimated:TRUE];
            }
            
        }

		if (duration > 0)
		{
			[self.slider setEnabled:YES];
			[self.slider setValue:100 * progress / duration];
		}
		else
		{
			[self.slider setEnabled:NO];
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
    if ([[segue identifier] isEqualToString:@"share"]) {
        SocialShareViewController *viewController = segue.destinationViewController;
        viewController.URL = [[[self.podcastDictionary objectForKey:self.seriesName] objectAtIndex:0] objectAtIndex:self.episodeNumber];
    }
    
}


@end
