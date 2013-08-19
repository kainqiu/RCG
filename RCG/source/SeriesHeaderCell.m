//
//  SeriesHeaderCell.m
//  RCG
//
//  Created by Daniel Ho on 7/25/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "SeriesHeaderCell.h"

@implementation SeriesHeaderCell
@synthesize description;
@synthesize seriesImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
