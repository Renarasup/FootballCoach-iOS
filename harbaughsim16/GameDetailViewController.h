//
//  GameDetailViewController.h
//  harbaughsim16
//
//  Created by Akshay Easwaran on 3/18/16.
//  Copyright © 2016 Akshay Easwaran. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Game;

@interface GameDetailViewController : UITableViewController
-(instancetype)initWithGame:(Game*)game;
@end
