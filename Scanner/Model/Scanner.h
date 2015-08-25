//
//  Scanner.h
//  Scanner
//
//  Created by Jakey on 15/8/20.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
@interface Scanner : NSObject
+(void)createTable;
+(BOOL)insert:(NSDictionary*)item;
+(NSArray*)select:(BOOL)group;
+(BOOL)clean;
+(NSArray*)deleteWithTime:(NSString*)timeStamp;
@end
