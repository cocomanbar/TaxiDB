# TaxiDB

[![CI Status](https://img.shields.io/travis/cocomanbar/TaxiDB.svg?style=flat)](https://travis-ci.org/cocomanbar/TaxiDB)
[![Version](https://img.shields.io/cocoapods/v/TaxiDB.svg?style=flat)](https://cocoapods.org/pods/TaxiDB)
[![License](https://img.shields.io/cocoapods/l/TaxiDB.svg?style=flat)](https://cocoapods.org/pods/TaxiDB)
[![Platform](https://img.shields.io/cocoapods/p/TaxiDB.svg?style=flat)](https://cocoapods.org/pods/TaxiDB)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TaxiDB is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby

pod 'TaxiDB'

```

```ruby

*  已完成功能：
*
*  1. 创建数据库，根据uid切换数据库功能
*  2. 根据模型创建表
*  3. 支持自动升级表内容检查和自动更新表：包括  增加字段  更改字段名字 删除字段 或 同时存在以上一个或多个操作行为
*  4. 插入模型数据：存在主键相同数据不插入
*  5. 更新模型数据：存在主键相同数据不更新
*  6. 执行插入或更新数据：存在即更新，不存在即插入
*  8. 根据条件查询或删除表内数据
*  9. 支持执行sqlite3语句
*
*  11.根据字典基本类型创建表
*  12.字典类型目前限制key-value都是NSString类型
*  13.支持表版本升级，需要模块监听升级自己模块内的类，注意升级时触发任务的线程或卡顿问题

```

## Author

cocomanbar, 125322078@qq.com

## License

TaxiDB is available under the MIT license. See the LICENSE file for more info.
