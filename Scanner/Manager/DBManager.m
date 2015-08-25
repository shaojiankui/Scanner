//
//  iOS-DBManager.m
//  iOS-DBManager
//
//  Created by Jakey on 15/7/14.
//  Copyright © 2015年 www.skyfox.org. All rights reserved.
//  https://github.com/shaojiankui/SQLiteManager

#import "DBManager.h"

@implementation DBManager
/**
 *  初始化方法
 *
 *  @param dbPath 数据库全路径
 *
 *  @return DBManager
 */
-(id)initWithDBPath:(NSString*)dbPath
{
    self = [super init];
    if (self!=nil)
    {
        self.dbPath = dbPath;
        self.dbName = [dbPath lastPathComponent];
        [self open];
    }
    return self;
}
/**
 *  类方法  根据文件路径初始化
 *
 *  @param dbName 全路径
 *
 *  @return DBManager
 */
+(id)managerWithDBPath:(NSString*)dbPath{
    return  [[self alloc]initWithDBPath:dbPath];
}
/**
 *  类方法  根据沙盒文件名初始化
 *
 *  @param dbName 沙盒根目录数据库名称
 *
 *  @return DBManager
 */
+(id)managerWithDocumentName:(NSString*)dbName{
    return [[self alloc]initWithDBPath:[self documentsPath:dbName]];
}
+(id)managerForScanner{
    return [[self alloc]initWithDBPath:[self documentsPath:@"Scanner.sqlite"]];
}
-(id)init
{
    NSAssert(0,@"Never Use this.Please Call Use initWithDB:(NSString*)");
    return nil;
}
/**
 *  拷贝bundle中数据库到沙盒
 *
 *  @param dbName 数据库名称
 *
 *  @return 数据库路径
 */
+(NSString*)copyBundleDBIntoDocuments:(NSString*)dbName{
    NSString *destinationPath = [self documentsPath:dbName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:(destinationPath)]){
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
        NSError* error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        NSLog(@"%@", [error localizedDescription]);
    }
    return destinationPath;
}
/**
 *  打开数据库
 *
 *  @return 打开结果
 */
