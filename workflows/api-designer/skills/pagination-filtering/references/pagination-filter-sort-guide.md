# 分页、筛选、排序指南

## 1. 分页模式

### Offset / limit

适合普通后台列表。

```text
GET /resources?offset=0&limit=20
```

### Page / pageSize

适合面向页面的列表。

```text
GET /resources?page=1&pageSize=20
```

### Cursor

适合高频写入、大数据量、无限滚动。

```text
GET /resources?cursor=xxx&limit=20
```

## 2. 筛选

```text
筛选字段必须白名单。
枚举值必须明确。
日期范围必须说明时区。
复杂筛选要避免发明难维护的小语言。
```

## 3. 排序

```text
必须定义默认排序。
只允许稳定字段排序。
分页和排序组合必须稳定，避免翻页重复或遗漏。
```

## 4. 搜索

```text
说明搜索字段范围。
说明是否分词、模糊、大小写敏感。
无结果返回空列表，不返回错误。
```

## 5. 字段选择

```text
fields 用于减少响应字段。
include/expand 用于展开关联资源。
敏感字段不可通过 fields 强行返回。
```
