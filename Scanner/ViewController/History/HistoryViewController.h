//
//  HistoryViewController.h
//  Scanner
//
//  Created by Jakey on 15/8/17.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface HistoryViewController : BaseViewController<UITableViewDelegate>
{
    NSArray *_list;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
-(void)clean;
@end
