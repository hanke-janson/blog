---
title: gitlab访问502问题
date: 2025-11-19 21:57:51
categories: gitlab
tags: [git]
---

# gitlab访问502问题

今天打开电脑发现gitlab访问502了，服务器上面的gitlab是使用docker进行搭建的。

进入容器内处理

```shell
# 修改externel-url为web可访问url
vim /etc/gitlab/gitlab.rb
# 修改port(不让22端口冲突)
vim /assets/sshd_config
cd /opt/gitlab/bin
gitlab-ctl reconfigure
gitlab-ctl restart
```

问题原因：

> 因为host模式原因导致
> 该问题于虚拟机中搭建gitlab时出现
