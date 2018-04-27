//
//  PACDataBaseManager.m
//  PACFMDBDatabaseManager
//
//  Created by STPACS on 2018/4/27.
//  Copyright © 2018年 STPACS. All rights reserved.
//

#import "PACDataBaseManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface PACDataBaseManager ()
@property (nonatomic,retain)FMDatabase *dataBase;
@property (nonatomic,retain)FMDatabaseQueue *queue;
@end

@implementation PACDataBaseManager

// 初始化数据库
+ (PACDataBaseManager *)shared{
    
    static  PACDataBaseManager *db;
    
    if (db == nil) {
        
        db = [[PACDataBaseManager alloc]init];
    }
    
    return db;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}


// 创建数据库
- (BOOL)createDatabase:(NSString *)dataBaseName{
    
    NSString *dataPath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.db",dataBaseName]];
    NSLog(@"%@",dataPath);
    
    self.queue = [FMDatabaseQueue databaseQueueWithPath:dataPath];
    
    __block BOOL isDb = NO;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        db.logsErrors = YES;
        if (db.open) {
            isDb = YES;
        }
        
    }];
    
    if (isDb) {
        NSLog(@"打开数据库成功");
    }else{
        NSLog(@"打开数据失败");
    }
    
    
    return isDb;
}



// 创建数据库表格
- (BOOL)createDatabaseTales:(NSString *)tableName field:(NSDictionary *)field{
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (keyId integer  PRIMARY KEY AUTOINCREMENT",tableName];
    
    NSArray *arr = [field allKeys];
    
    for (NSInteger i = 0; i < arr.count; i++) {
        
        if (i == arr.count-1) {
            NSString *value = [field valueForKey:arr[i]];
            
            NSString *str = [NSString stringWithFormat:@",%@ %@)",arr[i],value];
            
            [sql appendString:str];
            
        }else{
            
            NSString *value = [field valueForKey:arr[i]];
            
            NSString *str = [NSString stringWithFormat:@",%@ %@",arr[i],value];
            [sql appendString:str];
        }
    }
    __block BOOL isDb = NO;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        isDb = [db executeUpdate:sql];
        
    }];
    
    if (isDb) {
        NSLog(@"创建表格成功");
    }else{
        NSLog(@"创建表格失败");
    }
    return isDb;
    
}


// 数据库插入数据
- (BOOL)insertDatabaseDataByTableName:(NSString *)tableName dataSource:(NSDictionary *)dataSource{
    
    NSArray *fileName = [dataSource allKeys];
    
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(",tableName];
    
    for (int i = 0; i<fileName.count; i++) {
        if (i == fileName.count-1) {
            sql = [sql stringByAppendingFormat:@"%@) VALUES(",fileName[i]];
            
        }else{
            
            sql = [sql stringByAppendingFormat:@"%@,",fileName[i]];
        }
    }
    
    for (int i = 0 ; i<fileName.count; i++) {
        if (i == fileName.count -1) {
            
            sql = [sql stringByAppendingString:@"?)"];
            
        }else{
            
            sql = [sql stringByAppendingString:@"?,"];
        }
    }
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    for (int i = 0 ; i<fileName.count; i++) {
        
        [dataArray addObject:[dataSource valueForKey:fileName[i]]];
    }
    
    __block BOOL isDb = NO;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        isDb = [db executeUpdate:sql withArgumentsInArray:dataArray];
    }];
    
    if (isDb) {
        
        NSLog(@"插入成功");
        
    }else{
        
        NSLog(@"插入失败");
    }
    
    return isDb;
    
}



// 插入多条数据
- (BOOL)insertDatabaseDataByTableName:(NSString *)tableName arrayData:(NSArray *)arrayData{
    
    for (NSDictionary *dict  in arrayData) {
        
        BOOL res = [self insertDatabaseDataByTableName:tableName dataSource:dict];
        
        if (res == NO) {
            return res;
        }
    }
    
    return YES;
}



// 判断数据库表存在不存在
- (BOOL)isDatabaseTablesName:(NSString *)tablesName{
    
    tablesName = [tablesName lowercaseString];
    __block BOOL isDb = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *rs = [db executeQuery:@"select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?", tablesName];
            isDb =[rs next];
        }
    }];
    
    return isDb;
    
}

// 判断数据库表内有没有数据
- (BOOL)isDatabaseDataTablesName:(NSString *)tablesName{
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@",tablesName];
    __block BOOL isDb = NO;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *resu =  [db executeQuery:sql];
        while ([resu next]) {
            isDb = YES;
        }
    }];
    return isDb;
}

// 通过条件更新一个字段数据

