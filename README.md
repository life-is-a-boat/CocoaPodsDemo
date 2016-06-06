# CocoaPodsDemo

CocoaPods 使用指南：

安装方式异常简单 , Mac 下都自带 ruby，使用 ruby 的 gem 命令即可下载安装：
$ sudo gem install cocoapods
$ pod setup

另外，ruby 的软件源 https://rubygems.org 因为使用的是亚马逊的云服务，所以被墙了，需要更新一下 ruby 的源，使用如下代码将官方的 ruby 源替换成国内淘宝的源：
gem sources --remove https://rubygems.org/
gem sources -a https://ruby.taobao.org/
gem sources -l

还有一点需要注意，pod setup在执行时，会输出Setting up CocoaPods master repo，但是会等待比较久的时间。这步其实是 Cocoapods 在将它的信息下载到 ~/.cocoapods目录下，如果你等太久，可以试着 cd 到那个目录，用du -sh *来查看下载进度。你也可以参考本文接下来的使用 cocoapods 的镜像索引一节的内容来提高下载速度。

然后执行安装命令

在项目目录下创建文件Podfile
仿照下规则书写

platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
  pod 'AFNetworking', '~> 2.6'
  pod 'ORStackView', '~> 3.0'
  pod 'SwiftyJSON', '~> 2.3'
end

Tip: CocoaPods provides a pod init command to create a Podfile with smart defaults. You should use it.

执行下命令给项目安装cocoaPods
$ pod install



  