- (BOOL)open
{
    if (_db)
    {
        NSLog(@"The database is already opened.");
        return YES;
    }
    //多线程模式
    sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
    //串行
    //sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    //单线程
    // sqlite3_config(SQLITE_CONFIG_SINGLETHREAD);
    NSString *dbDir = [self.dbPath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if (sqlite3_open([self.dbPath UTF8String], &_db) != SQLITE_OK)
    {
        [self close];
        NSLog(@"Open Database faild。");
        return NO;
    }
    char *errorMsg = nil;
    if (sqlite3_exec(_db, "PRAGMA journal_mode=WAL;", NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"Failed to set WAL mode: %s",errorMsg);
    }
    sqlite3_wal_checkpoint(_db, NULL);
    //NSLog(@"Open Database success。");
    return YES;
    
}
/**
 *  关闭数据库
 *
 *  @return 关闭结果
 */
- (BOOL)close
{
    if (_db != NULL)
    {
        if(sqlite3_close(_db) == SQLITE_OK)
        {
            //NSLog(@"Close Database success。");
            return YES;;
        }
        else
        {
            NSLog(@"Close Database faild: %s",sqlite3_errmsg(_db));
            return NO;
        }
    }else{
        NSLog(@"Cannot close a database that is not open.");
    }
    return YES;
}
#pragma mark - execute methods
/**
 *  无结果集执行更新
 *
 *  @param sql 完整sql语句
 *
 *  @return 操作结果
 */
-(BOOL)executeUpdate:(NSString*)sql{
    char *err;
    if (sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        //        sqlite3_close(_db);
        NSLog(@"Database Opration faild!:%s",err);
        return NO;
    }else{
        // NSLog(@"Database Opration success!:%@",sql);
        return YES;
    }
}
/**
 *  查询结果集
 *
 *  @param query sql语句
 *  @param type  row对象类型枚举,关联对象/关联数组
 *
 *  @return 结果集
 */
- (NSArray *)executeQuery:(NSString *)query rowType:(RowType)type;
{
    __block NSMutableArray *result = [NSMutableArray array];
    [self executeQuery:query rowType:type withBlock:^(id row, NSError *error, BOOL finished) {
        if (!error)
        {
            if (!finished) {
                [result addObject:row];
            } else {
               // NSLog(@"Query finished!");
            }
        } else {
            NSLog(@"Query error!");
        }
    }];
    
    return result;
}
/**
 *  查询遍历器
 *
 *  @param query          sql语句
 *  @param type           ow对象类型,关联对象/关联数组
 *  @param fetchItemBlock 遍历block,id row为每一条记录对应的对象或者数组
 */
-(void)executeQuery:(NSString *)query rowType:(RowType)type withBlock:(FetchItemBlock)fetchItemBlock{
    
    NSString *fixedQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    sqlite3_stmt *statement;
    const char *tail;
    __unused int resultCode = sqlite3_prepare_v2(_db, [fixedQuery UTF8String], -1, &statement, &tail);
    if (statement) {
        
        int num_cols, i, column_type;
        id obj;
        NSString *key;
        NSMutableDictionary *row;
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            row = [NSMutableDictionary dictionary];
            num_cols = sqlite3_data_count(statement);
            for (i = 0; i < num_cols; i++) {
                obj = nil;
                column_type = sqlite3_column_type(statement, i);
                switch (column_type) {
                    case SQLITE_INTEGER:
                        obj = [NSNumber numberWithLongLong:sqlite3_column_int64(statement, i)];
                        break;
                    case SQLITE_FLOAT:
                        obj = [NSNumber numberWithDouble:sqlite3_column_double(statement, i)];
                        break;
                    case SQLITE_TEXT:
                        obj = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
                        break;
                    case SQLITE_BLOB:
                        obj = [NSData dataWithBytes:sqlite3_column_blob(statement, i) length:sqlite3_column_bytes(statement, i)];
                        break;
                    case SQLITE_NULL:
                        obj = [NSNull null];
                        break;
                    default:{
                        NSLog(@"[SQLITE] UNKNOWN DATATYPE");
                    }
                        break;
                }
                
                key = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
                [row setObject:obj?:@"" forKey:key];
            }
            if (type == RowTypeArray) {
                if (fetchItemBlock) {
                    fetchItemBlock([row allValues], nil, NO);
                }
            }else{
                if (fetchItemBlock) {
                    fetchItemBlock(row, nil, NO);
                }
            }
            
        }
        
        sqlite3_finalize(statement);
        if(fetchItemBlock){
            fetchItemBlock(nil, nil, YES);
        }
        
    }else
    {
        NSLog(@"statement is NULL,sql:%@",fixedQuery);
        fetchItemBlock(nil, [NSError errorWithDomain:@"statement is NULL" code:21323 userInfo:@{@"statement为空": @"中文",@"stmt is NULL":@"English"}], YES);
        
    }
    
}
/**
 *  执行sql文件
 *
 *  @param path 完整文件路径
 */
- (void)executeFromFile:(NSString *)path
{
    
    NSAssert1(path != nil, @"Could not locate %@", path);
    
    FILE *file = fopen([path UTF8String], "rt");
    NSAssert1(file != NULL, @"Could not open %@", path);
    
    char line[1024];
    char *err;
    
    while (fgets(line, 1023, file))
    {
        if (strlen(line) > 4)
            sqlite3_exec(_db, line, NULL, NULL, &err);
    }
    
    fclose(file);
    
}
#pragma mark -  Table Opration
/**
 *  创建表
 *
 *  @param table  表名
 *  @param fields 字段名数组
 *
 *  @return 创建结果
 */
- (BOOL)createTable:(NSString *)table fields:(NSArray *)fields
{
    if([fields count] < 1) {
        NSLog(@"unable create table,because no fields!");
        return NO;
    }
    
    NSString *cmd = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT PRIMARY KEY", table, [fields objectAtIndex:0]];
    
    for(NSInteger i = 1 ; i < [fields count] ; i++) {
        cmd = [NSString stringWithFormat:@"%@ , '%@' TEXT", cmd, [fields objectAtIndex:i]];
    }
    
    cmd = [NSString stringWithFormat:@"%@)", cmd];
    
    return [self executeUpdate:cmd];
    
}


/**
 *  删除表
 *
 *  @param table 表名
 *
 *  @return 删除结果
 */
- (BOOL)dropTable:(NSString *)table{
    NSString *sqlString = [NSString stringWithFormat:@"DROP TABLE '%@'", table];
    if (![self executeUpdate:sqlString])
    {
        NSLog(@"drop table failed!");
        return NO;
    }else{
        NSLog(@"drop table success!");
        return YES;
    }
    
}
#pragma mark -  CRUD
/**
 *  插入表记录
 *
 *  @param table   表名
 *  @param data    数据字典
 *  @param replace 如果存在是否替换
 *
 *  @return 插入结果
 */
