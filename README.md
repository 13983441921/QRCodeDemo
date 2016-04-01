# iOS QRcode识别及相册图片二维码读取识别

最近碰到一个用户 在使用我们 [微链App](https://itunes.apple.com/hk/app/wei-lian-chuang-ye-she-jiao/id944154493?l=zh&mt=8) 的时候，在分辨率低或者频率低的显示器上扫不出二维码。然后网上找了很多，试了很多，还是没有找出合适的方法，想想把三种扫描（系统原生API，ZBar，ZXing）写个Demo，做个小总结，看看从什么地方可以找到解决方法，也希望各位大神能给我指条明路😄。

对二维码的处理及系统原生API扫描、 Zbar扫描和Zing扫描 比较

## iOS原生API
系统扫描的效率是最高，反正包括各种你见过的没见过的码，但是有一点我不是很清楚 iOS7 扫描二维码可以，但从相册照片读取二维码苹果不支持，必须是iOS8+。
<https://github.com/yannickl/QRCodeReaderViewController>
<https://github.com/zhengjinghua/MQRCodeReaderViewController>

这两个例子已经写的非常清楚了

```
// 对于识别率的精度 就是屏幕有波浪一样
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
   // 改成了 降低采集频率
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
```
不知道 有什么好的方法

## ZXing 和 ZBar
具体代码 我就不在这里写了，Demo里 都写了，而且百度谷歌千篇一律，说说ZXing的一些用到的特点：

* 对那种小圆点的二维码 ZXing和原生API 都是支持的，而ZBar 貌似不是支持的，反正我没搞定。
* ZBar 现在还在继续维护 ZBar 而已经停止了
* ZXing 可以识别图片中多个二维码

ZBar中的识别率 本人觉得还是比较低

```
//ZBar 中对 图片中二维码 识别
	UIImage * aImage = #所获取的图片#
	ZBarReaderController *read = [ZBarReaderController new];
    CGImageRef cgImageRef = aImage.CGImage;
    ZBarSymbol* symbol = nil;
    for(symbol in [read scanImage:cgImageRef]){
        qrResult = symbol.data ;
        NSLog(@"qrResult = symbol.data %@",qrResult);
    }
```

ZXing 对圆点二维码的支持 及能够识别图片中多个二维码

```
	// ZXing 只识别单个二维码
	UIImage *image = #需要识别的图片# 
	ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage]; 
   ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource: source];
    ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
    
    NSError *error;
    
    id<ZXReader> reader;   
    if (NSClassFromString(@"ZXMultiFormatReader")) {
        reader = [NSClassFromString(@"ZXMultiFormatReader") performSelector:@selector(reader)];
    }
    ZXDecodeHints *_hints = [ZXDecodeHints hints];
    ZXResult *result = [reader decode:bitmap hints:_hints error:&error];
    if (result == nil) {
        NSLog(@"无QRCode");
        return;
    }
    NSLog(@"QRCode = %d，%@"，result.barcodeFormat，result.text);

```
ZXing 识别图片中多个二维码

```
	UIImage *image = #需要识别的图片# 
	ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage]; 
   ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource: source];
   ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
   ZXDecodeHints *hints = [ZXDecodeHints hints];

    NSError *error = nil;
    ZXQRCodeMultiReader * reader2 = [[ZXQRCodeMultiReader alloc]init];
    NSArray *rs = [reader2 decodeMultiple:bitmap error:&error];
    // 或者  NSArray *rs =[reader2 decodeMultiple:bitmap hints:hints error:&error];
    NSLog(@" err = %@",error);
    for (ZXResult *resul in rs) {
        NSLog(@" ---%@",resul.text);
    }
```
后面 就看你需求了

## iOS WebView中 长按二维码的识别
思路: 

1. 长按webView 的过程中 截屏，再去解析是否有二维码，但是有个缺点 就是 万一截了一个 一半的二维码 那就无解了。
2. 在webview中 注入获取点击图片的JS 获取图片，再解析。缺点：万一图片过大 需要下载，势必会影响用户体验。
3. webview 加载完成图片之后，图片势必缓存在 webview里，有什么方法可以获取webview 里的缓存图片。
 
本人目前用的是 第二种方式。求大神教我第三种...
我在[TOWebViewController](https://github.com/TimOliver/TOWebViewController) 做了类扩展

```
//要注入的 js 代码
static NSString* const kTouchJavaScriptString=
@"document.ontouchstart=function(event){\
x=event.targetTouches[0].clientX;\
y=event.targetTouches[0].clientY;\
document.location=\"myweb:touch:start:\"+x+\":\"+y;};\
document.ontouchmove=function(event){\
x=event.targetTouches[0].clientX;\
y=event.targetTouches[0].clientY;\
document.location=\"myweb:touch:move:\"+x+\":\"+y;};\
document.ontouchcancel=function(event){\
document.location=\"myweb:touch:cancel\";};\
document.ontouchend=function(event){\
document.location=\"myweb:touch:end\";};";
```

```
//部分核心代码 
- (BOOL)ad_webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0]
                                   isEqualToString:@"myweb"]) {
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"touch"])
        {
            if ([(NSString *)[components objectAtIndex:2] isEqualToString:@"start"])
            {
                self.gesState = GESTURE_STATE_START;
                NSLog(@"touch start!");
                
                float ptX = [[components objectAtIndex:3]floatValue];
                float ptY = [[components objectAtIndex:4]floatValue];
                NSLog(@"touch point (%f, %f)", ptX, ptY);
                
                NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", ptX, ptY];
                NSString * tagName = [self.webView stringByEvaluatingJavaScriptFromString:js];
                self.imgURL = nil;
                if ([tagName isEqualToString:@"IMG"]) {
                    self.imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", ptX, ptY];
                }
                if (self.imgURL) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:longGestureInterval target:self selector:@selector(handleLongTouch) userInfo:nil repeats:NO];
                }
            }
            else if ([(NSString *)[components objectAtIndex:2] isEqualToString:@"move"])
            {
                self.gesState = GESTURE_STATE_MOVE;
                NSLog(@"you are move");
            }
            
        }
        
        if ([(NSString*)[components objectAtIndex:2]isEqualToString:@"end"]) {
            [self.timer invalidate];
            self.timer = nil;
            self.gesState = GESTURE_STATE_END;
            NSLog(@"touch end");
        }
        
        if (self.imgURL && self.gesState == GESTURE_STATE_END) {
            NSLog(@"点的是图片");
        }
        
        return NO;
    }
//    return YES;
    return [self ad_webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}
```

```
- (void)ad_webViewDidFinishLoad:(UIWebView *)webView{
    //控制缓存
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];

    // 响应touch事件，以及获得点击的坐标位置，用于保存图片
    [webView stringByEvaluatingJavaScriptFromString:kTouchJavaScriptString];
    
    [self ad_webViewDidFinishLoad:webView];
}
```
基本就可以了。

* 终于找到取 webView 缓存的图片的方法了。 用的是 NSURLProtocol 方式，在github上找了一个 [RNCachingURLProtocol](https://github.com/rnapier/RNCachingURLProtocol),基本原理是：webView 在处理请求的过程中会调用

```
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response

```
 URLProtocol 把webView请求返回来的 data 用压缩的方式的存储在 cache的文件夹下, 发出请求的时候会先去读取缓存。本人对 RNCachingURLProtocol 做过修改 具体请看Demo

* 转载请注明 作者：好迪 [文章地址](http://ihaodi.net/2016/03/21/iOS-QRcode%E8%AF%86%E5%88%AB%E5%8F%8A%E7%9B%B8%E5%86%8C%E5%9B%BE%E7%89%87%E4%BA%8C%E7%BB%B4%E7%A0%81%E8%AF%86%E5%88%AB/)
* 水平有限 欢迎批评指正评论

## Demo地址
<https://github.com/cuiwe000/QRCodeDemo.git>

## 参考文档
* <http://blog.cnbluebox.com/blog/2014/08/26/ioser-wei-ma-sao-miao/>
* <https://github.com/MxABC/LBXScan> 这个很全
* [Apple CSS](https://developer.apple.com/library/safari/documentation/AppleApplications/Reference/SafariCSSRef/Articles/StandardCSSProperties.html#/apple_ref/doc/uid/TP30001266-SW1)
* <http://my.oschina.net/hmj/blog/111344>
* [stackoverflow](http://stackoverflow.com/questions/5995210/disabling-user-selection-in-uiwebview)
* [CSS 参考](https://developer.mozilla.org/en-US/docs/CSS/:not)
* <http://robnapier.net/offline-uiwebview-nsurlprotocol>
