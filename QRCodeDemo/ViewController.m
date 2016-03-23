//
//  ViewController.m
//  QRCodeDemo
//
//  Created by 好迪 on 16/3/10.
//  Copyright © 2016年 好迪. All rights reserved.
//

#import "ViewController.h"

//#import "AVDeviceQRController.h"

#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"

#import "ZXingQRController.h"
#import "ZBarQRContrller.h"

#import "ADWebviewController.h"
#import "TOWebViewController+QRCodeHelper.h"
#import <TOWebViewController/TOWebViewController.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描二维码";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellIndentify"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIndentify"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"系统原生API";
    }
    else if (indexPath.row == 1){
        cell.textLabel.text = @"ZXing";
        
    }
    else if (indexPath.row == 2){
        cell.textLabel.text = @"ZBar";
    }
    else if (indexPath.row == 3){
        cell.textLabel.text = @"在网页中识别二维码";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
//        AVDeviceQRController *avQR = [[AVDeviceQRController alloc]init];
        if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
            
            QRCodeReaderViewController *reader = [QRCodeReaderViewController new];
            [reader setCompletionWithBlock:^(NSString *resultAsString) {
                NSLog(@"Completion with result: %@", resultAsString);
            }];
            
            [self.navigationController pushViewController:reader animated:YES];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
    }
    else if (indexPath.row == 1){
        ZXingQRController *zxingQR = [[ZXingQRController alloc] init];
        [self.navigationController pushViewController:zxingQR animated:YES];
    }
    else if (indexPath.row == 2){
        ZBarQRContrller *zbarQR = [[ZBarQRContrller alloc]init];
        [self.navigationController pushViewController:zbarQR animated:YES];
    }
    else{
//        ADWebviewController *zxingQR = [[ADWebviewController alloc] init];
        TOWebViewController *qrweb = [[TOWebViewController alloc]initWithURLString:@"http://mp.weixin.qq.com/s?__biz=MjM5MjkwMjE3MQ==&mid=402966468&idx=1&sn=95205419dfe233b440382a867ff19696&scene=2&srcid=0322xf25lmMsHjAH8k3sV3Jc&from=timeline&isappinstalled=0#wechat_redirect"];
        qrweb.navigationButtonsHidden = YES;
        [self.navigationController pushViewController:qrweb animated:YES];
    }

}





@end
