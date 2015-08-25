//
//  Cell.h
//  Scanner
//
//  Created by Jakey on 15/8/20.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UILabel *time;
-(void)configCell:(id)data;
@end
