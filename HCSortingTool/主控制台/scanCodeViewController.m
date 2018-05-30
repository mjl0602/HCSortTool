//
//  scanCodeViewController.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/5/5.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "scanCodeViewController.h"
#import "Masonry.h"
#import "UIColor+OVColor.h"
#import <AVFoundation/AVFoundation.h>

@interface scanCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong,nonatomic)AVCaptureDevice *device;
@property (strong,nonatomic)AVCaptureDeviceInput *input;
@property (strong,nonatomic)AVCaptureMetadataOutput *output;
@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *preview;

@property(nonatomic)UIView *cameraView;
@property(nonatomic)UIButton *button;

@end

@implementation scanCodeViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _cameraView = [UIView new];
    [self.view addSubview:_cameraView];
    _cameraView.transform = CGAffineTransformMakeRotation(3*M_PI_2);
    _cameraView.layer.masksToBounds = YES;
    [_cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(_cameraView.mas_width);
        make.top.offset(0);
    }];
    
    _button = [UIButton buttonWithType:UIButtonTypeSystem];
    _button.tintColor = [UIColor textGrayColor];
    [_button.titleLabel setFont:[UIFont systemFontOfSize:32]];
    _button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_button setTitle:@"将条形码对准红线进行扫描" forState:UIControlStateNormal];
    [self.view addSubview:_button];
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.top.equalTo(_cameraView.mas_bottom);
        make.bottom.offset(0);
    }];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self setupCamera];
}

- (void)setupCamera
{

    self.device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];

    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    // Session
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    // 条码类型
    self.output.metadataObjectTypes =@[AVMetadataObjectTypeCode128Code];
    self.output.rectOfInterest = CGRectMake(0.3, 0.4, 0.42, 0.3);
    
    // Preview
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    self.preview.frame =CGRectMake(0,0,self.cameraView.frame.size.width,self.cameraView.frame.size.height);
    
    [self.cameraView.layer addSublayer:self.preview];
    
    // Start
    [self.session startRunning];
    
    //必须在running之后才会有区域
    UIImageView *target = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"code.png"]];
    target.contentMode = UIViewContentModeScaleAspectFit;
    CGRect oldRect = self.output.rectOfInterest;
    CGRect targetRect = [self.preview rectForMetadataOutputRectOfInterest:oldRect];
    target.frame = targetRect;
    
    NSLog(@"%@,  %@",NSStringFromCGRect(self.output.rectOfInterest),NSStringFromCGRect(target.frame));
    
    [self.cameraView addSubview:target];
    [self.cameraView bringSubviewToFront:target];
    
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if ([metadataObjects count] >0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"扫描二维码:%@",stringValue);
        [_parentVC showMissionWithFlowNumber:stringValue.integerValue];
        
    }];
}

#pragma mark - popver
//重写preferredContentSize，让popover返回你期望的大小
- (CGSize)preferredContentSize {
    return CGSizeMake(460, 500);
}

- (void)setPreferredContentSize:(CGSize)preferredContentSize{
    super.preferredContentSize = preferredContentSize;
}

@end
