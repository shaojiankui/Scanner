//
//  RootViewController.m
//  Scanner
//
//  Created by Jakey on 15/8/17.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import "RootViewController.h"
#import "ScanViewController.h"
#import "HistoryViewController.h"
#import "InfoViewController.h"
#import "MakerViewController.h"
#import "RecognizeViewController.h"

#import "JKAlert.h"
#import "DateManager.h"
#import "Scanner.h"
@interface RootViewController ()
{
    ScanViewController *_scan;
    HistoryViewController *_history;
    MakerViewController *_maker;
    RecognizeViewController *_recognize;
    UIButton *_turnButton;
}
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"二维码/条码扫描";
    self.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    __weak typeof(self) weakSelf = self;
    _scan = [[ScanViewController alloc]init];
    [_scan finishingBlock:^(NSString *string) {
        [weakSelf addNewRecord:string];
    }];
    _recognize = [[RecognizeViewController alloc]init];
    _recognize.tabBarItem.title=@"识别图片";
    _recognize.tabBarItem.image = [UIImage imageNamed:@"icon_find.png"];
    _recognize.navigationItem.title = @"识别图片";
    [_recognize recognizeFinishingBlock:^(NSString *string) {
        [weakSelf addNewRecord:string];
    }];
    _scan.tabBarItem.title=@"扫描";
    _scan.tabBarItem.image = [UIImage imageNamed:@"icon_qrcode.png"];
    _scan.navigationItem.title=@"二维码/条码扫描";

    _history = [[HistoryViewController alloc]init];
    _history.tabBarItem.title=@"扫描历史";
    _history.tabBarItem.image = [UIImage imageNamed:@"icon_history.png"];
    _history.navigationItem.title = @"扫描历史";
    
    _maker = [[MakerViewController alloc]init];
    _maker.tabBarItem.title=@"生成";
    _maker.tabBarItem.image = [UIImage imageNamed:@"icon_make.png"];
    _maker.navigationItem.title=@"生成二维码";
    
 
    self.viewControllers = @[_scan,_history,_maker,_recognize];
    self.selectedViewController = _scan;
    [self tabBarController:self didSelectViewController:_scan];
    
}
-(void)addNewRecord:(NSString*)scan{
    NSLog(@"scan string:%@",scan);
    InfoViewController *info = [[InfoViewController alloc]init];
    NSDictionary *item =  @{@"time":[DateManager nowTimeStampString],@"date":[DateManager stringConvert_YMD_FromDate:[NSDate date]],@"content":scan?:@""};
    info.item = item;
    [Scanner insert:item];
    [self.navigationController pushViewController:info animated:YES];
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
   self.title = viewController.navigationItem.title;
    
    if ([viewController isKindOfClass:[HistoryViewController class]]) {
        UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
        [right setImage:[UIImage imageNamed:@"icon_clean"] forState:UIControlStateNormal];
        right.frame = CGRectMake(0, 0, 20, 20);
        [right addTarget:self action:@selector(clearHistory:) forControlEvents:UIControlEventTouchUpInside];
        [self addRightBarButtonItem:right];
    }
     if ([viewController isKindOfClass:[ScanViewController class]]) {
        _turnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_turnButton setImage:[UIImage imageNamed:@"icon_light_normal.png"] forState:UIControlStateNormal];
        [_turnButton setImage:[UIImage imageNamed:@"icon_light.png"] forState:UIControlStateSelected];

        _turnButton.frame = CGRectMake(0, 0, 20, 20);
        [_turnButton addTarget:self action:@selector(turnLightTouched:) forControlEvents:UIControlEventTouchUpInside];
         _turnButton.selected = _scan.lighting;
        [self addRightBarButtonItem:_turnButton];
    }
    if ([viewController isKindOfClass:[MakerViewController class]]) {
        UIButton *makerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [makerButton setImage:[UIImage imageNamed:@"icon_done.png"] forState:UIControlStateNormal];
        
        makerButton.frame = CGRectMake(0, 0, 25, 25);
        [makerButton addTarget:_maker action:@selector(makerTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addRightBarButtonItem:makerButton];
    }
    if ([viewController isKindOfClass:[RecognizeViewController class]]) {
        UIButton *makerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [makerButton setImage:[UIImage imageNamed:@"icon_browse.png"] forState:UIControlStateNormal];
        
        makerButton.frame = CGRectMake(0, 0, 25, 25);
        [makerButton addTarget:_recognize action:@selector(browseTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addRightBarButtonItem:makerButton];
    }
}
- (void)turnLightTouched:(UIButton*)sender{
    if (!sender) {
        [_scan turnLight:NO];
        _turnButton.selected = NO;
    }else{
        [_scan turnLight:!_scan.lighting];
        _turnButton.selected = _scan.lighting;
    }
}
-(void)clearHistory:(UIButton*)sender{
    
    JKAlert *alert = [JKAlert alertWithTitle:@"提示" andMessage:@"确定清除所有记录嘛?"];
    [alert addCommonButtonWithTitle:@"清除" handler:^(JKAlertItem *item) {
        [_history clean];
    }];
    [alert addCommonButtonWithTitle:@"我再想想" handler:^(JKAlertItem *item) {
        
    }];
    
    [alert show];
}

#pragma mark -- navgation

- (void)addLeftBarButtonItem:(UIButton *)button
{
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // Add a negative spacer on iOS >= 7.0
        negativeSpacer.width = -10;
    } else {
        // Just set the UIBarButtonItem as you would normally
        negativeSpacer.width = 0;
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    }
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, leftBarButtonItem, nil]];
}
- (void)addRightBarButtonItem:(UIButton *)button
{
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        negativeSpacer.width = -10;
        
    } else {
        negativeSpacer.width = 0;
    }
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightBarButtonItem, nil]];
}
@end
