//
//  AVDeviceQRController.m
//  QRCodeDemo
//
//  Created by 好迪 on 16/3/10.
//  Copyright © 2016年 好迪. All rights reserved.
//

#import "AVDeviceQRController.h"
#import "QRScanView.h"

#import <AVFoundation/AVFoundation.h>


@interface AVDeviceQRController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic , strong)AVCaptureDevice *captureDevice;
@property (nonatomic , strong)AVCaptureSession *captureSession;
@property (nonatomic , strong)AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic , strong)AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic , strong)AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic , strong)AVCaptureConnection *captureConnect;

/**
 *  @author Haodi, 16-03-10 16:03:57
 *
 *  扫描区域
 */
@property (nonatomic, assign) CGRect scanRect;

@property (nonatomic, assign) BOOL isQRCodeCaptured;

@end

@implementation AVDeviceQRController

- (void)dealloc{
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.scanRect = CGRectMake(60.0f, 100.0f, 200.0f, 200.0f);
    self.view.backgroundColor = [UIColor blackColor];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self requestAuthCamera];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self stopCapture];
}

#pragma mark -
// 请求相机权限
- (void)requestAuthCamera{
    __weak typeof(self)weakSelf = self;
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    [weakSelf configDeviceQR];
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:
            NSLog(@"已授权");
            [self configDeviceQR];
            break;
        case AVAuthorizationStatusRestricted:
            NSLog(@"受限，有可能开启了访问限制");
        case AVAuthorizationStatusDenied:
            NSLog(@"访问受限");
            [self loadNoAuthCameraView];
            break;
        default:
            break;
    }
    
}

- (void)configDeviceQR{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
        if (error == nil) {
            if ([self.captureSession canAddInput:deviceInput]) {
                [self.captureSession  addInput:deviceInput];
            }
            
            if ([self.captureSession canAddOutput:self.captureMetadataOutput]) {
                // 这行代码要在设置 metadataObjectTypes 前
                [self.captureSession addOutput:self.captureMetadataOutput];
            }
            self.captureMetadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
            //    self.captureOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
            
            _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
            _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _previewLayer.frame = self.view.frame;
            [self.view.layer insertSublayer:_previewLayer atIndex:0];
            
            __weak typeof(self) weakSelf = self;
            [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                              object:nil
                                                               queue:[NSOperationQueue currentQueue]
                                                          usingBlock: ^(NSNotification *_Nonnull note) {
                                                              weakSelf.captureMetadataOutput.rectOfInterest = [_previewLayer metadataOutputRectOfInterestForRect:weakSelf.scanRect]; // 如果不设置，整个屏幕都可以扫
                                                              //!!!!!!!!!! 与直接设置的区别 还未发现有啥区别
                                                          }];
            
            
            AVCaptureStillImageOutput *img =  [self.captureSession.outputs objectAtIndex:0];
            _captureConnect =[img connectionWithMediaType:AVMediaTypeVideo];
            
            QRScanView *scanView = [[QRScanView alloc] initWithScanRect:self.scanRect];
            [self.view addSubview:scanView];
            
            [self startCapture];
            
        }
        else {
            NSLog(@"err = %@",error);
        }
    });
}

- (void)startCapture{
    self.isQRCodeCaptured = NO;
    [self.captureSession startRunning];
}

- (void)stopCapture{
    [self.captureSession stopRunning];
}

- (void)loadNoAuthCameraView{
    NSString *cameraTitle = [NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机”选项中，允许【%@】访问您的相机",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    [self showAlertViewWithMessage:cameraTitle];
}

- (void)removeCapture{
    [self stopCapture];
    
}

#pragma mark - Private Methods

- (void)showAlertViewWithMessage:(NSString *)message {
    NSLog(@"%@", message);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    alertView.delegate = self;
    [alertView show];
}

#pragma mark -
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode] && !self.isQRCodeCaptured) {
        self.isQRCodeCaptured = YES;
        [self stopCapture];
        [self showAlertViewWithMessage:metadataObject.stringValue];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

#pragma mark -
-(AVCaptureDevice *)captureDevice{
    if (_captureDevice == nil) {
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
//        NSError *error;
//        if (_captureDevice.isAutoFocusRangeRestrictionSupported)
//        {
//            if ([_captureDevice lockForConfiguration:&error])
//            {
//                [_captureDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
//                [_captureDevice unlockForConfiguration];
//            }
//        }
    }
    return _captureDevice;
}

-(AVCaptureSession *)captureSession{
    if (_captureSession == nil) {
        _captureSession = [[AVCaptureSession alloc] init];
//        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;

        
        [_captureSession setSessionPreset:AVCaptureSessionPresetInputPriority];
    }
    return _captureSession;
}

- (AVCaptureMetadataOutput *)captureMetadataOutput
{
    if (_captureMetadataOutput == nil) {
        _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _captureMetadataOutput;
}
@end
