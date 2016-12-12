//
//  QRViewController.m
//  乐账
//
//  Created by 谢毅 on 16/11/8.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "QRViewController.h"

#pragma mark - 宏定义
#define SCANVIEW_EdgeTop 40.0
#define SCANVIEW_EdgeLeft 50.0
#define TINTCOLOR_ALPHA 0.2   //浅色透明度
#define DARKCOLOR_ALPHA 0.5   //深色透明度
#define VIEW_WIDTH [UIScreen mainScreen].bounds.size.width
#define VIEW_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface QRViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong)UIButton *Scan;
@property (nonatomic,strong)UILabel *label;

@end

@implementation QRViewController
{
    AVCaptureSession *session;//输入、输出介质
    UIView *AVCapView;        //用于放置扫描框、取消按钮、label的说明
    UIView *QRcodeline;       //此View是上下移动的绿色调
    NSTimer *timer;           //定时器
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
-(void)setupUI{

    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UIView *ScanView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIButton *Scan = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [Scan setBackgroundImage:[UIImage imageNamed:@"Scan"] forState:UIControlStateNormal];
    Scan.layer.cornerRadius = 5;
    [Scan addTarget:self action:@selector(ScanClick) forControlEvents:UIControlEventTouchUpInside];
    [ScanView addSubview:Scan];

    //把扫描的按键放到导航栏上去！
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:ScanView];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ScanClick{
//创建一个view来放置扫描区、说明label、取消按钮
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, VIEW_WIDTH, VIEW_HEIGHT)];
    AVCapView = tempView;
    AVCapView.backgroundColor  = [UIColor colorWithRed:54.f/255 green:53.f/255 blue:58.f/255 alpha:0.6];
    CGFloat margin = 20;
    
    //画上边框
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop, VIEW_WIDTH- 2 * SCANVIEW_EdgeLeft, 1)];
    topView.backgroundColor = [UIColor whiteColor];
    [AVCapView addSubview:topView];
    //画左边框
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop , 1,VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft)];
    leftView.backgroundColor = [UIColor whiteColor];
    [AVCapView addSubview:leftView];
    //画右边框
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft + VIEW_WIDTH- 2 * SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop , 1,VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + 1)];
    rightView.backgroundColor = [UIColor whiteColor];
    [AVCapView addSubview:rightView];
    //画下边框
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop + VIEW_WIDTH- 2 * SCANVIEW_EdgeLeft,VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft ,1 )];
    downView.backgroundColor = [UIColor whiteColor];
    [AVCapView addSubview:downView];
    
    //画中间的基准线
     QRcodeline= [[UIView alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft + 1, SCANVIEW_EdgeTop, VIEW_WIDTH- 2 * SCANVIEW_EdgeLeft - 1, 2)];
    QRcodeline.backgroundColor = [UIColor greenColor];
    [AVCapView addSubview:QRcodeline];
    
    //提示标签
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft, CGRectGetMaxY(downView.frame)+margin, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft, 60)];
    label.numberOfLines = 0;
    label.text = @"小提示：将条形码或二维码对准上方区域中心即可";
    label.textColor = [UIColor grayColor];
    [AVCapView addSubview:label];
//    self.label = label;
    //取消按钮
    UIButton *CancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft, CGRectGetMaxY(label.frame)+margin, 50, 25)];
    [CancelBtn setTitle:@"取消" forState: UIControlStateNormal];
    [CancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [CancelBtn addTarget:self action:@selector(touchAVCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [AVCapView addSubview:CancelBtn];
    [self.view addSubview:AVCapView];

     // 先让基准线运动一次，避免定时器的时差
    [UIView animateWithDuration:1.2 animations:^{
        QRcodeline.frame = CGRectMake(SCANVIEW_EdgeLeft + 1, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop , VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft - 1, 2);
    }];
    //设置定时器
    [self performSelector:@selector(createTimer) withObject:nil afterDelay:0.4];
    //设置扫描方法
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [session addInput:input];
    [session addOutput:output];
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame = CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop, VIEW_WIDTH- 2 * SCANVIEW_EdgeLeft, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft);
    [AVCapView.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [session startRunning];
}

#pragma mark - 实现定时器、还有基准线的滚动方法
- (void)createTimer
{
    timer=[NSTimer scheduledTimerWithTimeInterval:1.1 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if ([timer isValid] == YES) {
        [timer invalidate];
        timer = nil;
    }
    
}

// 横线上下滚动
- (void)moveUpAndDownLine
{
    CGFloat YY = QRcodeline.frame.origin.y;
    if (YY != VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop ) {
        [UIView animateWithDuration:1.2 animations:^{
            QRcodeline.frame = CGRectMake(SCANVIEW_EdgeLeft + 1, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop , VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft - 1,2);
        }];
    }else {
        [UIView animateWithDuration:1.2 animations:^{
            QRcodeline.frame = CGRectMake(SCANVIEW_EdgeLeft + 1, SCANVIEW_EdgeTop, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft - 1,2);
        }];
        
    }
}
#pragma mark - 扫描成功后，想干嘛干嘛，就在这个代理方法里面实现就行了
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        NSLog(@"%@",metadataObject.stringValue);
        self.navigationItem.title = metadataObject.stringValue;
        [session stopRunning];
        [self stopTimer];
        [AVCapView removeFromSuperview];
        
    }
}

#pragma mark - 如果用户不想扫描了，点击取消按钮
- (void)touchAVCancelBtn{
    [session stopRunning];//摄像也要停止
    [self stopTimer];//定时器要停止
    [AVCapView removeFromSuperview];//刚刚创建的 view 要移除
    
}
/*
#
 pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before n avigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
