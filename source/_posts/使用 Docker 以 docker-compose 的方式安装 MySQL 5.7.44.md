---
title: 使用 Docker 以 docker-compose 的方式安装 MySQL 5.7.44
date: 2025-05-03 05:11:19
categories: Database
tags: mysql
---

# 使用 Docker 以 docker-compose 的方式安装 MySQL 5.7.44

## 前置条件
1. 已安装 Docker 和 Docker Compose。
2. 确保本地没有占用 3306 端口的服务。

## 步骤

### 1. 创建项目目录
在终端中执行以下命令：
```bash
mkdir mysql-docker && cd mysql-docker
```

### 2. 创建 `docker-compose.yml` 文件
在项目目录下创建 `docker-compose.yml` 文件，并添加以下内容：
```yaml
version : '3'
services:
  mysql:
    # 容器名(以后的控制都通过这个)
    container_name: mysql5.7.44
    # 重启策略
    restart: always
    image: mysql:5.7.44
    ports:
      - "3306:3306"
    volumes:
      # 挂载配置文件
      - C:\dev\1 tools\docker_mnt\mysql5.7.44\conf:/etc/mysql/conf.d
      # 挂载日志
      - C:\dev\1 tools\docker_mnt\mysql5.7.44\logs:/logs
      # 挂载数据
      - C:\dev\1 tools\docker_mnt\mysql5.7.44\data:/var/lib/mysql
    command: [
          'mysqld',
          '--innodb-buffer-pool-size=80M',
          '--character-set-server=utf8mb4',
          '--collation-server=utf8mb4_unicode_ci',
          '--default-time-zone=+8:00',
          '--lower-case-table-names=1'
        ]
    environment:
      # root 密码
      MYSQL_ROOT_PASSWORD: 123456
```

### 3. 启动服务
在终端中执行以下命令启动 MySQL 服务：
```bash
docker-compose up -d
```

### 4. 验证安装
执行以下命令查看容器状态：
```bash
docker ps
```
确保 `mysql5.7.44` 容器正在运行。

### 5. 连接 MySQL
使用以下命令连接到 MySQL：
```bash
docker exec -it mysql5.7.44 mysql -u root -p
```
输入 `MYSQL_ROOT_PASSWORD` 即可登录。

## 注意事项
- 修改 `docker-compose.yml` 中的密码和用户名为实际需要的值。
- 数据库数据会保存在 `mysql_data` 卷中，容器删除后数据仍然保留。
