//
//  TaxiWhereDescription.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaxiWhereDesc){
    TaxiWhereDescEquelTo = 0,         // ==
    TaxiWhereDescLessThan,            // <
    TaxiWhereDescLessThanOrEquelTo,   // <=
    TaxiWhereDescNotEquelTo,          // !=
    TaxiWhereDescGreaterThan,         // >
    TaxiWhereDescGreaterThanOrEquelTo,// >=
    TaxiWhereDescLike,                // like
};

typedef NS_ENUM(NSInteger, TaxiConnect){
    TaxiConnectAND = 0,
    TaxiConnectOR,
};

@interface TaxiWhereDescription : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, copy, readonly, nullable) NSString *sql;
@property (nonatomic, copy, readonly, nullable) NSArray <id>*values;


// 快捷方式，例如：
// where age not in ( '25', '27', '29' )
// where age between '25' and '27'
- (instancetype)initWithSql:(NSString * _Nullable)sql;

// key-values的关系，例如：
// where age not in ( 25, 27, 29 )，sql = where age not in ( ?, ?, ? )， values = [@25, @27, @29]
// where age between 25 and 27，sql = where age between ? and ?， values = [@25, @27]
- (instancetype)initWithSql:(NSString * _Nullable)sql values:(NSArray <id>* _Nullable)values;

// key-value的关系，例如：
// where age > 27，name = age or field.name，value = @27，compareDesc = .GreaterThan
- (instancetype)initWithName:(NSString * _Nullable)name value:(id _Nullable)value compareDesc:(TaxiWhereDesc)compareDesc;

@end

NS_ASSUME_NONNULL_END
