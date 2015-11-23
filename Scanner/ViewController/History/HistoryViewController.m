//
//  HistoryViewController.m
//  Scanner
//
//  Created by Jakey on 15/8/17.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import "HistoryViewController.h"
#import "InfoViewController.h"
#import "Cell.h"
#import "Scanner.h"
@interface HistoryViewController ()

@end

@implementation HistoryViewController
static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets=NO;
    [self.myTableView registerNib:[UINib nibWithNibName:@"Cell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _list = [Scanner select:YES];

    [self.myTableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_list count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_list[section] count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([_list count]>0 &&  [_list[section] count]>0) {
        return [NSString stringWithFormat:@"扫描日期:%@",[_list[section][0] objectForKey:@"date"]];
    }
    return @"";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = _list[indexPath.section][indexPath.row];
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        if (indexPath.row<[_list[indexPath.section] count]) {
            NSArray *list =  [Scanner deleteWithTime:[item objectForKey:@"time"]];
            if (list) {
                _list = list;
                [self.myTableView reloadData];
            }
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Cell *cell = (Cell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *item = _list[indexPath.section][indexPath.row];
    cell.result.text = [item objectForKey:@"content"];
    cell.time.text = [item objectForKey:@"time"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //config the cell
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    InfoViewController *info = [[InfoViewController alloc]init];
    info.item =  _list[indexPath.section][indexPath.row];
    [self.navigationController pushViewController:info animated:YES];
    
}
-(void)clean{
    if ([Scanner clean]) {
        _list = [Scanner select:YES];
        [self.myTableView reloadData];
    }
}

@end
