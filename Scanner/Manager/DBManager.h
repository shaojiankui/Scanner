//
//  iOS-DBManager.h
//  iOS-DBManager
//
//  Created by Jakey on 15/7/14.
//  Copyright © 2015年 www.skyfox.org. All rights reserved.
//  https://github.com/shaojiankui/SQLiteManager

#import <Foundation/Foundation.h>
#import "sqlite3.h"

typedef void (^FetchItemBlock)(id row, NSError *error, BOOL finished);

typedef NS_ENUM(NSUInteger, RowType) {
    RowTypeObject,  //关联对象
    RowTypeArray,    //关联数组
};


@interface DBManager : NSObject
@property(nonatomic) sqlite3 *db;
@property(strong,nonatomic)NSString *dbPath;
@property(strong,nonatomic)NSString *dbName;

/**
 *  初始化方法
 *
 *  @param dbPath 数据库全路径
 *
 *  @return DBManager
 */
-(id)initWithDBPath:(NSString*)dbPath;
/**
 *  类方法  根据沙盒文件名初始化
 *
 *  @param dbName 沙盒根目录数据库名称
 *
 *  @return DBManager
 */
+(id)managerWithDocumentName:(NSString*)dbName;
/**
 *  类方法  根据文件路径初始化
 *
 *  @param dbName 全路径
 *
 *  @return DBManager
 */
+(id)managerWithDBPath:(NSString*)dbPath;
/**
 *  拷贝bundle中数据库到沙盒
 *
 *  @param dbName 数据库名称
 *
 *  @return 数据库路径
 */
+(id)managerForScanner;

+(NSString*)copyBundleDBIntoDocuments:(NSString*)dbName;
#pragma mark - Close and Open

/**
 *  打开数据库
 *
 *  @return 打开结果
 */
- (BOOL)open;
/**
 *  关闭数据库
 *
 *  @return 关闭结果
 */
- (BOOL)close;

#pragma mark - execute Opration
/**
 *  无结果集执行更新
 *
 *  @param sql 完整sql语句
 *
 *  @return 操作结果
 */
-(BOOL)executeUpdate:(NSString*)sql;
/**
 *  执行sql文件
 *
 *  @param path 完整文件路径
 */
- (void)executeFromFile:(NSString *)path;
/**
 *  查询结果集
 *
 *  @param query sql语句
 *  @param type  row对象类型枚举,关联对象/关联数组
 *
 *  @return 结果集
 */
- (NSArray *)executeQuery:(NSString *)query rowType:(RowType)type;
/**
 *  查询遍历器
 *
 *  @param query          sql语句
 *  @param type           ow对象类型,关联对象/关联数组
 *  @param fetchItemBlock 遍历block,id row为每一条记录对应的对象或者数组
 */
-(void)executeQuery:(NSString *)query rowType:(RowType)type withBlock:(FetchItemBlock)fetchItemBlock;

#pragma mark - Table Opration
/**
 *  创建表
 *
 *  @param table  表名
 *  @param fields 字段名数组
 *
 *  @return 创建结果
 */
- (BOOL)createTable:(NSString *)table fields:(NSArray *)fields;
/**
 *  删除表
 *
 *  @param table 表名
 *
 *  @return 删除结果
 */
- (BOOL)dropTable:(NSString *)table;

#pragma mark - CRUD
/**
 *  插入表记录
 *
 *  @param table   表名
 *  @param data    数据字典
 *  @param replace 如果存在是否替换
 *
 *  @return 插入结果
 */
-(BOOL)insert:(NSString*)table data:(NSDictionary*)data replace:(BOOL)replace;
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
-(BOOL)insert:(NSString *)table fields:(NSArray *)fields values:(NSArray*)values replace:(BOOL)replace;
/**
 *  更新表记录
 *
 *  @param table     表名
 *  @param data      数据字典
 *  @param condition     where条件,字符串,或者是数据字典
 *
 *  @return 更新结果
 */
-(BOOL)update:(NSString*)table data:(NSDictionary*)data where:(id)condition;
/**
 *  删除表记录
 *
 *  @param table     表名
 *  @param condition where条件,字符串,或者是数据字典
 *  @param limit     删除记录条数
 *
 *  @return 删除结果
 */
-(BOOL)delete:(NSString*)table where:(id)condition limit:(NSString*)limit;
/**
 *  查询表记录
 *
 *  @param table     表名
 *  @param condition where条件,字符串,或者是数据字典
 *  @param limit     查询记录条数
 *
 *  @return 查询结果集
 */
- (NSArray *)select:(NSString*)table where:(id)condition limit:(NSString*)limit;
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
-(NSArray *)select:(NSArray *)fields from:(NSString *)table where:(id)condition groupBy:(id)groups order:(NSString *)order limit:(NSString *)limit;
/**
 *  统计表总行数
 *
 *  @param table     表名
 *  @param condition 统计条件
 *
 *  @return 行数
 */
-(NSUInteger)count:(NSString*)table where:(id)condition;

#pragma mark -  Transaction
/**
 *  开始事物
 *
 *  @return 开始结果
 */
- (BOOL)beginTransaction;
/**
 *  开始延迟事物
 *
 *  @return 开始结果
 */
- (BOOL)beginDeferredTransaction;
/**
 *  提交事务
 *
 *  @return 结果
 */
- (BOOL)commitTransaction;
/**
 *  回滚事务
 *
 *  @return 回滚结果
 */
- (BOOL)rollbackTransaction;

#pragma mark -  Info
//最近执行的INSERT、UPDATE和DELETE语句所影响的数据行数
- (NSUInteger)affectedRows;
//自从该连接被打开时起，INSERT、UPDATE和DELETE语句总共影响的行数
- (NSUInteger)totalAffectedRows;
// 是否存在表
- (BOOL) isExistTable:(NSString *)table;
//数据库所有表名
- (NSArray *)tables;
//最后一次插入记录row id
- (NSNumber *)lastInsertID;
//最后一条记录id
- (NSInteger)lastRecodeId:(NSString *)table;
//表列数
- (NSUInteger)columnsInTable:(NSString *)table;
//所有表头
-(NSArray *)columnTitlesInTable:(NSString *)table;
//错误信息
- (NSString *)errorMessage;
//错误代码
- (NSInteger)errorCode;
#pragma mark -  SQLite information
//整数版本号
+ (int)versionNumber;
+ (int)libraryVersionNumber;
//sqlite数据库lib版本
+ (NSString*)sqliteLibVersion;
//是否线程安全
+ (BOOL)isSQLiteThreadSafe;
@end
