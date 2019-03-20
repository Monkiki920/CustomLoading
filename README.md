在iOS开发中，经常会有一个页面中有多个异步请求的情况，在数据请求未完成的情况下，应该对用户的操作进行限制，防止出现由于数据未请求完成导致的bug。
而且如果某个请求已经出错，应当提示用户重新操作，从服务端拉取数据。
自定义Loading，在很多项目中都有这种需求，但是在App所有需要添加Loading的地方一个个添加未免太过麻烦，于是写了这个小东西，使用类别实现的一个Loading扩展。
效果预览

![image](https://raw.githubusercontent.com/Monkiki920/CustomLoading/master/loading.gif)
