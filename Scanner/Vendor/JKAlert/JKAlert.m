//
//  JKAlert.m
//  JKAlert
//
//  Created by Jakey on 15/1/20.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//
static const void *AlertObject = &AlertObject;
#import <objc/runtime.h>
#import "JKAlert.h"

@implementation JKAlertItem
@end

//private
@interface JKAlert()<UIActionSheetDelegate>{
    NSMutableArray *_items;
    NSString *_title;
    NSString *_message;
    StyleType _styleType;
}
@end

@implementation JKAlert
- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message style:(StyleType)style{
    self = [super init];
    if (self != nil)
    {
        _items = [NSMutableArray array];
        _title  = title;
        _message = message;
        _styleType = style;
    }
    return self;
}
- (NSInteger)addButtonWithTitle:(NSString *)title{
    NSAssert(title != nil, @"all title must be non-nil");
    
    JKAlertItem *item = [[JKAlertItem alloc] init];
    item.title = title;
    item.action = ^(JKAlertItem *item) {
        NSLog(@"no action");
    };
    item.type = ITEM_OK;
    [_items addObject:item];
    return [_items indexOfObject:title];
}
- (void)addButton:(ItemType)type withTitle:(NSString *)title handler:(JKAlertHandler)handler{
    NSAssert(title != nil, @"all title must be non-nil");
    
    JKAlertItem *item = [[JKAlertItem alloc] init];
    item.title = title;
    item.action = handler;
    item.type = type;
    [_items addObject:item];
    item.tag = [_items indexOfObject:item];
}
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex{
    JKAlertItem *item = _items[buttonIndex];
    return item.title;
}
- (NSArray *)actions
{
    return [_items copy];
}

#pragma --mark show
-(void)show
{
    
    if (NSClassFromString(@"UIAlertController") != nil)
    {
        [self show8];
    }
    else
    {
        [self show7];
    }
}

-(void)show8
{
    UIAlertControllerStyle controllerStyle;
    if (_styleType == STYLE_ALERT) {
        controllerStyle = UIAlertControllerStyleAlert;
    }else{
        controllerStyle = UIAlertControllerStyleActionSheet;
        
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:_title
                                                                             message:_message
                                                                      preferredStyle:controllerStyle];
    
    
    for (JKAlertItem *item in _items)
    {
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        
        if (item.type == ITEM_CANCEL) {
            style = UIAlertActionStyleCancel;
        }
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:item.title style:style handler:^(UIAlertAction *action) {
            if (item.action) {
                item.action(item);
            }
        }];
        
        [alertController addAction:alertAction];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        // UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        [self.topViewController presentViewController:alertController animated:YES completion:nil];
    });
    
}


-(void)show7
{
    
    if (_styleType == STYLE_ALERT) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_title
                                                            message:_message
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil];
        
        objc_setAssociatedObject(alertView,  &AlertObject,self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //http://coding.tabasoft.it/ios/an-ios7-and-ios8-simple-alert/
        for (JKAlertItem *item in _items)
        {
            if (item.type == ITEM_CANCEL)
            {
                [alertView setCancelButtonIndex:[alertView addButtonWithTitle:item.title]];
            }
            else
            {
                [alertView addButtonWithTitle:item.title];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [alertView show];
        });
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:_title
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil, nil];
        
        objc_setAssociatedObject(actionSheet,  &AlertObject,self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        for (JKAlertItem *item in _items)
        {
            if (item.type == ITEM_CANCEL)
            {
                [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:item.title]];
            }
            else
            {
                [actionSheet addButtonWithTitle:item.title];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [actionSheet showInView:self.topViewController.view];
        });
        
    }
    
    
}
#pragma --mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    JKAlertItem *item = _items[buttonIndex];
    if(item.action){
        item.action(item);
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    JKAlertItem *item = _items[buttonIndex];
    if(item.action){
        item.action(item);
    }
};

#pragma --mark actionSheet delegate

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


+ (void)showMessage:(NSString *)title message:(NSString *)message
{
    if (message == nil)
    {
        return;
    }
    JKAlert *alert = [[JKAlert alloc]initWithTitle:title andMessage:message style:STYLE_ALERT];
    [alert addButtonWithTitle:@"确定"];
    [alert show];
    
}
+ (void)showMessage:(NSString *)message{
    [[self class]showMessage:@"提示" message:message];
    
}
@end

//fixed UIAlertController Rotation crash bug
@implementation UIAlertController (Rotation)
#pragma mark self rotate
-(BOOL)shouldAutorotate {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if ( orientation == UIDeviceOrientationPortrait
        | orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        return YES;
    }
    
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIDevice* device = [UIDevice currentDevice];
    if (device.orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown;
    }
    return UIInterfaceOrientationPortrait;
}

@end