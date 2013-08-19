//
//  BasicTableCell.h
//  RCG
//
//  Created by Daniel Ho on 7/30/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicTableCell : UITableViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *view;
@property (nonatomic, strong) UILabel *pubdateLabel;
@property (nonatomic, strong) UISwitch *switchBtn;
@end
