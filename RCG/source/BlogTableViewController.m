//
//  BlogTableViewController.m
//  RCG
//
//  Created by Daniel Ho on 7/27/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "BlogTableViewController.h"
#import "ViewBlogViewController.h"
#import "RCGAppDelegate.h"
#import "ViewPodcastTableViewController.h"
#import "BasicTableCell.h"

@interface BlogTableViewController ()

@end

@implementation BlogTableViewController
@synthesize blogArray;

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
    self.blogArray = [[NSUserDefaults standardUserDefaults]  objectForKey:@"blog_array"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContents) name:@"rssFeedParsed" object:nil];
    
    
}

-(void)refreshButtonWasPressed:(id)sender {
    [self.tableView reloadData];
    NSLog(@"refresh finished");
}

- (void) refreshContents
{
    NSLog(@"in blogTableView, refreshContents");
    self.blogArray = [[NSUserDefaults standardUserDefaults]  objectForKey:@"blog_array"];
    //NSLog(@"self blog array is %@", self.blogArray.description);
    [self.tableView reloadData];
    //[self.tableView reloadRowsAtIndexPaths:withRowAnimation:]
    
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
    return [[blogArray objectAtIndex:1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"blog";
    BasicTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (cell.label != nil) 
        [cell.label removeFromSuperview];
    cell.label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, screenSize.width - 90, 50)];
    cell.label.text = [[blogArray objectAtIndex: 1]  objectAtIndex:indexPath.row];
    cell.label.font = [UIFont fontWithName:@"Helvetica" size:12];
    cell.label.lineBreakMode = NSLineBreakByWordWrapping;
    cell.label.numberOfLines = 2;
    [cell addSubview:cell.label];
    if (cell.pubdateLabel != nil)
        [cell.pubdateLabel removeFromSuperview];
    cell.pubdateLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenSize.width - 80, 5, 80, 10)];
    cell.pubdateLabel.text = [[blogArray objectAtIndex: 4]  objectAtIndex:indexPath.row];
    cell.pubdateLabel.font = [UIFont fontWithName:@"Helvetica" size:9];
    cell.pubdateLabel.textColor = [UIColor grayColor];
    [cell addSubview:cell.pubdateLabel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    [self performSegueWithIdentifier:@"viewBlog" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = sender;
    if ([[segue identifier] isEqualToString:@"viewBlog"]) {
        ViewBlogViewController *destViewController = segue.destinationViewController;
        destViewController.name = [[blogArray objectAtIndex:1] objectAtIndex:indexPath.row];
        destViewController.description = [[blogArray objectAtIndex:3] objectAtIndex:indexPath.row];
        destViewController.pubdate = [[blogArray objectAtIndex:4] objectAtIndex:indexPath.row];
        destViewController.content = [[blogArray objectAtIndex:5] objectAtIndex:indexPath.row];
    }
    else if ([[segue identifier] isEqualToString:@"nowPlaying"]) {
        ViewPodcastTableViewController *destViewController = segue.destinationViewController;
        destViewController.isCurrentPodcast = YES;
    }

}

@end
