## 项目名称： 懒大厨
<img src="https://img-blog.csdnimg.cn/20200520095243967.png"/>

项目已完成，下载可以直接运行看效果
<img src="https://storage-1255928497.cos.ap-guangzhou.myqcloud.com/lazycook/qr.png" width="40%"/>
扫码下载或[点击下载](https://storage-1255928497.cos.ap-guangzhou.myqcloud.com/lazycook/lazycook.apk)
#### 功能
本人练手项目，菜谱类app，前期功能比较较简单，包含以下模块：

 - 用户模块：注册、登录、修改密码
  
 - 菜品模块：菜品制作过程展示、检索、上新、收藏
 
 #### 技术实现
 
 - Provider实现组件的状态管理，做到局部刷新
 - 自定义LoadContainer、ListContainer、SlideListContainer容器等
 - 自定义Dialog，包括LoadingDialog、[自定义布局Dialog](https://blog.csdn.net/qq627578198/article/details/105486722)等
 - 在[photo_view](https://github.com/renancaraujo/photo_view)、[image_picker](https://github.com/flutter/plugins)基础上，自定义[图片裁剪](https://blog.csdn.net/qq627578198/article/details/103981254)
 - 使用[fluro](https://github.com/theyakka/fluro)作为路由管理器，并对其基础上实现路由[拦截跳转功能](https://blog.csdn.net/qq627578198/article/details/105487091)，比如登录判断
 - 使用[localstorage](https://github.com/lesnitsky/flutter_localstorage) 存储数据到本地
 - MD5、AES、RSA加密、签名
 - 自定义滑动删除，支持为每一条item定制操作按钮
 
 #### 效果展示
 <table>
 <tr>
 		<td>
 		 <img src="https://img-blog.csdnimg.cn/20200520111612237.png" width="50%"/>
 		</td>
 		<td>
 		  <img src="https://img-blog.csdnimg.cn/20200520111612237.png" width="50%"/>
 		 </td>
 	</tr>
 	<tr>
 		<td>
 		<img src="https://img-blog.csdnimg.cn/20200520102345117.png" width="50%"/>
 		</td>
 		<td>
 		 <img src="https://img-blog.csdnimg.cn/20200520102343864.png" width="50%"/>
 		 </td>
 	</tr>
 	<tr>
 		<td>
 		 <img src="https://img-blog.csdnimg.cn/20200520102345554.png" width="50%"/>
 		</td>
 		<td>
 		  <img src="https://img-blog.csdnimg.cn/20200520102344200.png" width="50%"/>
 		 </td>
 	</tr>
 	<tr>
 		<td>
 		 <img src="https://img-blog.csdnimg.cn/20200520110319294.png" width="50%"/>
 		</td>
 		<td>
 		  <img src="https://img-blog.csdnimg.cn/20200520110420920.png" width="50%"/>
 		 </td>
 	</tr>
 </table>

[源码地址](https://github.com/MrDavy/lazycook_flutter)
