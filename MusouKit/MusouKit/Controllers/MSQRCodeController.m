//
//  QRCodeController.m
//  Demo
//
//  Created by danal on 7/7/15.
//  Copyright (c) 2015 danal. All rights reserved.
//

#import "MSQRCodeController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@interface MSQRCodeController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@end

@implementation MSQRCodeController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupCamera];
    [self scan];
}

- (void)setupCamera{
    @try {
        
        // Device
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // Input
        AVCaptureDeviceInput *_input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        
        // Output
        AVCaptureMetadataOutput *_output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // Session
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:_input]){
            [_session addInput:_input];
        }
        
        if ([_session canAddOutput:_output]){
            [_session addOutput:_output];
        }
        
        // 条码类型 AVMetadataObjectTypeQRCode
        _output.metadataObjectTypes = @[AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode] ;
        
        // Preview
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _preview.frame = self.view.bounds;
        [self.view.layer insertSublayer:_preview atIndex:0];
        
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:exception.description delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
    //Overlay
    if (_overlay == nil){
        MSQRCodeOverlay *overlay = [[MSQRCodeOverlay alloc] initWithFrame:self.view.bounds];
        [overlay.cancelButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:overlay];
        _overlay = overlay;
    }
    [self.view addSubview:_overlay];
    _overlay.translatesAutoresizingMaskIntoConstraints = YES;
    _overlay.frame = self.view.bounds;
    
}

- (void)scan{
    [_session startRunning];
}

- (void)stop{
    [_session stopRunning];
}

- (void)onCancel{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (![_session isRunning]){
        [_session startRunning];
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
#ifdef DEBUG
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scan result" message:metadataObject.stringValue delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
#endif
        if(_onScanComplete) _onScanComplete(metadataObject.stringValue, self);
    }
    [_session stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGColorSpaceRelease(cs);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *ret = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return ret;
}

#pragma mark - QRCode image

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

+ (UIImage *)createQRCodeImage:(NSString *)qrString{
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // Send the image back
    CIImage *qrcodeImage = qrFilter.outputImage;

    UIImage *image = [self createNonInterpolatedUIImageFormCIImage:qrcodeImage withSize:200.f];
    return image;
    //return [vc imageBlackToTransparent:image withRed:60.0f andGreen:74.0f andBlue:89.0f];
    
}

+ (NSString *)parseQRCodeImage:(UIImage *)qrcodeImage{
    @try {
        
        CIImage *img = qrcodeImage.CIImage;
        //img = [CIImage imageWithContentsOfURL:url]

        if (img){
            CIDetector *d = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                               context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}]
                                               options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
            NSArray *features = [d featuresInImage:img];
            for (CIFeature *f in features){
                
                if ([f isKindOfClass:[CIQRCodeFeature class]]){
                    return [(CIQRCodeFeature *)f messageString];
                    break;
                }
            }
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"当前系统不支持此功能" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    return nil;
}

+ (NSString *)parseAction:(NSString *)string{
    NSRange range = [string rangeOfString:@"_"];
    return range.length > 0 ? [string substringFromIndex:range.location+1] : string;
}

+ (NSString *)parseValue:(NSString *)string{
    NSRange range = [string rangeOfString:@"_"];
    return range.length > 0 ? [string substringToIndex:range.location] : string;
}

@end


@implementation MSQRCodeOverlay

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        if (!_cancelButton){
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelButton.showsTouchWhenHighlighted = YES;
            [cancelButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
            CGFloat w = 80.f, h = 30.f;
            cancelButton.frame = CGRectMake((self.bounds.size.width-w)/2, (self.bounds.size.height-h-20.f), w, h);
            [self addSubview:cancelButton];
            _cancelButton = cancelButton;
        }
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGFloat boxSize = 240.f;
    CGRect box = CGRectMake((rect.size.width-boxSize)/2, (rect.size.height-boxSize)/2, boxSize, boxSize);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(c, kCGLineCapRound);
    CGFloat ox = box.origin.x, oy = box.origin.y, w = 30.f;
    [[UIColor whiteColor] setStroke];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //lt
    [path moveToPoint:CGPointMake(ox, oy+w)];
    [path addLineToPoint:CGPointMake(ox, oy)];
    [path addLineToPoint:CGPointMake(ox+w, oy)];
    //rt
    [path moveToPoint:CGPointMake(ox+boxSize-w, oy)];
    [path addLineToPoint:CGPointMake(ox+boxSize, oy)];
    [path addLineToPoint:CGPointMake(ox+boxSize, oy+w)];
    //rb
    [path moveToPoint:CGPointMake(ox+boxSize, oy+boxSize-w)];
    [path addLineToPoint:CGPointMake(ox+boxSize, oy+boxSize)];
    [path addLineToPoint:CGPointMake(ox+boxSize-w, oy+boxSize)];
    //lb
    [path moveToPoint:CGPointMake(ox+w, oy+boxSize)];
    [path addLineToPoint:CGPointMake(ox, oy+boxSize)];
    [path addLineToPoint:CGPointMake(ox, oy+boxSize-w)];
    
    CGContextAddPath(c, path.CGPath);
    CGContextStrokePath(c);
    
}

@end
