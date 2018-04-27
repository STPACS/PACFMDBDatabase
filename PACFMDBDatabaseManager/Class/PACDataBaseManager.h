//
//  PACDataBaseManager.h
//  PACFMDBDatabaseManager
//
//  Created by STPACS on 2018/4/27.
//  Copyright © 2018年 STPACS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PACDataBaseManager : NSObject
/**
 *  全局初始化数据库
 *
 *  @return 返回实例
 */
+ (PACDataBaseManager *)shared;

/**
 *  创建数据库
 *
 *  @param dataBaseName 数据库名字
 *
 *  @return [YES/成功][NO/失败]
 */
- (BOOL)createDatabase:(NSString *)dataBaseName;



/**
 *  判断数据库表格是否存在
 *
 *  @return [YES/存在][NO/不存在]
 */
- (BOOL)isDatabaseTablesName:(NSString *)tablesName;



/**
 *  判断数据库表格是否有数据
 *
 *  @param tablesName 表格名字
 *
 *  @return [YES/存在][NO/不存在]
 */
- (BOOL)isDatabaseDataTablesName:(NSString *)tablesName;




/*************************     field value支持的值类型          **************************/
/************************* value***INTERGER - 有符号整数类型    **************************/
/************************* value***REAL     - 浮点数类型       ***************************/
/************************* value***TEXT     - 字符串          ***************************/
/************************* value***BLOB     - 二进制表示      ****************************/

/**
 *  创建数据库表格
 *
 *  @param tableName 表格名称
 *  @param field     表格字段名称 和 字段类型 value类型 Key字段名称
 *
 *  @return [YES/成功][NO/失败]
 */
- (BOOL)createDatabaseTales:(NSString *)tableName field:(NSDictionary *)field;



/**
 *  插入数据库字段数据
 *
 *  @param tableName  表格名字
 *  @param dataSource 数据源
 *
 *  @return [YES/成功][NO/失败]
 */
- (BOOL)insertDatabaseDataByTableName:(NSString *)tableName dataSource:(NSDictionary *)dataSource;


/**
 *  插入多条数据
 *
 *  @param tableName 字段名字
 *  @param arrayData 多条数据数组 [数组内是字典]
 *
 *  @return [YES/成功][NO/失败]
 */
- (BOOL)insertDatabaseDataByTableName:(NSString *)tableName arrayData:(NSArray *)arrayData;

/**
 *  通过条件更新一个字段数据
 *
 *  @param tableName      表格名字
 *  @param conditionValue      条件字段类型
 *  @param conditionName  条件字段名
 *  @param updateName     更新字段名
 *  @param updateValue    更新字段值
 *
 *  @return [YES 插入成功][NO 插入失败]
 */
- (BOOL)updataDatabaseByTableName:(NSString *)tableName conditionName:(NSString *)conditionName conditionValue:(NSString *)conditionValue updateName:(NSString *)updateName updateValue:(NSString *)updateValue;

/**
 *  通过条件更新多个字段数据
 *
 *  @param tableName      表格名字
 *  @param conditionName  条件字段名字
 *  @param conditionValue 条件字段值
 *  @param dataSource     更新数据源  字段形式 key 更新的字段名  value 更新的字段值
 *
 *  @return [YES 插入成功][NO 插入失败]
 */
- (BOOL)updataDatabaseByTableName:(NSString *)tableName conditionName:(NSString *)conditionName conditionValue:(NSString *)conditionValue updatadataSource:(NSDictionary *)dataSource;


/**
 *  获取数据库表格全部数据
 *
 *  @param tablesName 表格名字
 *
 *  @return 数组字典
 */
- (NSArray *)accessDatabaseTablesAllFieldDataByTablesName:(NSString *)tablesName;



/**
 *  正序倒序查询数据库
 *
 *  @param tableName 表格名字
 *  @param field     字段名字   这个储存的是必须是 数字类型 如果没有 请传 keyId
 *  @param sorted    [YES/正序][NO/倒序]
 *
 *  @return 数组字典
 */
