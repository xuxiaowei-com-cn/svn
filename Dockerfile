# 第一阶段：编译 SVN 源码

# 选择运行时基础镜像
FROM openanolis/anolisos:8.6 as svn-make

# 维护人员
MAINTAINER 徐晓伟 xuxiaowei@xuxiaowei.com.cn

# 工作空间
WORKDIR /home/svn

# 添加 SVN 源码
ADD subversion-1.14.2.tar.gz .

# 查看文件
RUN ls

# 配置、编译、安装环境准备
# configure: error: no acceptable C compiler found in $PATH
RUN yum -y install gcc

# 调整工作空间
WORKDIR /home/svn/subversion-1.14.2
# 查看文件
RUN ls
# 配置并指定目录
RUN ./configure --prefix=/usr/local/svn
