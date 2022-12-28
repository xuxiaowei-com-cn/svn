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
RUN ls /usr/local/
RUN ls /usr/local/include/ && echo '可以看到，现在未安装任何软件时，/usr/local/include/ 文件夹为空'
RUN ls /usr/local/lib/ && echo '可以看到，现在未安装任何软件时，/usr/local/lib/ 文件夹为空'

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

RUN ls /usr/local/
RUN ls /usr/local/include/ && echo '可以看到，yum 安装文件后，/usr/local/include/ 文件夹为空'
RUN ls /usr/local/lib/ && echo '可以看到，yum 安装文件后，/usr/local/lib/ 文件夹为空'

# SVN 环境准备
# configure: WARNING: APR not found
# Subversion with both the --with-apr and --with-apr-util options.
# configure: error: no suitable APR found
WORKDIR /home/svn/apr-1.7.0
RUN ./configure
RUN make
RUN make install
RUN ls /usr/local/
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
RUN ls /usr/local/
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
RUN ls /usr/local/
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
RUN ls /usr/local/
RUN ls /usr/local/bin/
RUN ls /usr/local/bin/svn*
RUN /usr/local/bin/svn --version

WORKDIR /
RUN svn --version

RUN yum -y remove gcc
RUN yum -y remove make
RUN yum -y remove expat-devel
RUN yum -y remove unzip
RUN yum -y remove zlib-devel
RUN yum -y remove lz4-devel
RUN /usr/local/bin/svn --version
RUN svn --version

# 第二阶段，使用第一阶段编译构建好的可执行文件来构建 git 镜像

FROM openanolis/anolisos:8.6

WORKDIR /home

# 从第一阶段中复制构建好的可执行文件
COPY --from=svn-make /usr/local/apr/ /usr/local/apr/
COPY --from=svn-make /usr/local/include/ /usr/local/include/
COPY --from=svn-make /usr/local/lib/ /usr/local/lib/

COPY --from=svn-make /usr/local/share/man/man1/svn.1 /usr/local/share/man/man1/svn.1
COPY --from=svn-make /usr/local/share/man/man1/svnadmin.1 /usr/local/share/man/man1/svnadmin.1
COPY --from=svn-make /usr/local/share/man/man1/svndumpfilter.1 /usr/local/share/man/man1/svndumpfilter.1
COPY --from=svn-make /usr/local/share/man/man1/svnlook.1 /usr/local/share/man/man1/svnlook.1
COPY --from=svn-make /usr/local/share/man/man1/svnmucc.1 /usr/local/share/man/man1/svnmucc.1
COPY --from=svn-make /usr/local/share/man/man1/svnrdump.1 /usr/local/share/man/man1/svnrdump.1
COPY --from=svn-make /usr/local/share/man/man8/svnserve.8 /usr/local/share/man/man8/svnserve.8
COPY --from=svn-make /usr/local/share/man/man5/svnserve.conf.5 /usr/local/share/man/man5/svnserve.conf.5
COPY --from=svn-make /usr/local/share/man/man1/svnsync.1 /usr/local/share/man/man1/svnsync.1
COPY --from=svn-make /usr/local/share/man/man1/svnversion.1 /usr/local/share/man/man1/svnversion.1

COPY --from=svn-make /usr/local/bin/svn* /usr/local/bin/
RUN ls /usr/local/bin/svn*
RUN /usr/local/bin/svn --version
RUN svn --version

# SVN 端口
EXPOSE 3690

# 创建文件夹
RUN mkdir /svn-data

# 创建 SVN 仓库
RUN svnadmin create /svn-data/test

# 将 # anon-access = read 替换为 anon-access = none
# 禁止匿名访问
# “#”需要转译
RUN sed -i "s/\# anon-access = read/anon-access = none/g" /svn-data/test/conf/svnserve.conf

RUN sed -i "s/\# auth-access = write/auth-access = write/g" /svn-data/test/conf/svnserve.conf
RUN sed -i "s/\# password-db = passwd/password-db = passwd/g" /svn-data/test/conf/svnserve.conf
RUN sed -i "s/\# authz-db = authz/authz-db = authz/g" /svn-data/test/conf/svnserve.conf

# 创建用户
# 用户名：xuxiaowei
# 密码：123456
RUN echo 'xuxiaowei = 123456' >> /svn-data/test/conf/passwd

# 设置目录的权限
RUN echo '[/]' >> /svn-data/test/conf/authz
RUN echo 'xuxiaowei = rw' >> /svn-data/test/conf/authz
RUN echo '*=' >> /svn-data/test/conf/authz
