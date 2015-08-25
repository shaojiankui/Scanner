//
//  DBManagerQueue.m
//  iOS-DBManager
//
//  Created by Jakey on 15/7/18.
//  Copyright © 2015年 www.skyfox.org. All rights reserved.
//

#import "DBManagerQueue.h"
#import "DBManager.h"

static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;
@implementation DBManagerQueue

- (instancetype)init {
    return [self initWithDBPath:nil];
}
- (instancetype)initWithDBPath:(NSString*)dbPath{
    
    self = [super init];
    
    if (self != nil) {
        _dbManager = [[DBManager class] managerWithDBPath:dbPath];
        if (!_dbManager || !_dbManager.db) {
            NSLog(@"Could not create database queue for path %@", dbPath);
            return 0x00;
        }
        _dbName = [dbPath lastPathComponent];
        _dbPath = dbPath;
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"fmdb.%@", self] UTF8String], NULL);
        dispatch_queue_set_specific(_queue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
    }
    
    return self;
}
+(id)managerForScanner{
    return [[self alloc]initWithDBPath:[self documentsPath:@"Scanner.sqlite"]];
}

+ (instancetype)managerQueueWithDBPath:(NSString*)dbPath {
    DBManagerQueue *q = [[self alloc] initWithDBPath:dbPath];
    return q;
}
+ (instancetype)managerQueueWithDocumentName:(NSString*)dbName{
    DBManagerQueue *q = [[self alloc] initWithDBPath:[self documentsPath:dbName]];
    return q;
}
- (void)close {
    dispatch_sync(_queue, ^() {
        [self->_dbManager close];
        self->_dbManager = 0x00;
    });
}

- (DBManager*)manager {
    if (!_dbManager) {
        _dbManager = [DBManager managerWithDBPath:_dbPath];

        BOOL success = [_dbManager open];
        if (!success) {
            NSLog(@"DBManagerQueue could not reopen database for path %@", _dbPath);
            _dbManager  = 0x00;
            return 0x00;
        }
    }
    
    return _dbManager;
}

- (void)inDatabase:(void (^)(DBManager *manager))block {
    /* Get the currently executing queue (which should probably be nil, but in theory could be another DB queue
     * and then check it against self to make sure we're not about to deadlock. */
    DBManagerQueue *currentSyncQueue = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);
    assert(currentSyncQueue != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");

    dispatch_sync(_queue, ^() {
        
        DBManager *manager = [self manager];
        block(manager);
    });
}


- (void)beginTransaction:(BOOL)useDeferred withBlock:(void (^)(DBManager *manager, BOOL *rollback))block {
    dispatch_sync(_queue, ^() {
        
        BOOL shouldRollback = NO;
        
        if (useDeferred) {
            [[self manager] beginDeferredTransaction];
        }
        else {
            [[self manager] beginTransaction];
        }
        
        block([self manager], &shouldRollback);
        
        if (shouldRollback) {
            [[self manager] rollbackTransaction];
        }
        else {
            [[self manager] commitTransaction];
        }
    });
}

- (void)inDeferredTransaction:(void (^)(DBManager *manager, BOOL *rollback))block {
    [self beginTransaction:YES withBlock:block];
}

- (void)inTransaction:(void (^)(DBManager *manager, BOOL *rollback))block {
    [self beginTransaction:NO withBlock:block];
}
#pragma mark -- helper
+ (NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
+(NSString *)documentsPath:(NSString *)fileName{
    return [[self  documentsPath] stringByAppendingPathComponent:fileName];
}
@end
