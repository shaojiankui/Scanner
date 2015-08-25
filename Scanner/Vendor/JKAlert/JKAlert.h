//
//  JKAlert.h
//  JKAlert
//
//  Created by Jakey on 15/1/20.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum ItemType
{
    ITEM_OK,
    ITEM_CANCEL,
    ITEM_OTHER
    
}ItemType;

typedef enum StyleType
{
    STYLE_ALERT,
    STYLE_ACTION_SHEET
}StyleType;


@class JKAlertItem;
typedef void(^JKAlertHandler)(JKAlertItem *item);

@interface UIAlertController (Rotation)
//fixed UIAlertController Rotation crash bug
@end


@interface JKAlert : NSObject
@property(nonatomic,readonly) NSArray *actions;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (NSInteger)addButtonWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message style:(StyleType)style;
- (void)addButton:(ItemType)type withTitle:(NSString *)title handler:(JKAlertHandler)handler;
+ (void)showMessage:(NSString *)title message:(NSString *)message;
+ (void)showMessage:(NSString *)message;
-(void)show;
@end


@interface JKAlertItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic) ItemType type;
@property (nonatomic) NSUInteger tag;
@property (nonatomic, copy) JKAlertHandler action;
@end