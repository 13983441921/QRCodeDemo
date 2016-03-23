//
//  TOWebViewController+QRCodeHelper.h
//  QRCodeDemo
//
//  Created by 好迪 on 16/3/23.
//  Copyright © 2016年 好迪. All rights reserved.
//

#import <TOWebViewController/TOWebViewController.h>
#import "ADRuntimeClass.h"

@interface TOWebViewController (QRCodeHelper)<UIWebViewDelegate>

@property (nonatomic, strong)NSTimer *timer;

@property (nonatomic, assign)int gesState;

@property (nonatomic, strong)NSString *imgURL;

@end
