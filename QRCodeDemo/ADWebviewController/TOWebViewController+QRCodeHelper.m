//
//  TOWebViewController+QRCodeHelper.m
//  QRCodeDemo
//
//  Created by 好迪 on 16/3/23.
//  Copyright © 2016年 好迪. All rights reserved.
//

#import "TOWebViewController+QRCodeHelper.h"
#import <objc/runtime.h>

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

static NSString *const kGestrueState     = @"keyForGestrueState";
static NSString *const kImageUrl         = @"keyForImageUrl";
static NSString *const kLongGestureTimer = @"keyForLongGestureTimer";

static const NSTimeInterval longGestureInterval = 1.0f;

enum
{
    GESTURE_STATE_NONE = 0,
    GESTURE_STATE_START = 1,
    GESTURE_STATE_MOVE = 2,
    GESTURE_STATE_END = 4,
    GESTURE_STATE_ACTION = (GESTURE_STATE_START | GESTURE_STATE_END),
};


@implementation TOWebViewController (QRCodeHelper)

// why 会加载load
+(void)load{
    [super load];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self towebviewHook];
    });
}

+ (void)towebviewHook{
    ADSwizzlingMethod([self class], @selector(webView:shouldStartLoadWithRequest:navigationType:), @selector(ad_webView:shouldStartLoadWithRequest:navigationType:));
    ADSwizzlingMethod([self class], @selector(webViewDidFinishLoad:), @selector(ad_webViewDidFinishLoad:));
//    ADSwizzlingMethod([self class], @selector(webViewDidStartLoad:), @selector(ad_webViewDidStartLoad:));
}

#pragma mark - seter and getter
- (void)setGesState:(int)gesState{
    objc_setAssociatedObject(self, &kGestrueState, @(gesState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int)gesState{
    return [objc_getAssociatedObject(self, &kGestrueState) intValue];
}

- (void)setImgURL:(NSString *)imgURL{
    objc_setAssociatedObject(self, &kImageUrl, imgURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)imgURL{
    return objc_getAssociatedObject(self, &kImageUrl);
}

- (void)setTimer:(NSTimer *)timer{
    objc_setAssociatedObject(self, &kLongGestureTimer, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimer *)timer{
    return objc_getAssociatedObject(self, &kLongGestureTimer);
}

#pragma mark - private Method
- (void)handleLongTouch {
    
    NSString *imageUrl = [self.webView stringByEvaluatingJavaScriptFromString:self.imgURL];
    if (imageUrl && self.gesState == GESTURE_STATE_START) {
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage* image = [UIImage imageWithData:data];
        NSLog(@"下载完成====%@", imageUrl);
        
        //用获取的图片 去识别二维码
        self.gesState = GESTURE_STATE_END;
        
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", nil];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

#pragma mark - swizing
- (void)ad_webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

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

- (void)ad_webViewDidStartLoad:(UIWebView *)webView{
    [self ad_webViewDidStartLoad:webView];
}

- (void)ad_webViewDidFinishLoad:(UIWebView *)webView{
    //控制缓存
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];

    // 响应touch事件，以及获得点击的坐标位置，用于保存图片
    [webView stringByEvaluatingJavaScriptFromString:kTouchJavaScriptString];
    
    [self ad_webViewDidFinishLoad:webView];
}

@end
