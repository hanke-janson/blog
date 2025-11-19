---
title: gitlab中root密码忘记怎么办
date: 2025-11-19 21:58:20
categories: gitlab
tags: [git]
---

# gitlab中root密码忘记怎么办

修改gitlab中root用户的密码（Omnibus GitLab）

进入容器内处理

```shell
sudo gitlab-rails console -e production
# 在控制台中执行
user=User.find_by(username:'root')
user.password='新密码'
user.password_confirmation='新密码'
user.save!
exit
# 重启GitLab服务
sudo gitlab-ctl reconfigure
```
