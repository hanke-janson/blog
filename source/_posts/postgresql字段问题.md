---
title: postgresql字段问题
date: 2025-07-04 11:23:26
categories: GIS
tags: [postgresql, 坑]
---

# postgresql字段问题

postgresql 在创建表及字段时，大小写不敏感，即使写成大写，也会自动变为小写，

如果想要区分大小写的话，需要使用 `""` 包裹起来，如 `CREATE TABLE "TABLE_NAME" ("FIELD_NAME" varchar(255))`

如果这样的话 使用`mybatis-plus` 可能需要单独配置。