- (BOOL)updataDatabaseByTableName:(NSString *)tableName conditionName:(NSString *)conditionName conditionValue:(NSString *)conditionValue updateName:(NSString *)updateName updateValue:(NSString *)updateValue{
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where %@ = '%@'",tableName,updateName,updateValue,conditionName,conditionValue];
    
    __block BOOL isDb = NO;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        isDb =  [db executeUpdate:sql];
    }];
    
    if (isDb) {
        
        NSLog(@"更新成功");
    }else{
        NSLog(@"更新失败");
        
    }
    
    return isDb;
    
    
    
}
// 通过条件更新多个字段数据
- (BOOL)updataDatabaseByTableName:(NSString *)tableName conditionName:(NSString *)conditionName conditionValue:(NSString *)conditionValue updatadataSource:(NSDictionary *)dataSource{
    
    NSArray *arr = [dataSource allKeys];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"update %@ set",tableName];
    
    for (NSInteger i = 0; i< arr.count; i++) {
        
        if (i == 0) {
            [sql appendFormat:@" %@ = '%@'",arr[i],[dataSource valueForKey:arr[i]]];
        }else{
            
            [sql appendFormat:@",%@ = '%@'",arr[i],[dataSource valueForKey:arr[i]]];
        }
    }
    
    [sql appendFormat:@" where %@ = '%@'",conditionName,conditionValue];
    
    __block BOOL isDb = NO;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        NSError *error;
        
        db.logsErrors = YES;
        if (db.open) {
            isDb = [db executeUpdate:sql withErrorAndBindings:&error];
        }
        NSLog(@"%@",error);
    }];
    
    
    
    
    if (isDb) {
        NSLog(@"成功");
    }else{
        NSLog(@"失败");
    }
    
    return isDb;
    
    
    
}

// 获取数据全部数据
- (NSArray *)accessDatabaseTablesAllFieldDataByTablesName:(NSString *)tablesName{
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@",tablesName];
    
    __block   NSMutableArray *arr = [NSMutableArray array];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                
                [arr addObject:[res resultDictionary]];
            }
        }
        
        
    }];
    
    return arr;
}



// 正序倒序输出
- (NSArray *)sortedQueryDatabaseDataByTableName:(NSString *)tableName field:(NSString *)field sorted:(BOOL)sorted{
    
    __block NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql;
    
    if (sorted) {
        sql = [NSString stringWithFormat:@"select * from %@ order by %@",tableName,field];
        
    }else{
        sql = [NSString stringWithFormat:@"select * from %@ order by %@ desc ",tableName,field];
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                
                [arr addObject:[res resultDictionary]];
            }
        }
        
        
    }];
    
    return arr;
}

// 查询数据库输出限制
- (NSArray *)sortedQueryDatabaseDataByTableName:(NSString *)tableName number:(NSInteger)number sorted:(BOOL)sorted{
    
    NSString *sql;
    
    __block  NSMutableArray *arr = [NSMutableArray array];
    
    if (sorted) {
        sql = [NSString stringWithFormat:@"select * from %@ order by keyId limit %ld",tableName,(long)number];
    }else{
        
        sql = [NSString stringWithFormat:@"select * from %@ order by keyId desc limit %ld",tableName,(long)number];
        
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                
                [arr addObject:[res resultDictionary]];
            }
        }
        
        
    }];
    
    return arr;
}


// 通过条件查询数据库输出限制
- (NSArray *)inquiryDatabaseDataByTableName:(NSString *)tableName number:(NSInteger)number sorted:(BOOL)sorted keyString:(NSString *)keyString  typeString:(NSString *)typeString{
    
    NSString *sql;
    
    __block  NSMutableArray *arr = [NSMutableArray array];
    
    if (sorted) {
        sql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' order by updateTime limit %ld",tableName,keyString,typeString,(long)number];
    }else{
        
        sql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' order by updateTime desc limit %ld",tableName,keyString,typeString,(long)number];
        
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                
                [arr addObject:[res resultDictionary]];
            }
        }
        
        
    }];
    
    return arr;
}

// 通过条件查询
- (NSArray *)queryByDatabaseTableName:(NSString *)tableName criteria:(NSString *)criteria fieldName:(NSString *)fieldName{
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where  %@ ='%@'",tableName,fieldName,criteria];
    
    __block NSMutableArray *arr = [NSMutableArray array];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                
                [arr addObject:[res resultDictionary]];
            }
        }
    }];
    
    return arr;
}


// 通过条件查询2
- (NSArray *)queryByDatabaseTableName2:(NSString *)tableName criteria:(NSString *)criteria fieldName:(NSString *)fieldName tj:(NSString *)tj sorted:(BOOL)sorted{
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where  %@ %@'%@' order by updateTime",tableName,fieldName,tj,criteria];
    
    __block  NSMutableArray *arr = [NSMutableArray array];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                
                [arr addObject:[res resultDictionary]];
            }
        }
    }];
    
    return arr;
}

