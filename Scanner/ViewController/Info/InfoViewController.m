//
//  InfoViewController.m
//  Scanner
//
//  Created by Jakey on 15/8/19.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import "InfoViewController.h"
#import "JKAlert.h"
#import "Cell.h"
#import "JKToast.h"
@interface InfoViewController ()

@end

@implementation InfoViewController
static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描信息";
    // Do any additional setup after loading the view from its nib.
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    [right setImage:[UIImage imageNamed:@"icon_copy"] forState:UIControlStateNormal];
    right.frame = CGRectMake(0, 0, 20, 20);
    [right addTarget:self action:@selector(copyInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self addRightBarButtonItem:right];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"Cell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _list = [[self.item objectForKey:@"content"] componentsSeparatedByString:@"\n"];
    [self.myTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_list count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = (Cell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.result.text = _list[indexPath.row];
//    cell.time.text = [self.item objectForKey:@"time"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *string =  _list[indexPath.row];
    BOOL result = YES;
    if ([string hasPrefix:@"http"]) {
       result =  [self openurl:string];
    }
    if ([string hasPrefix:@"TEL"]) {
        result = [self openurl:[string stringByReplacingOccurrencesOfString:@"TEL:" withString:@"tel://"]];
    }
    if ([string hasPrefix:@"SMSTO"]) {
        result = [self openurl:[string stringByReplacingOccurrencesOfString:@"SMSTO:" withString:@"sms://"]];
    }
    if ([string hasPrefix:@"EMAIL"]) {
       result =[self openurl:[string stringByReplacingOccurrencesOfString:@"EMAIL:" withString:@"mailto://"]];
    }else{
        result =[self openurl:string];
    }

    if(!result){
        [JKToast showWithText:@"哦偶!打开失败喽!"];

    }
}
-(void)copyInfo:(UIButton*)button{
    [[UIPasteboard generalPasteboard] setPersistent:YES];
    [[UIPasteboard generalPasteboard] setValue:[self.item objectForKey:@"content"] forPasteboardType:[UIPasteboardTypeListString objectAtIndex:0]];
    [JKToast showWithText:@"亲!已经复制到剪切板啦!"];
}

- (BOOL)openurl:(NSString *)aurl
{
    if (aurl) {
        NSURL *url = [NSURL URLWithString:aurl];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            
            return YES;
        }
    }
    return NO;
}

@end
