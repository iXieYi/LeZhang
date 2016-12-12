//
//  DUI_ViewController.m
//  乐账
//
//  Created by 谢毅 on 16/11/7.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "DUI_ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "Definition.h"
#import "iflyMSC/IFlyUserWords.h"
#import "RecognizerFactory.h"
#import "UIPlaceHolderTextView.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "PopupView.h"
#import "ISRDataHelper.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyResourceUtil.h"
#import "iflyMSC/IFlySpeechError.h"

@interface DUI_ViewController ()

@property (nonatomic, weak)UIButton *startBtn;
@property (nonatomic, weak)UIButton *stopBtn;
@property (nonatomic, weak)UIButton *cancelBtn;
@property (nonatomic) BOOL isCanceled;
@property (nonatomic, strong) PopupView *popUpView;
@property (nonatomic, weak) UITextView  * resultView;
@property (nonatomic, strong) NSString * result;

@end

@implementation DUI_ViewController


-(void)viewWillDisappear:(BOOL)animated
{
    //取消识别
    [_iFlySpeechRecognizer cancel];
    [_iFlySpeechRecognizer setDelegate: nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupUI{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif

    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    UIView *mainView = [[UIView alloc] initWithFrame:frame];
    mainView.backgroundColor = [UIColor whiteColor];
    self.view = mainView;
    int top = Margin*2;
    //听写
    self.title = @"语音听写";
    
    UIPlaceHolderTextView *resultView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(Margin*2, top, self.view.frame.size.width-Margin*4, 160)];
    resultView.layer.cornerRadius = 8;
    resultView.layer.borderWidth = 1;
    [self.view addSubview:resultView];
    resultView.font = [UIFont systemFontOfSize:17.0f];
    resultView.placeholder = @"识别结果";
    [self.view addSubview:resultView];
    self.resultView = resultView;

    //识别控制按钮
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startBtn setTitle:@"开始识别" forState:UIControlStateNormal];
    startBtn.frame = CGRectMake(Padding, resultView.frame.origin.y + resultView.frame.size.height + Margin, (self.view.frame.size.width-Padding*4)/3, ButtonHeight);
    [self.view addSubview:startBtn];
    [startBtn addTarget:self action:@selector(onBtnStart:) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn = startBtn;

    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    stopBtn.frame = CGRectMake(startBtn.frame.origin.x+ Padding + startBtn.frame.size.width, startBtn.frame.origin.y, (self.view.frame.size.width-Padding*4)/3, ButtonHeight);
    [self.view addSubview:stopBtn];
    self.stopBtn = stopBtn;
    [stopBtn addTarget:self action:@selector(onBtnStop:) forControlEvents:UIControlEventTouchUpInside];
    [_stopBtn setEnabled:NO];

    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(stopBtn.frame.origin.x+ Padding + stopBtn.frame.size.width, stopBtn.frame.origin.y, stopBtn.frame.size.width, stopBtn.frame.size.height);
    [self.view addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(onBtnCancel:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn = cancelBtn;
    [_cancelBtn setEnabled:NO];

    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 100, 0, 0)];
    _popUpView.ParentView = self.view;
}
//开始录音
- (void) onBtnStart:(id) sender
{
    [_resultView setText:@""];
    [_resultView resignFirstResponder];
    
    self.isCanceled = NO;
    
    //设置为录音模式
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    bool ret = [_iFlySpeechRecognizer startListening];
    
    if (ret) {
        
        [_startBtn setEnabled:NO];
        [_cancelBtn setEnabled:YES];
        [_stopBtn setEnabled:YES];
    }
    else
    {
        [_popUpView setText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
        [self.view addSubview:_popUpView];
    }
    
}


/*
 * @ 暂停录音
 */
- (void) onBtnStop:(id) sender
{
    [_iFlySpeechRecognizer stopListening];
    
    [_resultView resignFirstResponder];
}

/*
 * @取消识别
 */
- (void) onBtnCancel:(id) sender
{
    self.isCanceled = YES;
    
    [_iFlySpeechRecognizer cancel];
    
    [_popUpView removeFromSuperview];
    [_resultView resignFirstResponder];
}


/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        
        [_popUpView removeFromSuperview];
        
        return;
    }
    
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    
    [_popUpView setText: vol];
    
    [self.view addSubview:_popUpView];
}

/**
 * @fn      onBeginOfSpeech
 * @brief   开始识别回调
 *
 * @see
 */
- (void) onBeginOfSpeech
{
    NSLog(@"onBeginOfSpeech");
    
    [_popUpView setText: @"正在录音"];
    
    [self.view addSubview:_popUpView];
    
    _stopBtn.enabled = YES;
    _cancelBtn.enabled  = YES;
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
    
    [_popUpView setText: @"停止录音"];
    [self.view addSubview:_popUpView];
}

/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void) onError:(IFlySpeechError *) error
{
    NSString *text ;
    
    if (error.errorCode ==0 ) {
        NSLog(@"%@",self.result);
        if (_result.length==0) {
            
            text = @"无识别结果";
        }
        else
        {
            text = @"识别成功";
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        
        NSLog(@"%@",text);
    }
    
    [_popUpView setText: text];
    
    [self.view addSubview:_popUpView];
    
    [_stopBtn setEnabled:NO];
    [_cancelBtn setEnabled:NO];
    [_startBtn setEnabled:YES];
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result  -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    NSLog(@"听写结果：%@",resultString);
    
    self.result =[NSString stringWithFormat:@"%@%@", _resultView.text,resultString];
    
    NSString * resultFromJson =  [[ISRDataHelper shareInstance] getResultFromJson:resultString];
    
    _resultView.text = [NSString stringWithFormat:@"%@%@", _resultView.text,resultFromJson];
    
    if (isLast)
    {
        NSLog(@"听写结果(json)：%@测试",  self.result);
    }
    
    NSLog(@"isLast=%d",isLast);
}

@end
