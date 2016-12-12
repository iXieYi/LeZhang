//
//  webViewController.m
//  乐账
//
//  Created by 谢毅 on 16/11/8.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "webViewController.h"
#import "PopupView.h"

//系统版本适配
#define IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO)

@interface webViewController ()<UIWebViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,JSObjcDelegate>

@property (nonatomic,weak) UIWebView *WebView;  //网页加载容器
@property (nonatomic,weak) WKWebView *wkwebview;//网页容器
@property(strong,nonatomic)JSContext *context;  //Js对象上下文
@property (nonatomic, strong)PopupView *popView;//定义语音显示控件

@end

@implementation webViewController{

    UIImage *getImage;//获取的图片


}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI1];
    [self init_iFly];                            //初始化语音控件
    [self loadHtml:@"LZ4/index.html"];           //加载指定网页
//    [self login:@"zhangsan" pwd:@"zhang"];     //用户登录
    [self loadUserInfo];                         //加载用户数据
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //界面消失时，终止语音识别操作
    [_iflyRecognizerView cancel];
    [_iflyRecognizerView setDelegate:nil];
}
#pragma mark 初始化语音识别
-(void)init_iFly{
    //初始化语音识别控件
    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
    _iflyRecognizerView.delegate = self;
}

#pragma mark - 界面设置
-(void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    //设置UIwebview
    CGRect webFrame = CGRectMake(0.0,0.0,375.0,667);
    //webFrame.origin.y+=25;
    UIWebView *WebView = [[UIWebView alloc] initWithFrame:webFrame];
    [WebView setBackgroundColor:[UIColor whiteColor]];//设置背景为白色
//    WebView.layer.cornerRadius = 8;
//    WebView.layer.borderWidth = 1;
     WebView.scalesPageToFit = YES;//适应屏幕大小
//    NSString * strURL = @"http://www.baidu.com";
//    NSURL * url = [NSURL URLWithString:strURL];
//    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    self.WebView = WebView;
    self.WebView.delegate = self;
//    [WebView loadRequest:request];
    [self.view addSubview:WebView];
}
-(void)setupUI1{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    //设置WKWebView偏好配置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;

    //配置Js与iOS交互内容
    /*
     
     WKUserContentController是用于给JS注入对象的，注入对象后，JS端就可以使用。直白点说就是给JS与iOS的交互提供一个通道，以后JS与iOS交互就是通过这个AppModel值识别和传值的，传数据统一通过body传，可以是多种类型，只支持NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull类型
     
     */
    // 通过JS与webview内容交互
    config.userContentController = [[WKUserContentController alloc] init];
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时
    // 我们可以在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
    //注入对象名称
    
    //设置Wkwebview
     CGRect webFrame = CGRectMake(0.0,0.0,375.0,667);
    WKWebView *wkwebview = [[WKWebView alloc] initWithFrame:webFrame configuration:config];
    NSLog(@"%@",config);
    self.wkwebview = wkwebview;
    self.wkwebview.navigationDelegate = self;
    self.wkwebview.UIDelegate = self;
    [self.wkwebview.scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:wkwebview];
}

#pragma mark - WKScriptMessageHandler
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"AppModel"]) {
        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,
        // NSDictionary, and NSNull类型
        NSLog(@"%@", message.body);
        
        //打开相机
        dispatch_async(dispatch_get_main_queue(), ^{
            [self takePhoto];
        });
    }else if ([message.name isEqualToString:@"Video"]){
    
    
        [self callVideo];
    }
}

-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{





}
#pragma mark - 网页加载方法
-(void)loadHtml:(NSString *)urlString{
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:path];
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"pic" ofType:@"html"];
//    NSString *htmlCont = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    [self.WebView loadHTMLString:htmlCont baseURL:baseURL];
    [self.wkwebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString relativeToURL:[[NSBundle mainBundle] bundleURL]]]];
//    [self.WebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString relativeToURL:[[NSBundle mainBundle] bundleURL]]]];

}
#pragma mark - 用户登录请求操作
-(void)login:(NSString *)name pwd:(NSString *)pwd {
    NSString *strUrl = @"http://127.0.0.1/php/login.php";
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //发送post请求
    request.HTTPMethod = @"post";
    //设置请求体
    NSString *body =[NSString stringWithFormat:@"username=%@&password=%@",name,pwd];
    //把字符串换成NData对象
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"连接错误 %@",error);
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200||httpResponse.statusCode==304) {
            //解析数据
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSLog(@"%@",dic);
            if ([dic[@"userId"] intValue]) {
                NSLog(@"登录成功");
                [self saveInfo];
            }else {
                NSLog(@"登录失败");
            }
        }else{
            NSLog(@"服务器内部错误");
        }
    }] resume];
}

//用户登录成功，将账号保存到用户配置中（读取html字符串）
-(void)saveInfo{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"zhangsan" forKey:@"name"];
    [userDefaults setObject:@"zhang" forKey:@"pwd"];
    //立即保存
    [userDefaults synchronize];
}
//界面出现时重新加载（给html字符串传值）
-(void)loadUserInfo{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *name = [userDefaults objectForKey:@"name"];
    NSString *pwd  = [userDefaults objectForKey:@"pwd"];
    NSLog(@"%@-----%@",name,pwd);
}

