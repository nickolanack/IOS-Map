//
//  OverlayListViewController.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-04.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapOverlayListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
