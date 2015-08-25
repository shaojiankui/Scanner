//
//  DBManagerQueue.h
//  iOS-DBManager
//
//  Created by Jakey on 15/7/18.
//  Copyright © 2015年 www.skyfox.org. All rights reserved.
//

/** 多线程增加与查询可以使用,"DBManagerQueue".
 
 使用一个DBManager的单例，用多线程来处理是很愚蠢的。通常，不同的线程处理一个不同的 DBManager 对象是安全的。 请不要创建数据库单例，并在不同的线程中访问，如果实在不行，也不要让不同的线程同时访问这一个数据库对象。 如果你坚持这么做，那经常就会出现一些莫名其妙的崩溃，异常，或者从天而降的陨石砸坏你的苹果电脑，别这么干哦。
  所以，不要创建一个 DBManager 单例对象，然后在不同的线程中访问。
 你可以使用 DBManagerQueue，线程安全就靠它了：
 
 首先，创建你的queue
 
 DBManagerQueue *queue = [DBManagerQueue managerQueueWithDBPath:aPath];
 
 Then use it like so:
 
 [queue inDatabase:^(DBManager *manager) {
    [manager executeUpdate:@"INSERT INTO myTable ....."];
    [manager executeUpdate:@"INSERT INTO myTable ....."];
    [manager executeUpdate:@"INSERT INTO myTable ....."];

 }];
 
 对于多条查询语句事务的提交，可以这样做：
 
 [queue inTransaction:^(DBManager *manager, BOOL *rollback) {
    [manager executeUpdate:@"INSERT INTO myTable ....."];
    [manager executeUpdate:@"INSERT INTO myTable ....."];
    [manager executeUpdate:@"INSERT INTO myTable ....."];
 
     if (whoopsSomethingWrongHappened) {
        *rollback = YES;//如果需要回滚
        return;
     }
 }];
 
 DBManagerQueue 运行在一个串行队列当中。所以，当你在不同的线程中调用了 DBManagerQueue 方法，他们将会被序列执行。这种处理方式，不同线程间不会互相干扰，每个线程都很happy^_^。
 
 注意：调用 DBManagerQueue 方法是一个 block 。即使你在 block 中使用了 block，它也不会在其它线程中运行。
 
 */

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@class DBManager;
@interface DBManagerQueue : NSObject {
    dispatch_queue_t    _queue;
    DBManager          *_dbManager;
}
@property (nonatomic, strong) NSString *dbPath;
@property (nonatomic, strong) NSString *dbName;
+(id)managerForScanner;
/**
 *  初始化DBManagerQueue
 *
 *  @param dbPath 数据库全路径
 *
 *  @return DBManagerQueue
 */
- (instancetype)initWithDBPath:(NSString*)dbPath;
/**
 *  类方法 初始化
 *
 *  @param dbPath 数据库全路径
 *
 *  @return DBManagerQueue
 */
+ (instancetype)managerQueueWithDBPath:(NSString*)dbPath;
/**
 *  类方法初始化
 *
 *  @param dbName 沙盒中数据库名称
 *
 *  @return DBManagerQueue
 */
+ (instancetype)managerQueueWithDocumentName:(NSString*)dbName;

/**
 *  关闭数据库
 */
- (void)close;

/**
 *  执行语句
 *
 *  @param block block description
 */
- (void)inDatabase:(void (^)(DBManager *manager))block;

/**
 *  事务
 *
 *  @param block block description
 */
- (void)inTransaction:(void (^)(DBManager *manager, BOOL *rollback))block;

/**
 *  延迟事务
 *
 *  @param block block description
 */
- (void)inDeferredTransaction:(void (^)(DBManager *manager, BOOL *rollback))block;


@end

