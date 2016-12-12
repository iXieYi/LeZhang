//
//  UI_ViewController.m
//  乐账
//
//  Created by 谢毅 on 16/11/7.
//  Copyright © 2016年 xieyi. All rights reserved.
//带UI显示的识别

#import "UI_ViewController.h"
#import "UIPlaceHolderTextView.h"
#import "PopupView.h"
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

@interface UI_ViewController ()

@property (nonatomic, weak)UILabel *text;

@end

@implementation UI_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self init_iFly];
}
//初始化语音识别
-(void)init_iFly{
    //初始化语音识别控件
    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
    _iflyRecognizerView.delegate = self;
}
-(void)setupUI{
    //系统兼容性
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER) {
        //因为一般为了不让View不延伸到navigationBar下面，属性设置为UIRectEdgeNone
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance =NO;
        //no，则状态栏及导航栏不为透明的，界面上的组件就是紧挨着导航栏显示了
        self.navigationController.navigationBar.translucent =NO;
    }
#endif
    self.navigationItem.title = @"乐账";
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat Margin = 5;
    //设置显示框
    UIPlaceHolderTextView *resultView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(Margin*2, Margin*2, self.view.frame.size.width-4*Margin, 300)];
    resultView.layer.cornerRadius = 8;
    resultView.layer.borderWidth = 1;//设置边框粗细
    resultView.font = [UIFont systemFontOfSize:18.0f];
    resultView.placeholder = @"亲，你将要输入的内容";
    //    resultView.placeholderColor = [UIColor brownColor];
    resultView.editable = YES;
    [self.view addSubview:resultView];
    
    _textView  = resultView;
    
    //设置按键
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(Margin*2, CGRectGetMaxY(resultView.frame)+2*Margin, self.view.frame.size.width-Margin*4, 50);
    [button setTitle:@"开始识别" forState:UIControlStateNormal];
    [button setTitle:@"开始识别" forState:UIControlStateSelected];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    [button addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font  = [UIFont systemFontOfSize:20];
    [self.view addSubview:button];
    
    _popView =[[PopupView alloc] initWithFrame:CGRectMake(100, 300, 0, 0)];
    _popView.ParentView = self.view;
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 200,[UIScreen mainScreen].bounds.size.width, 30)];
//    NSString *tmp  = [[UIDevice currentDevice] systemVersion];
    text.text =@"";
    text.textAlignment = NSTextAlignmentCenter;
    self.text = text;
    [self.view addSubview: text];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //界面消失时，终止识别
    [_iflyRecognizerView cancel];
    [_iflyRecognizerView setDelegate:nil];//取消代理
}
//按键响应函数
-(void)start{
    [_iflyRecognizerView setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    //设置结果的数据格式，json，xml，plain，默认为json
    [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    //启动识别服务
    [_iflyRecognizerView start];
    NSLog(@"正在聆听中.....");
    
}
/*识别结果返回代理
 @param resultArray 识别结果
 @ param isLast 表示是否最后一次结果
 */
- (void)onResult: (NSArray *)resultArray isLast:(BOOL) isLast {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dict = [resultArray objectAtIndex:0];
    for (NSString *key in dict) {
        [result appendString:key];
    }
    _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text,result];
}

/*识别会话错误返回代理
 @ param error 错误码
 */
- (void)onError:(IFlySpeechError *)error {
    [self.view addSubview:_popView];
    [_popView setText:@"识别结束"];
    NSLog(@"errorCode:%d",[error errorCode]);
}
@end
