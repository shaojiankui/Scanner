//
//  JKAlert.h
//  JKAlert
//
//  Created by Jakey on 15/1/20.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JKALERT_ITEM_TYPE) {
    JKALERT_ITEM_TYPE_OK,
    JKALERT_ITEM_TYPE_CANCEL,
    JKALERT_ITEM_TYPE_OTHER
};

typedef NS_ENUM(NSUInteger, JKALERT_STYLE) {
    JKALERT_STYLE_ALERT,
    JKALERT_STYLE_ACTION_SHEET
};
@class JKAlertItem;
typedef void(^JKAlertHandler)(JKAlertItem *item);

@interface UIAlertController (Rotation)
//fixed UIAlertController Rotation crash bug
@end


@interface JKAlert : NSObject
- (instancetype)init __attribute__((unavailable("Forbidden use init!")));

@property(nonatomic,readonly) NSArray *actions;
/**
 *  @brief  instance init method
 *
 *  @param title   alert tiltle
 *  @param message alert message
 *  @param style   JKAlert Style
 *
 *  @return JKAlert
 */
-(id)initWithTitle:(NSString *)title andMessage:(NSString *)message style:(JKALERT_STYLE)style;
/**
 *  @brief  class init method
 *
 *  @param title   alert tiltle
 *  @param message alert message
 *
 *  @return JKAlert with JKALERT_STYLE_ALERT
 */
+(id)alertWithTitle:(NSString *)title andMessage:(NSString *)message;
/**
 *  @brief  class init method
 *
 *  @param title   actionSheet tiltle
 *  @param message actionSheet message
 *
 *  @return JKAlert with JKALERT_STYLE_ACTION_SHEET
 */
+(id)actionSheetWithTitle:(NSString *)title andMessage:(NSString *)message;
/**
 *  @brief  add a common button without handler block
 *
 *  @param title button title
 *
 *  @return button index
 */
-(NSInteger)addButtonWithTitle:(NSString *)title;
/**
 *  @brief  add a cancle button
 *
 *  @param title   button title
 *  @param handler handler block
 */
-(void)addCancleButtonWithTitle:(NSString *)title handler:(JKAlertHandler)handler;
/**
 *  @brief  add a common button
 *
 *  @param title   button title
 *  @param handler handler block
 */
-(void)addCommonButtonWithTitle:(NSString *)title handler:(JKAlertHandler)handler;
/**
 *  @brief  find button title with buttonIndex
 *
 *  @param buttonIndex buttonIndex
 *
 *  @return button title
 */
-(NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
/**
 *  @brief  show a alert with JKALERT_STYLE_ALERT
 *
 *  @param title   alert tiltle
 *  @param message alert message
 */
+(id)showMessage:(NSString *)title message:(NSString *)message;
/**
 *  @brief  show a alert with JKALERT_STYLE_ALERT
 *
 *  @param message alert message
 */
+(id)showMessage:(NSString *)message;
/**
 *  @brief  show method
 */
-(void)show;
@end


@interface JKAlertItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic) JKALERT_ITEM_TYPE type;
@property (nonatomic) NSUInteger tag;
@property (nonatomic, copy) JKAlertHandler action;
@end
