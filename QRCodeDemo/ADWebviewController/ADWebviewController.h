//
//  ADWebviewController.h
//  QRCodeDemo
//
//  Created by 好迪 on 16/3/22.
//  Copyright © 2016年 好迪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADWebviewController : UIViewController<UIWebViewDelegate,UIActionSheetDelegate>

@property (nonatomic,readonly)  UIWebView *webView;

@end
