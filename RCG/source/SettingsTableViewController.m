//
//  SettingsTableViewController.m
//  RCG
//
//  Created by Daniel Ho on 7/31/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "SettingsTableViewController.h"
#import <Parse/Parse.h>
#import "BasicTableCell.h"

@interface SettingsTableViewController ()
{
    BOOL allAnnouncements;
    BOOL allContent;
}
@property (strong, nonatomic) IBOutlet UISwitch *contentSwitch;
@property (strong, nonatomic) NSArray *keys;
@property (strong, nonatomic) IBOutlet UISwitch *announcementSwitch;
@property (strong, nonatomic) NSMutableArray *uiSwitches;


@end

@implementation SettingsTableViewController

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
    NSMutableDictionary *podcastDictionary = [(NSMutableDictionary *)[NSUserDefaults standardUserDefaults] objectForKey:@"podcast_dictionary"];
    self.keys = [podcastDictionary allKeys];
    
    UISwitch *uiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(225, 10, 30, 20)];
    [uiSwitch setOn:YES];
    [uiSwitch setTag:0];
    [uiSwitch addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
    self.uiSwitches = [[NSMutableArray alloc] initWithObjects:uiSwitch, nil];
    for (int i = 1; i < [self.keys count]; i++) {
        UISwitch *uiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(225, 10, 30, 20)];
        [uiSwitch setOn:NO];
        [uiSwitch setTag:i];
        [uiSwitch addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
        [self.uiSwitches addObject:uiSwitch];
    }
    allAnnouncements = YES;
    allContent = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)contentSwitched
{
    if ([self.contentSwitch isOn]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:@"newContent" forKey:@"channels"];
        [currentInstallation saveInBackground];
    } else {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObject:@"newContent" forKey:@"channels"];
        [currentInstallation saveInBackground];
    }
}

-(void)announcementsSwitched
{
    if ([self.announcementSwitch isOn]) {
        allAnnouncements = YES;
        for (int i = 0; i < [self.keys count]; i++) {
            NSString *keyStr = @"announcement_";
            keyStr = [keyStr stringByAppendingString:[self.keys objectAtIndex:i]];
            NSArray* words = [keyStr componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
            NSString* newString = [words componentsJoinedByString:@""];
            newString = [newString stringByReplacingOccurrencesOfString:@"'" withString:@""];

            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation addUniqueObject:newString forKey:@"channels"];
            [currentInstallation saveInBackground];


        }
        NSLog(@"reload data");
        [self.tableView reloadData];
    } else {
        allAnnouncements = NO;
        for (int i = 0; i < [self.keys count]; i++) {
            NSString *keyStr = @"announcement_";
            keyStr = [keyStr stringByAppendingString:[self.keys objectAtIndex:i]];
            NSArray* words = [keyStr componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
            NSString* newString = [words componentsJoinedByString:@""];
            newString = [newString stringByReplacingOccurrencesOfString:@"'" withString:@""];
            UISwitch *switchBtn = [self.uiSwitches objectAtIndex:i];
            if ([switchBtn isOn]) {
                NSLog(@"%@", newString);
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:newString forKey:@"channels"];
                [currentInstallation saveInBackground];
                [[self.uiSwitches objectAtIndex:i] setOn:YES];
            } else {
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation removeObject:newString forKey:@"channels"];
                [currentInstallation saveInBackground];
                [[self.uiSwitches objectAtIndex:i] setOn:NO];
            }
            
            
        }
        [self.tableView reloadData];
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
    if (allAnnouncements == YES) {
        return 2;
    }
    else
        return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    }else
        return [self.keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", indexPath.description);
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"generalSettings";
        BasicTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.label = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, 200, 40)];
        [cell.label setBackgroundColor:[UIColor clearColor]];
        [cell.label setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        cell.label.text = @"  Recordings and Blogs";
        [cell addSubview:cell.label];
        if (self.contentSwitch != nil)
            [self.contentSwitch removeFromSuperview];
        self.contentSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(225, 10, 30, 20)];
        if (allContent == YES)
            [self.contentSwitch setOn:YES];
        else
            [self.contentSwitch setOn:NO];
        [self.contentSwitch addTarget:self action:@selector(contentSwitched) forControlEvents:UIControlEventValueChanged];
        
        [cell addSubview:self.contentSwitch];
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"generalSettings";
        BasicTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.label = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, 200, 40)];
        [cell.label setBackgroundColor:[UIColor clearColor]];
        [cell.label setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        cell.label.text = @"  All Anouncements";
        [cell addSubview:cell.label];
        if (self.announcementSwitch != nil)
            [self.announcementSwitch removeFromSuperview];
        self.announcementSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(225, 10, 30, 20)];
        [self.announcementSwitch addTarget:self action:@selector(announcementsSwitched) forControlEvents:UIControlEventValueChanged];
        if (allAnnouncements == YES)
            [self.announcementSwitch setOn:YES];
        else
            [self.announcementSwitch setOn:NO];
        [cell addSubview:self.announcementSwitch];
        UILabel *subtitles = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 280, 40)];
        subtitles.text = @"Turn this off to select specific types";
        [subtitles setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        [subtitles setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:subtitles];
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"specificSettings";
        BasicTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell.label != nil)
            [cell.label removeFromSuperview];
        cell.label = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, 200, 40)];
        [cell.label setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [cell.label setLineBreakMode:NSLineBreakByWordWrapping];
        [cell.label setNumberOfLines:2];
        [cell.label setBackgroundColor:[UIColor clearColor]];
        cell.label.text = [self.keys objectAtIndex:indexPath.row];
        
        [cell addSubview:cell.label];

        cell.switchBtn = [self.uiSwitches objectAtIndex:indexPath.row];
        cell.switchBtn.frame = CGRectMake(225, 10, 30, 20);
        [cell addSubview:cell.switchBtn];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 50;
    }
    else if (indexPath.section == 1){
        return 100;
    } else {
        return 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionName = nil;

    switch (section) {
        case 0:
            sectionName = [NSString stringWithFormat:@"    Receive Notifications for "];
            break;
        case 1:
            sectionName = [NSString stringWithFormat:@"    Receive Notifications for "];
            break;
        case 2:
            sectionName = [NSString stringWithFormat:@"    Choose Specific Types of Announcements"];
            break;
    }

    UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 40)];
    sectionHeader.backgroundColor = [UIColor clearColor];
    sectionHeader.font = [UIFont boldSystemFontOfSize:15];
    sectionHeader.textColor = [UIColor blackColor];
    sectionHeader.text = sectionName;

    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

-(void)switched:(id)sender
{
    UISwitch *switchBtn = (UISwitch *)sender;
    int tag = switchBtn.tag;
    NSString *keyStr = @"announcement_";
    keyStr = [keyStr stringByAppendingString:[self.keys objectAtIndex:tag]];
    NSArray* words = [keyStr componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
    NSString* newString = [words componentsJoinedByString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"'" withString:@""];
    if ([switchBtn isOn]) {
        NSLog(@"%@", newString);
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:newString forKey:@"channels"];
        [currentInstallation saveInBackground];
        [[self.uiSwitches objectAtIndex:tag] setOn:YES];
    } else {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObject:newString forKey:@"channels"];
        [currentInstallation saveInBackground];
        [[self.uiSwitches objectAtIndex:tag] setOn:NO];
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

@end
