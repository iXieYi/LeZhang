//
//  PicViewController.m
//  乐账
//
//  Created by 谢毅 on 16/11/15.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "PicViewController.h"
#import "NetworkTools.h"
#define IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO)
@interface PicViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,weak)UIImageView *imageView;
@property(nonatomic,weak)UIImageView *imageViewR;
@property(nonatomic,strong) UIImage *CustomImage;
@property(nonatomic,weak)UIButton *btn;

@end

@implementation PicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
-(void)setupUI{
    CGSize viewSize = self.view.bounds.size;
    self.view.backgroundColor =[UIColor whiteColor];
    UIImageView *imageViewR = [[UIImageView alloc] initWithFrame:CGRectMake((viewSize.width-100)/2, 94, 100, 100)];
    imageViewR.backgroundColor = [UIColor grayColor];
    imageViewR.layer.cornerRadius  = 50;
    imageViewR.layer.masksToBounds = YES;
    [self.view addSubview:imageViewR];
    self.imageViewR = imageViewR;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(imageViewR.frame)+20, viewSize.width-60, viewSize.width-60)];
    imageView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:imageView];
    self.imageView  = imageView;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(imageView.frame)+20, viewSize.width-32, 35)];
    btn.backgroundColor = [UIColor orangeColor];
    btn.layer.cornerRadius  = 5;
    btn.layer.masksToBounds  =YES;
    [btn setTitle:@"获取图片" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];//加粗字体
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    self.btn  =btn;

}
-(void)btnClick{
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
-(void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 1);//取值0.0~1.0，1为不压缩保存
    NSString *fullpath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:imageName];
    //将图片写入文件
    [imageData writeToFile:fullpath atomically:YES];
    
}
//当从相册里选取一张照片，或者用相机拍照后会自动调用该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //保存至本地
    [self saveImage:image withName:@"avatar.jpg"];
    //保存至系统相册
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    [self createAlbum:image];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"avatar.jpg"];
    UIImage *saveImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    //设置图片显示
    [self.imageView setImage:saveImage];
    [self.imageViewR setImage:saveImage];
//    [NSThread sleepForTimeInterval:1];
    [self Upload];

}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];

}
//创建自己的相册
- (void)createAlbum:(UIImage *)image
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *groups=[[NSMutableArray alloc]init];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group)
        {
            [groups addObject:group];
        }
        else
        {
            BOOL haveHDRGroup = NO;
            for (ALAssetsGroup *gp in groups)
            {
                NSString *name =[gp valueForProperty:ALAssetsGroupPropertyName];
                if ([name isEqualToString:@"乐账"])
                {
                    haveHDRGroup = YES;
                }
            }
            if (!haveHDRGroup)
            {
                //do add a group named "XXXX"
                [assetsLibrary addAssetsGroupAlbumWithName:@"乐账"
                                               resultBlock:^(ALAssetsGroup *group)
                 {
                     [groups addObject:group];
                 }
                                              failureBlock:nil];
                haveHDRGroup = YES;
            }
        }
    };
    //创建相簿
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listGroupBlock failureBlock:nil];
    [self saveToAlbumWithMetadata:nil imageData:UIImagePNGRepresentation(image) customAlbumName:@"乐账" completionBlock:^
     {
         //这里可以创建添加成功的方法
     }
                     failureBlock:^(NSError *error)
     {
         //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
         dispatch_async(dispatch_get_main_queue(), ^{
             //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
             if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){
                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
                 [alert show];
             }
         });
     }];
}
- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                      imageData:(NSData *)imageData
                customAlbumName:(NSString *)customAlbumName
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    __weak ALAssetsLibrary *weakSelf = assetsLibrary;
    void (^AddAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName]) {
                    [group addAsset:asset];
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            } failureBlock:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    };
    [assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        if (customAlbumName) {
            [assetsLibrary addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
                if (group) {
                    [weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group addAsset:asset];
                        if (completionBlock) {
                            completionBlock();
                        }
                    } failureBlock:^(NSError *error) {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }];
                } else {
                    AddAsset(weakSelf, assetURL);
                }
            } failureBlock:^(NSError *error) {
                AddAsset(weakSelf, assetURL);
            }];
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
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

#pragma mark - 客户端文件上传
-(void)Upload{
    //获取Documents路径
    NSString *DocumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"开始上传文件");
    //文件拼接
    NSString *filePath = [DocumentPath stringByAppendingPathComponent:@"avatar.jpg"];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"12.jpg" ofType:nil];
    //服务器接口
    NSString *urlstring = @"http://192.168.31.148/php/upload/upload.php";
    NetworkTools *tools = [NetworkTools sharedNetworkTool];
    [tools POSTFileWithUrlString:urlstring FilePath:filePath FileKey:@"userfile" FileName:@"avatar.jpg" SuccessBlock:^(NSData *data, NSURLResponse *response) {
        NSLog(@"请求成功");
    } Fail:^(NSError *error) {
        NSLog(@"请求失败%@",error);
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