-(BOOL)insert:(NSString *)table data:(NSDictionary*)data replace:(BOOL)replace{
    NSArray *fields = [data allKeys];
    NSArray *values = [data allValues];
    NSString *cmd = replace ? @"REPLACE INTO" : @"INSERT INTO";
    
    NSString *_fields = [NSString stringWithFormat: @"('%@'", [fields objectAtIndex:0]];
    NSString *_values = [NSString stringWithFormat:@"('%@'", [values objectAtIndex:0]];
    
    for(NSInteger i = 1 ; i < [fields count] && i < [values count] ; i++) {
        _fields = [NSString stringWithFormat:@"%@, '%@'", _fields, [fields objectAtIndex:i]];
        _values = [NSString stringWithFormat:@"%@, '%@'", _values,[values objectAtIndex:i]];
    }
    
    _fields = [NSString stringWithFormat:@"%@)", _fields];
    _values = [NSString stringWithFormat:@"%@)", _values];
    
    NSString *sqlString = [NSString stringWithFormat:@"%@ %@ %@ VALUES %@", cmd, table,_fields, _values];
    // NSLog(@"insert %@",sqlString);
    if ([self executeUpdate:sqlString]) {
        //NSLog(@"insert table success!");
        return YES;
    }else{
        NSLog(@"insert table failed!");
        return NO;
    }
    
}
/**
 *  插入表记录
 *
 *  @param table   表名
 *  @param fields  列名
 *  @param values  列值
 *  @param replace 如果存在是否替换
 *
 *  @return 插入结果
 */
-(BOOL)insert:(NSString *)table fields:(NSArray *)fields values:(NSArray*)values replace:(BOOL)replace{
    NSString *cmd = replace ? @"REPLACE INTO" : @"INSERT INTO";
    
    NSString *_fields = [NSString stringWithFormat: @"('%@'", [fields objectAtIndex:0]];
    NSString *_values = [NSString stringWithFormat:@"('%@'", [values objectAtIndex:0]];
    
    for(NSInteger i = 1 ; i < [fields count] && i < [values count] ; i++) {
        _fields = [NSString stringWithFormat:@"%@, '%@'", _fields, [fields objectAtIndex:i]];
        _values = [NSString stringWithFormat:@"%@, '%@'", _values,[values objectAtIndex:i]];
    }
    
    _fields = [NSString stringWithFormat:@"%@)", _fields];
    _values = [NSString stringWithFormat:@"%@)", _values];
    
    NSString *sqlString = [NSString stringWithFormat:@"%@ %@ %@ VALUES %@", cmd, table,_fields, _values];
    // NSLog(@"insert %@",sqlString);
    if ([self executeUpdate:sqlString]) {
        //NSLog(@"insert table success!");
        return YES;
    }else{
        NSLog(@"insert table failed!");
        return NO;
    }
    
}
/**
 *  更新表记录
 *
 *  @param table     表名
 *  @param data      数据字典
 *  @param condition     where条件,字符串,或者是数据字典
 *
 *  @return 更新结果
 */
-(BOOL)update:(NSString*)table data:(NSDictionary*)data where:(id)condition{
    NSString *sql = [self implode_field_value:data split:nil];
    NSString *where = @"";
    if (!condition) {
        where = @"1";
    } else if ([condition  isKindOfClass:[NSDictionary class]])
    {
        where = [self implode_field_value:condition split:@" AND "];
    } else {
        where = condition;
    }
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",table,sql,where];
    NSLog(@"update %@",sqlString);
    return [self executeUpdate:sqlString];
}

/**
 *  删除表记录
 *
 *  @param table     表名
 *  @param condition where条件,字符串,或者是数据字典
 *  @param limit     删除记录条数
 *
 *  @return 删除结果
 */
