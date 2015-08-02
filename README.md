#iPhone,iPad识别条形码
* 二维码，
	* 将扫描出的二维码打开进入
* 商品码:
	* 使用[聚合数据平台](http://www.juhe.cn/)解析商品
	* API:http://api.juheapi.com/jhbar/bar?appkey=5dde6d0cf313b93ba47798b6ad4b910f&pkg=cn.edu.hhuc&cityid=1&barcode=6950574780188
	* 解析得出:
	```Json
		{
			"error_code":0,
			"reason":"请求成功！",
			"result":
				{
					"summary":{
						"barcode":"6950574780188",
						"name":"蝶枫抽取式纸巾",
						"imgurl":"",
						"shopNum":0,
						"eshopNum":0,
						"interval":"￥:0.0"
						}
				}
		}
	```
* 人脸:
* 银行卡:
	* 导入SDK：CardIO包

##
![图片1](/Resource/屏幕快照 2015-08-03 00.56.48.jpg)
![图片2](/Resource/屏幕快照 2015-08-03 00.57.55.jpg)
![图片3](/Resource/屏幕快照 2015-08-03 00.58.08.jpg)
