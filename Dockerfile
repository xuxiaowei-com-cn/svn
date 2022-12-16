# 第一阶段：编译 SVN 源码

# 选择运行时基础镜像
FROM openanolis/anolisos:8.6 as svn-make

# 维护人员
MAINTAINER 徐晓伟 xuxiaowei@xuxiaowei.com.cn

# 工作空间
WORKDIR /home/svn

# 添加 SVN 源码
ADD subversion-1.14.2.tar.gz .
ADD apr-1.7.0.tar.gz .
ADD apr-util-1.6.1.tar.gz .
ADD sqlite-amalgamation-3081101.zip .
ADD utf8proc-2.8.0.tar.gz .

# 查看文件
RUN ls

# 配置、编译、安装环境准备
# configure: error: no acceptable C compiler found in $PATH
RUN yum -y install gcc
# /bin/sh: make: command not found
RUN yum -y install make
#  #include <expat.h>
RUN yum -y install expat-devel
# 用于解压 .zip 文件
RUN yum -y install unzip
# configure: error: subversion requires zlib
RUN yum -y install zlib-devel
# configure: error: Subversion requires LZ4 >= r129, or use --with-lz4=internal
RUN yum -y install lz4-devel

# SVN 环境准备
# configure: WARNING: APR not found
# Subversion with both the --with-apr and --with-apr-util options.
# configure: error: no suitable APR found
WORKDIR /home/svn/apr-1.7.0
RUN ./configure
RUN make
RUN make install
RUN ls /usr/local/apr/
RUN ls /usr/local/apr/lib/
RUN ls /usr/local/apr/lib/pkgconfig/
RUN ls /usr/local/apr/include/


# SVN 环境准备
# configure: WARNING: APRUTIL not found
#  appropriate --with-apr-util option.
# configure: error: no suitable APRUTIL found
WORKDIR /home/svn/apr-util-1.6.1
RUN ./configure --with-apr=/usr/local/apr
RUN make
RUN make install
RUN ls /usr/local/apr/
RUN ls /usr/local/apr/lib/
RUN ls /usr/local/apr/lib/pkgconfig/
RUN ls /usr/local/apr/include/

# SVN 环境准备
# configure: error: Subversion requires SQLite
WORKDIR /home/svn/
RUN unzip sqlite-amalgamation-3081101.zip
RUN mv sqlite-amalgamation-3081101 /home/svn/subversion-1.14.2/sqlite-amalgamation
RUN ls /home/svn/subversion-1.14.2/sqlite-amalgamation/

# SVN 环境准备
# configure: error: Subversion requires UTF8PROC; install it or re-run configure with "--with-utf8proc=internal"
WORKDIR /home/svn/utf8proc-2.8.0
RUN make
RUN make install
RUN ls /usr/local/include/
RUN ls /usr/local/lib/
RUN ls /usr/local/lib/pkgconfig/

# 调整工作空间
WORKDIR /home/svn/subversion-1.14.2
# 查看文件
RUN ls
# 配置并指定目录
RUN ./configure
RUN make
RUN make install
