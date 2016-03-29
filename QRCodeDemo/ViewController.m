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
        cell.textLabel.text = @"ZBar 官方说明 这里不再举例";
    }
    else if (indexPath.row == 3){
        cell.textLabel.text = @"在网页中识别二维码及图片缓存处理";
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
        TOWebViewController *qrweb = [[TOWebViewController alloc]initWithURLString:@"https://mp.weixin.qq.com/s?__biz=MzAxNzI0NTQ4Nw==&mid=403200626&idx=1&sn=287682f40afaa5072d2bd0f76dc97746&scene=1&srcid=0223hbfL6h2ExWv5MrrYC5F8&key=710a5d99946419d912c9eecdcdedc802bf3e90d0c5fc57d257877fd67805f873d5d10784a2196a8af03e46fb958d69a1&ascene=0&uin=MTgyNTM1NDc1&devicetype=iMac+MacBookPro12%2C1+OSX+OSX+10.11.4+build(15E65)&version=11020201&pass_ticket=OEtu0yPL5hn25zQEjbXcS%2FK9aXuhLRSHyA4DyjBwwnI%3D"];
//        TOWebViewController *qrweb = [[TOWebViewController alloc]initWithURLString:@"https://baidu.com"];
        qrweb.navigationButtonsHidden = YES;
        [self.navigationController pushViewController:qrweb animated:YES];
    }

}





@end