// 通过条件查询2
- (NSArray *)queryByDatabaseTableName2:(NSString *)tableName criteria:(NSString *)criteria fieldName:(NSString *)fieldName tj:(NSString *)tj{
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where  %@ %@'%@'",tableName,fieldName,tj,criteria];
    
    __block   NSMutableArray *arr = [NSMutableArray array];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                
                [arr addObject:[res resultDictionary]];
            }
        }
        
        
    }];
    
    return arr;
}


// 通过多个条件查询
- (NSArray *)queryByDatabaseTableName:(NSString *)tableName criteriaDictionary:(NSDictionary *)dictionary{
    
    NSMutableString *sql = [[NSMutableString alloc]initWithFormat:@"select * from %@ where",tableName];;
    
    NSArray *arrs = [dictionary allKeys];
    
    for (NSInteger i = 0; i<arrs.count;i++) {
        
        NSString *field = [arrs objectAtIndex:i];
        
        if (i == 0) {
            [sql appendFormat:@" %@ = '%@'",field,[dictionary valueForKey:field]];
        }else{
            
            [sql appendFormat:@" and %@ = '%@'",field,[dictionary valueForKey:field]];
        }
        
    }
    
    __block NSMutableArray *arr = [NSMutableArray array];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                
                [arr addObject:[res resultDictionary]];
            }
        }
        
        
    }];
    return arr;
}


// 按自增长id 输出
- (NSArray *)accordingConditionOutputDatabaseDataByTableName:(NSString *)tableName maximumValue:(NSInteger)maximumValue minimumValue:(NSInteger)minimumValue sorted:(BOOL)sorted
{
    NSString *sql;
    __block NSMutableArray *arr = [NSMutableArray array];
    
    if (sorted) {
        
        sql = [NSString stringWithFormat:@"select * from %@ where keyId <=%ld and keyId>=%ld order by keyId",tableName,(long)minimumValue,(long)maximumValue];
    }else{
        sql = [NSString stringWithFormat:@"select * from %@ where keyId <=%ld and keyId>=%ld order by keyId desc",tableName,(long)minimumValue,(long)maximumValue];
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                
                [arr addObject:[res resultDictionary]];
            }
        }
    }];
    
    
    return arr;
}



// 删除数据
- (BOOL)deleteDatabaseDataByTableName:(NSString *)tableName conditionName:(NSString *)conditionName conditionValue:(NSString *)conditionValue{
    
    NSString *sql =[NSString stringWithFormat:@"DELETE FROM %@ where %@ = '%@'",tableName,conditionName,conditionValue];
    
    __block BOOL isDb = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        db.logsErrors  = YES;
        if (db.open) {
            
            isDb = [db executeUpdate:sql];
        }
        
    }];
    if (isDb == NO) {
        NSLog(@"删除失败");
        
    }
    NSLog(@"删除成功");
    return isDb;
}


// 删除表格全部数据
- (BOOL)allDeleteDatabaseDataTable:(NSString *)tableName{
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@",tableName];
    __block BOOL isDb = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        
        isDb = [db executeUpdate:sql];
    }];
    
    //    BOOL s = [self.dataBase executeUpdate:sql];
    if (isDb == NO) {
        //NSLog(@"删除失败");
        
    }
    //NSLog(@"删除成功");
    
    return isDb;
}

// 移除数据库表格
- (BOOL)removeDatabaseTable:(NSString *)tableName{
    
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@",tableName];
    __block BOOL isDb = NO;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        isDb = [db executeUpdate:sql];
    }];
    
    return isDb;
}

// 取出最大值
- (NSInteger )macIndex:(NSString *)tableName field:(NSString *)field size:(BOOL)size
{
    __block NSInteger maxIndex = 0;
    
    NSString *sql;
    if (size) {
        sql = [NSString stringWithFormat:@"select * from %@ order by %@ desc limit 1",tableName,field];
        
    }else{
        
        sql = [NSString stringWithFormat:@"select * from %@ order by %@  limit 1",tableName,field];
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *res = [db executeQuery:sql];
            while ([res next]) {
                int userId1 = [res intForColumn:@"field"];
                maxIndex = userId1;
            }
        }
    }];
    
    return maxIndex;
}

// 获取一个字段的全部值
- (NSArray *)outputFieldAllValueByFieldName:(NSString *)fieldName tableName:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
    __block  NSMutableArray *result = [NSMutableArray array];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if (db.open) {
            FMResultSet *resu =  [db executeQuery:sql];
            while ([resu next]) {
                [result addObject:[resu stringForColumn:fieldName]];
            }
        }
    }];
    return  result ;
}


@end
