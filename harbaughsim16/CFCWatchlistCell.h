//
//  CFCWatchlistCell.h
//  harbaughsim16
//
//  Created by Akshay Easwaran on 1/5/18.
//  Copyright © 2018 Akshay Easwaran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFCWatchlistCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *interestLabel;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *activitiesLabel;
@end
