# Mojo-CentosPerl

在Centos-6.5-x86_64系统上编译打包而成,包含Perl-5.16+cpanm+Mojo-Webqq+Mojo-Weixin的完整Linux运行环境

测试可以在Centos 6.5/6.7/7.0 上正常运行，如有问题请反馈给作者

##安装方法：

1. 下载压缩包（ZIP约21M，tar.gz约18M）

        $ wget https://github.com/sjdy521/Mojo-CentosPerl/archive/master.zip -O Mojo-CentosPerl.zip

    如果github下载较慢，可以尝试使用腾讯云存储的文件下载地址（可能较旧）

        $ wget http://share-10066126.cos.myqcloud.com/Mojo-CentosPerl-20161116.zip -O Mojo-CentosPerl.zip
        
        $ wget http://share-10066126.cos.myqcloud.com/Mojo-CentosPerl-20161116.tar.gz -O Mojo-CentosPerl.tar.gz
        

2. 解压到指定路径（会把perl安装到 /usr/local/perl 目录下）
   
    对于ZIP包 

        $ unzip Mojo-CentosPerl.zip -d /usr/local/  #路径不能够更改，请确保有相关权限

    对于tar.gz包

        $ tar zxf Mojo-CentosPerl.tar.gz -C /usr/local #路径不能够更改，请确保有相关权限

3. 把Mojo-CentosPerl包含的perl和cpanm设置下alias，避免和系统默认的perl混淆（或者直接使用绝对路径）

        $ /usr/local/perl/bin/perl -v       #使用perl的绝对路径
        $ /usr/local/perl/bin/cpanm --help  #使用cpanm的绝对路径

   或者绝对路径太长，可以给命令起个别名，方便使用，如下两行写入到 ~/.bashrc 文件的最后

        alias perl='/usr/local/perl/bin/perl'
        alias cpanm='/usr/local/perl/bin/cpanm' 

    执行如下命令来使得 ~/.bashrc 的改动生效

        $ source ~/.bashrc

    现在你可以直接使用别名来执行perl和cpanm
        
        $ perl -v 
        $ cpanm --help