-(BOOL)delete:(NSString*)table where:(id)condition limit:(NSString*)limit{
    NSString *where;
    NSString *limitString =@"";
    if (limit) {
        limitString = [NSString stringWithFormat:@"LIMIT %@",limit];
    }
    if (!condition) {
        where = @"1";
    }else if ([condition  isKindOfClass:[NSDictionary class]]) {
        where = [self implode_field_value:condition split:@" AND "];
    } else {
        where = condition;
    }
    NSString *sqlString =[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ %@",table,where,limitString];
    NSLog(@"delete %@",sqlString);
    return [self executeUpdate:sqlString];
}


/**
 *  查询表记录
 *
 *  @param table     表名
 *  @param condition where条件,字符串,或者是数据字典
 *  @param limit     查询记录条数
 *
 *  @return 查询结果集
 */
- (NSArray *)select:(NSString*)table where:(id)condition limit:(NSString*)limit{
    return [self select:nil from:table where:condition groupBy:nil order:nil limit:limit];
}
/**
 *  查询表记录
 *
 *  @param fields    待查询字段名
 *  @param table     表名
 *  @param condition where条件,字符串,或者是数据字典
 *  @param groupBy   分组字符串或者数组
 *  @param order     排序字符串,比如 @"userid desc"
 *  @param limit     查询记录条数 或者范围 @"2,10"
 *
 *  @return 查询结果集
 */
-(NSArray *)select:(NSArray *)fields from:(NSString *)table where:(id)condition groupBy:(id)groups order:(NSString *)order limit:(NSString *)limit{
    NSString *fieldString;
    NSString *where;
    NSString *limitString = @"";
    NSString *orderString = @"";
    NSString *groupString;
    
    //fields
    if (!fields) {
        fieldString = @"*";
    }else if([fields count]==1){
        fieldString = [fields lastObject];
    }else{
        fieldString  = [fields componentsJoinedByString:@","];
    }
    //limit
    if (limit) {
        limitString = [NSString stringWithFormat:@"LIMIT %@",limit];
    }
    //where
    if (!condition) {
        where = @"1";
    }else if ([condition  isKindOfClass:[NSDictionary class]]) {
        where = [self implode_field_value:condition split:@" AND "];
    } else {
        where = condition;
    }
    //groupBy
    if (!groups) {
        groupString = @"";
    }else if ([groups  isKindOfClass:[NSArray class]]) {
        groupString = [groups componentsJoinedByString:@","];
        if([fields count]==1){
            groupString = [groups lastObject];
        }
    }else {
        groupString = groups;
    }
    if (groupString && ![groupString isEqualToString:@""]) {
        groupString = [NSString stringWithFormat:@"GROUP BY %@",groupString];
    }
    
    //order
    if (order) {
        orderString = [NSString stringWithFormat:@"ORDER BY %@",order];
    }else{
        orderString  =@"";
    }
    NSString *sqlString =[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ %@ %@ %@",fieldString,table,where,groupString,orderString,limitString];
   NSLog(@"select: %@",sqlString);
    return [self executeQuery:sqlString rowType:RowTypeObject];
}

/**
 *  统计表总行数
 *
 *  @param table     表名
 *  @param condition 统计条件
 *
 *  @return 行数
 */
-(NSUInteger)count:(NSString*)table where:(id)condition{
    NSString *where;
    if (!condition) {
        where = @"1";
    }else if ([[condition class] isKindOfClass:[NSDictionary class]]) {
        where = [self implode_field_value:condition split:@" AND "];
    } else {
        where = condition;
    }
    NSArray *array = [self executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) AS num FROM %@ WHERE %@",table,where] rowType:RowTypeObject];
    if(array && [array count]>0){
        NSDictionary *dic = [array objectAtIndex:0];
        return [[dic objectForKey:@"num"] unsignedIntegerValue];
    }else{
        return 0;
    }
    
}
#pragma mark -  Info
// 是否存在表
- (BOOL)isExistTable:(NSString *)table
{
    NSArray  *array = [self executeQuery:[NSString stringWithFormat:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = '%@'",table] rowType:RowTypeObject];
    NSDictionary *item = [array lastObject];
    if(item && [[item objectForKey:@"count"] integerValue]>0)
    {
        return YES;
    }else{
        return NO;
    }
}
//最近执行的INSERT、UPDATE和DELETE语句所影响的数据行数
- (NSUInteger)affectedRows
{
    return (NSUInteger)sqlite3_changes(_db);
}
//自从该连接被打开时起，INSERT、UPDATE和DELETE语句总共影响的行数
- (NSUInteger)totalAffectedRows
{
    return (NSUInteger)sqlite3_total_changes(_db);
}
//最后一次插入记录row id
- (NSNumber *)lastInsertID {
    
    sqlite3_int64 rowid = 0;
    
    if (_db) {
        rowid = sqlite3_last_insert_rowid(_db);
    }else{
        NSLog(@"Cannot return the last row ID with a database that is not open.");
    }
    if ( rowid == 0LL )
    {
        return nil;
    }
    return [NSNumber numberWithLongLong:rowid];
}
//最后一条记录id
- (NSInteger)lastRecodeId:(NSString *)table
{
    NSString *cmd = [NSString stringWithFormat:@"SELECT ID FROM %@ ORDER BY ID DESC LIMIT 1", table];
    
    sqlite3_stmt *stmt;
    
    if(sqlite3_prepare_v2(_db, [cmd UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        if(sqlite3_step(stmt)){
            char *id = (char*) sqlite3_column_text(stmt, 0);
            
            if(id == NULL) return 0;
            
            int ret =  (int)strtol(id, NULL, 10);
            return ret;
        }
        
        return 0;
    }
    
    NSLog(@"Error reading last ID from database.");
    
    return -1;
}
//数据库所有表名
- (NSArray *)tables
{
    NSArray *descs = [self executeQuery:@"SELECT tbl_name FROM sqlite_master WHERE type = 'table'" rowType:RowTypeObject];
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *row in descs) {
        NSString *tblName = [row objectForKey:@"tbl_name"];
        [result addObject:tblName];
    }
    return result;
}
//表列数
- (NSUInteger)columnsInTable:(NSString *)table
{
    char *sql = sqlite3_mprintf("PRAGMA table_info(%q)", [table UTF8String]);
    NSString *query = [NSString stringWithUTF8String:sql];
    sqlite3_free(sql);
    return [[self executeQuery:query rowType:RowTypeObject] count];
}
//所有表头
-(NSArray *)columnTitlesInTable:(NSString *)table
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ROWID ASC LIMIT 1",table];
    NSDictionary *result = [[self executeQuery:query rowType:RowTypeObject] lastObject];
    return [result allKeys];
}
//错误信息
- (NSString *)errorMessage {
    return [NSString stringWithUTF8String:sqlite3_errmsg(_db)];
}
//错误代码
- (NSInteger)errorCode{
    return sqlite3_errcode(_db);
}
#pragma mark -  Transaction
/**
 *  开始事物
 *
 *  @return 开始结果
 */
- (BOOL)beginTransaction {
    //    NSAssert(_db != NULL, @"Don't have a database connection");
    //    char *errorMsg = NULL;
    //    if (sqlite3_exec(_db, "BEGIN", NULL, NULL, &errorMsg) != SQLITE_OK)
    //        NSAssert1(NO, @"Error starting transaction: %s", errorMsg);
    return [self executeUpdate:@"BEGIN EXCLUSIVE TRANSACTION;"];
}
/**
 *  开始延迟事物
 *
 *  @return 开始结果
 */
- (BOOL)beginDeferredTransaction {
    return [self executeUpdate:@"BEGIN DEFERRED TRANSACTION;"];
}
/**
 *  提交事务
 *
 *  @return 结果
 */
- (BOOL)commitTransaction {
    return [self executeUpdate:@"COMMIT TRANSACTION;"];
}
/**
 *  回滚事务
 *
 *  @return 回滚结果
 */
- (BOOL)rollbackTransaction {
    return [self executeUpdate:@"ROLLBACK TRANSACTION;"];
}

#pragma mark -  SQLite information
+ (int)versionNumber {
    return SQLITE_VERSION_NUMBER;
}
+ (int)libraryVersionNumber {
    return sqlite3_libversion_number();
}
+ (NSString*)sqliteLibVersion {
    return [NSString stringWithFormat:@"%s", sqlite3_libversion()];
}

+ (BOOL)isSQLiteThreadSafe {
    // make sure to read the sqlite headers on this guy!
    return sqlite3_threadsafe() != 0;
}
#pragma mark -  Helper
-(NSString*)implode_field_value:(NSDictionary*)data split:(NSString*)split{
    if(!split){
        split = @",";
    }
    NSMutableString *sql = [NSMutableString string];
    NSString *comma = @"";
    for (NSString *key in data) {
        [sql appendString:[NSString stringWithFormat:@"%@%@ = %@",comma,key,[data valueForKey:key]]];
        comma = split;
    }
    return sql;
}
-(void)writeLog:(NSString*)log{
    NSLog(@"%@:%@",[NSDate date],log);
}
+ (NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
+(NSString *)documentsPath:(NSString *)fileName{
    return [[self  documentsPath] stringByAppendingPathComponent:fileName];
}
@end
