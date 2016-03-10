//
//  AVDeviceQRController.m
//  QRCodeDemo
//
//  Created by 好迪 on 16/3/10.
//  Copyright © 2016年 好迪. All rights reserved.
//

#import "AVDeviceQRController.h"

#import <AVFoundation/AVFoundation.h>

@interface AVDeviceQRController ()

@property (nonatomic , strong)AVCaptureDevice *captureDevice;
@property (nonatomic , strong)AVCaptureSession *captureSession;
@property (nonatomic , strong)AVCaptureInput *captureInput;
@property (nonatomic , strong)AVCaptureMetadataOutput *captureMetadataOutput;

@end

@implementation AVDeviceQRController


- (void)viewDidLoad{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

#pragma mark -
@end
