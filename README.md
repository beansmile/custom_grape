# 基础项目

## Teac Stack

- Ruby: 2.6.4
- Rails: 6.0.x

## Development

```
git clone repo
cp example.env .env # and edit content
cp config/database.yml.example config/database.yml
echo "<master.key>" > config/master.key # find it on resources repo
yarn install
bundle install
rails db:create db:migrate db:seed
# change config based on project requirements
rails server
curl localhost:3000/health_check # to check if config is correct
```

## 账号配置

### master.key
53209498cc0aaeed37a19705be371e89

### 小程序

### 微信商户号

暂无，基础版暂不集成支付

### OSS

### 邮件服务

开发环境: noreply@beansmile-dev.com

### Sentry

### SMTP

## Features List

## API Generator

## GitLab Flow

features/bugfix/etc... -> develop -> staging -> master

## 跟前端的接口对接

工具：[json-server](https://github.com/typicode/json-server)