- (NSArray *)sortedQueryDatabaseDataByTableName:(NSString *)tableName field:(NSString *)field sorted:(BOOL)sorted;

/**
 *  查询数据库输出限制
 *
 *  @param tableName 表格名字
 *  @param number    输出条数
 *  @param sorted    [YES/正序][NO/倒序]
 *
 *  @return 数组字典
 */
- (NSArray *)sortedQueryDatabaseDataByTableName:(NSString *)tableName number:(NSInteger)number sorted:(BOOL)sorted;

// *  按自增长 id  条件查询
// *
// *  @param tableName    表格名字
// *  @parama maximumValues 最大 id（自增长id）
// *  @params minimumValues 最小 id（自增长id）
// *  @param sorted       [YES/正序][NO/倒序]
// *
// *  @return 数组字典



// 通过条件查询数据库输出限制
- (NSArray *)inquiryDatabaseDataByTableName:(NSString *)tableName number:(NSInteger)number sorted:(BOOL)sorted keyString:(NSString *)keyString  typeString:(NSString *)typeString;



- (NSArray *)accordingConditionOutputDatabaseDataByTableName:(NSString *)tableName maximumValue:(NSInteger)maximumValue minimumValue:(NSInteger)minimumValue sorted:(BOOL)sorted;

/**
 *  按条件查询
 *
 *  @param tableName 表名
 *  @param criteria  条件值
 *  @param fieldName 条件字段名
 *
 *  @return 数组字典
 */
- (NSArray *)queryByDatabaseTableName:(NSString *)tableName criteria:(NSString *)criteria fieldName:(NSString *)fieldName;

- (NSArray *)queryByDatabaseTableName2:(NSString *)tableName criteria:(NSString *)criteria fieldName:(NSString *)fieldName tj:(NSString *)tj sorted:(BOOL)sorted;
/**
 *  通过多个条件查询
 *
 *  @param tableName  表名
 *  @param dictionary 条件字典
 *
 *  @return 数组字典
 */
- (NSArray *)queryByDatabaseTableName:(NSString *)tableName  criteriaDictionary:(NSDictionary *)dictionary;

/**
 *  获得一个字段的全部值
 *
 *  @param fieldName 字段名
 *  @param tableName 表格名字
 *
 *  @return 数组
 */
- (NSArray *)outputFieldAllValueByFieldName:(NSString *)fieldName tableName:(NSString *)tableName;


/**
 *  取出一个字段的最大值 或者 最小值
 *
 *  @param tableName 表格名字
 *  @param field     字段名字
 *  @param size      [YES/最大值][NO/最小值]
 *
 *  @return 数字类型
 */
- (NSInteger )macIndex:(NSString *)tableName field:(NSString *)field size:(BOOL)size;


/**
 *  删除数据库表格的一条数据
 *
 *  @param tableName      表格名字
 *  @param conditionName  字段名字
 *  @param conditionValue 字段值
 *
 *  @return [YES 删除成功][NO 删除失败]
 */
- (BOOL)deleteDatabaseDataByTableName:(NSString *)tableName conditionName:(NSString *)conditionName conditionValue:(NSString *)conditionValue;

/**
 *  删除表格全部数据
 *
 *  @param tableName 表格名字
 *
 *  @return [YES 删除成功][NO 删除失败]
 */
- (BOOL)allDeleteDatabaseDataTable:(NSString *)tableName;

/**
 *  移除数据库表格
 *
 *  @param tableName 表格名字
 *
 *  @return [YES 删除成功][NO 删除失败]
 */
- (BOOL)removeDatabaseTable:(NSString *)tableName;

// 通过条件查询
- (NSArray *)queryByDatabaseTableName2:(NSString *)tableName criteria:(NSString *)criteria fieldName:(NSString *)fieldName tj:(NSString *)tj;
@end
