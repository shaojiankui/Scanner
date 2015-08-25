//
//  InfoViewController.h
//  Scanner
//
//  Created by Jakey on 15/8/19.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface InfoViewController : BaseViewController
{
    NSArray *_list;
}
@property(nonatomic,strong) NSDictionary *item;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end
