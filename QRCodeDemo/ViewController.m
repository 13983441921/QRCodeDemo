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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIndentify"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"系统原生API";
    }
    else if (indexPath.row == 1){
        cell.textLabel.text = @"ZXing";
        
    }
    else{
        cell.textLabel.text = @"ZBar";
        
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
    else{
        ZBarQRContrller *zbarQR = [[ZBarQRContrller alloc]init];
        [self.navigationController pushViewController:zbarQR animated:YES];
    }

}





@end