//获取调iOS
-(void)getImage:(id)parameter{
    NSString *jsonStr = [NSString stringWithFormat:@"%@",parameter];
    NSDictionary *jsParameDic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"js传来的字典");
    for (NSString *key in jsParameDic) {
        NSLog(@"jsParameDic[%@]:%@", key, jsParameDic[key]);
    }
    //打开相机
    dispatch_async(dispatch_get_main_queue(), ^{
        [self takePhoto];
    });
}
//使用UIWebView实现的代理
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 以 JSExport 协议关联 Toyun 的方法
    self.context[@"Toyun"] = self;
    // 打印异常
    self.context.exceptionHandler =
    ^(JSContext *context, JSValue *exceptionValue)
    {
        context.exception = exceptionValue;
        NSLog(@"%@", exceptionValue);
    };

}
//使用WKWebView实现加载完成的代理（不支持javacore框架）
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{

    
    

}
//在HTML中调用js 的Alert时调用
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{



}
//采用数据回调的方式，将ios获取的数据再返回给js
-(void)callCamera{
    NSLog(@"调用照相机实现功能");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self takePhoto];
//    });
    

//    JSValue *picCallback = self.context[@"picCallback"];
//    [picCallback callWithArguments:@[@"拍照"]];
  


}
//调用摄像头
-(void)takePhoto{
    if (IOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"获取图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        //判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //相机
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.allowsEditing = YES;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }];
            [alertController addAction:defaultAction];
        }
        UIAlertAction *defaultAction1 = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //相册
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:defaultAction1];
        //弹出视图，使用的方法
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        UIActionSheet *sheet;
        //判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            sheet = [[UIActionSheet alloc] initWithTitle:@"获取图片" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
        }else{
            sheet  = [[UIActionSheet alloc] initWithTitle:@"获取图片" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册获取", nil];
        }
        [sheet showInView:self.view];
        
    }

}
//图片保存的方法
-(NSString *)saveImage:(UIImage *)currentImage withName:(NSString *)imageName{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 1);//取值0.0~1.0，1为不压缩保存
    NSString *fullpath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:imageName];
    //将图片写入文件
    [imageData writeToFile:fullpath atomically:YES];
    return fullpath;
}
//指定保存到相册的回调方法
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *msg =nil;
    if (error !=NULL) {
        msg=@"保存失败";
    }else{
        msg =@"保存成功";
    }
    NSLog(@"%@",msg);
}

//当从相册里选取一张照片，或者用相机拍照后会自动调用该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //保存至本地
    NSString *path = [[NSString alloc] initWithString:[self saveImage:image withName:@"avatar.jpg"]];
    //保存至系统相册
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    /**
     *  这里是IOS 调 js 其中 picCallback 就是js中的方法 picCallback(),参数是字典
     */
    
    if (IOS8) {
        //手动调用JS代码，参数直接写到()里
        NSString *Js = [NSString stringWithFormat:@"picCallback('%@')",path];
        [self.wkwebview evaluateJavaScript:Js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            NSLog(@"call js alert by native");
        }];
    }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                JSValue *picCallback = self.context[@"picCallback"];
                [picCallback callWithArguments:@[@{@"imagePath":path}]];
            });
    }
    
    
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


//语音回调
-(void)callVideo{
    [_iflyRecognizerView setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    //设置结果的数据格式，json，xml，plain，默认为json
    [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    //启动识别服务
    [_iflyRecognizerView start];
    NSLog(@"正在聆听中.....");
    
//    JSValue *videoCallback = self.context[@"videoCallback"];
//    [videoCallback callWithArguments:@[@"语音识别"]];
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
//    _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text,result];
    dispatch_async(dispatch_get_main_queue(), ^{
        JSValue *videoCallback = self.context[@"videoCallback"];
        [videoCallback callWithArguments:@[result]];
    });
    
    if (IOS8) {
        //手动调用JS代码，参数直接写到()里
        NSString *Js = [NSString stringWithFormat:@"videoCallback('%@')",result];
        [self.wkwebview evaluateJavaScript:Js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            NSLog(@"call js alert by native");
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            JSValue *videoCallback = self.context[@"picCallback"];
            [videoCallback callWithArguments:@[result]];
        });
    }


}

/*识别会话错误返回代理
 @ param error 错误码
 */
- (void)onError:(IFlySpeechError *)error {
    [self.view addSubview:_popView];
    [_popView setText:@"识别结束"];
    NSLog(@"errorCode:%d",[error errorCode]);
}


-(void)demo1{

   // self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 打印异常
    self.context.exceptionHandler =
    ^(JSContext *context, JSValue *exceptionValue)
    {
        context.exception = exceptionValue;
        NSLog(@"%@", exceptionValue);
    };
    // 以 JSExport 协议关联 native 的方法
    self.context[@"native"] = self;
    
    // 以 block 形式关联 JavaScript function
    self.context[@"log"] =
    ^(NSString *str)
    {
        NSLog(@"%@", str);
    };
    
    // 以 block 形式关联 JavaScript function
    self.context[@"Alert"] =
    ^(NSString *str)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"msg from js" message:str delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [alert show];
        });
        
    };




}
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
    
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
