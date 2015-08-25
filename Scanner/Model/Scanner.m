//
//  Scanner.m
//  Scanner
//
//  Created by Jakey on 15/8/20.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import "Scanner.h"
static NSString *TABLE = @"history";
@implementation Scanner
+(void)createTable{
    DBManager *manager = [DBManager managerForScanner];
    if (![manager isExistTable:TABLE]) {
       [manager createTable:TABLE fields:@[@"time",@"date",@"content"]];
    }
    [manager close];
}
+(BOOL)insert:(NSDictionary*)item{
    BOOL result;
    DBManager *manager = [DBManager managerForScanner];
    result = [manager insert:TABLE data:item replace:YES];
    [manager close];
    return result;
}
+(NSArray*)select:(BOOL)group{
    NSMutableArray *list = [NSMutableArray array];
    DBManager *manager = [DBManager managerForScanner];
    if(group){
        NSArray *groupArray = [manager select:@[@"distinct(date)"] from:TABLE where:nil groupBy:nil order:@"time desc" limit:nil];
        for (NSDictionary *group in groupArray) {
            NSArray *array = [manager select:nil from:TABLE where:[NSString stringWithFormat:@"date = '%@'",[group objectForKey:@"date"]] groupBy:nil order:@"time desc" limit:nil];
            [list addObject:array];
        }

    }else{
        list  = (NSMutableArray*)[manager select:nil from:TABLE where:nil groupBy:nil order:nil limit:nil];

    }
    [manager close];
    return list;
}
+(NSArray*)deleteWithTime:(NSString*)timeStamp{
    BOOL result;
    DBManager *manager = [DBManager managerForScanner];
    result = [manager delete:TABLE where:@{@"time":timeStamp} limit:nil];
    [manager close];

    if (result) {
        return [Scanner select:YES];
    }
    return nil;
}
+(BOOL)clean{
    BOOL result;
    DBManager *manager = [DBManager managerForScanner];
    result = [manager delete:TABLE where:nil limit:nil];
    [manager close];
    return result;
}
@end
