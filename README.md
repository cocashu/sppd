# hy_goods2-商品盘点

A Flutter learning project
一个Flutter 学习项目

## FLUTTER 新手
学习作品，经过实际使用，效果还是可以的。

在登录认证什么的，使用的代码还是比较初级，基本能用。

## 主要功能
在线商品盘点和离线商品盘点

ps:上传时已将测试url地址修改为：URL

测试使用用注意替换

###在线商品

主要是实时连接盘点商品的数据库盘点并回传盘点数据。

### 离线盘点

主要用于无网络情况下的盘点
可以在有网络的情况下下载离线数据或上传盘点数据

## 打包命令

flutter build apk --target-platform android-arm,android-arm64 --split-per-abi

## 完整的打包命令如

flutter build apk --target-platform android-arm,android-arm64 --split-per-abi --release --no-tree-shake-icons#

## 好久不用git把命令备份一下
echo "# sppd" >> README.md

git init  //把这个目录变成Git可以管理的仓库

git add README.md   //文件添加到仓库

git add . //不但可以跟单一文件，还可以跟通配符，更可以跟目录。一个点就把当前目录下所有未追踪的文件全部add了 

git commit -m "first commit" //把文件提交到仓库

git branch -M main

git remote add origin git@github.com:cocashu/sppd.git  //关联远程仓库

git push -u origin main  //把本地库的所有内容推送到远程库上


git status //查看仓库状态

--修改提交

git commit -m "修改内容"

git status   查看状态

git push   提交代码到github
