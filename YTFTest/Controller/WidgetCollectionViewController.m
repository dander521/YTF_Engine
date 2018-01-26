//
//  WidgetCollectionViewController.m
//  YTFTest
//
//  Created by apple on 2016/11/16.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "WidgetCollectionViewController.h"
#import "Definition.h"
#import "BaseViewController.h"
#import "AppDelegate.h"
#import "HeaderCRView.h"
#import "SRWebSocket.h"
#import "WidgetAppObject.h"
#import "WidgetCollectionViewCell.h"
#import "NetworkManager.h"

@interface WidgetCollectionViewController ()<SRWebSocketDelegate, HeaderCRViewDelegate>
{
    SRWebSocket *_webSocket;
}

@property (nonatomic, strong) NSMutableArray <WidgetAppObject *>*appObjectArray; // 需要测试的app数组

@end

@implementation WidgetCollectionViewController

static NSString * const cellIdentifier = @"cellIdentifier";
static NSString * const headerIdentifier = @"header";

- (instancetype)init
{
    // 设置流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    // UICollectionViewFlowLayout流水布局的内部成员属性有以下：
    layout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 80.0);
    // 定义大小
    layout.itemSize = CGSizeMake(ScreenWidth/3, ScreenWidth/3);
    // 设置最小行间距
    layout.minimumLineSpacing = 0;
    // 设置垂直间距
    layout.minimumInteritemSpacing = 0;
    // 设置滚动方向（默认垂直滚动）
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appObjectArray = [NSMutableArray new];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    // Register cell classes
    [self.collectionView registerClass:[WidgetCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    //这里的HeaderCRView 是自定义的header类型
    [self.collectionView registerClass:[HeaderCRView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
    
    [self performSelector:@selector(inputSocketHostAndPort) withObject:nil afterDelay:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)inputSocketHostAndPort
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"IDE Socket" message:@"请输入IDE中socket的host和port" preferredStyle:UIAlertControllerStyleAlert];
    
    
    RCWeakSelf(alertController);
    RCWeakSelf(self);
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 读取文本框的值显示出来
        
        [[NSUserDefaults standardUserDefaults] setValue:weakalertController.textFields.firstObject.text forKey:LoaderIDEHost];
        [[NSUserDefaults standardUserDefaults] setValue:weakalertController.textFields.lastObject.text forKey:LoaderIDEPort];
        [[NSUserDefaults standardUserDefaults] synchronize];

        if ([[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEHost] && [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEPort])
        {
            // _webSocket
            _webSocket.delegate = nil;
            
            [_webSocket close];
            
            _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%@/websocket", [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEHost], [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEPort]]]]];
            
            _webSocket.delegate = weakself;
            [_webSocket open];
        }
    }]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
    {
        textField.placeholder = @"请输入服务器地址";
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.secureTextEntry = false;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEHost])
        {
            textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEHost];
        }
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
    {
        textField.placeholder = @"请输入服务器端口号";
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.secureTextEntry = false;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEPort])
        {
            textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEPort];
        }
    }];

    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.appObjectArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WidgetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];


    WidgetAppObject *appObj = self.appObjectArray[indexPath.item];
    
    NSData *fileData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/loader/%@.png", FilePathAppCaches, appObj.appId]];
    // Configure the cell
    if (![ToolsFunction isFileExistAtPath:[NSString stringWithFormat:@"%@/loader/%@.png", FilePathAppCaches, appObj.appId]] || [fileData length] < 200)
    {
        cell.imageView.image = [UIImage imageNamed:@"icon.png"];
    } else {
        cell.imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/loader/%@.png", FilePathAppCaches, appObj.appId]];
    }
    
    cell.appName.text = appObj.appName;
    cell.appId.text = appObj.appId;

    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BaseViewController *vwcBase = [[BaseViewController alloc] init];
    [[NSUserDefaults standardUserDefaults] setValue:self.appObjectArray[indexPath.item].appId forKey:LoaderIDEAppId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AppDelegate shareAppDelegate].baseViewController = vwcBase;
    [self presentViewController:vwcBase animated:true completion:nil];
}

//这个也是最重要的方法 获取Header的 方法。
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    // 从缓存中获取 Headercell
    HeaderCRView *cell = (HeaderCRView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    DLog(@"webSocketDidOpen");

    NSError *error;
    [_webSocket sendString:@"{'commanId':1}" error:&error];
    DLog(@"error = %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fail" message:@"请求socket失败" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    DLog(@"message = %@", message);
    /*
     {"port":8080,"apps":[{"appId":"Y16111579203930","appName":"555","icon":"/Y16111579203930/images/ic_launcher.png"}],"commanId":"1"}
     */
    
    NSData *dataJson = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dicJson = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:nil];

    [[NSUserDefaults standardUserDefaults] setValue:dicJson[@"port"] forKey:LoaderIDEWebPort];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSArray *arrayApp = dicJson[@"apps"];
        
    if (arrayApp && arrayApp.count > 0)
    {
        for (NSDictionary *dicApp in arrayApp)
        {
            WidgetAppObject *appObject = [[WidgetAppObject alloc] init];
            appObject.appId = dicApp[@"appId"];
            appObject.appName = dicApp[@"appName"];
            appObject.appIcon = dicApp[@"icon"];
            [self.appObjectArray addObject:appObject];
            
            YTFAFHTTPSessionManager *manager =[NetworkManager sharedHTTPSession];

            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", [[NSUserDefaults standardUserDefaults] objectForKey:LoaderIDEHost], dicJson[@"port"], dicApp[@"icon"]]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

                NSString *fullPath = [NSString stringWithFormat:@"%@/loader/%@.png", FilePathAppCaches, dicApp[@"appId"]];
                [ToolsFunction createDirectoryWithPath:[[NSString stringWithFormat:@"%@/loader/%@.png", FilePathAppCaches, dicApp[@"appId"]] stringByDeletingLastPathComponent]];
                return [NSURL fileURLWithPath:fullPath];
                
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.collectionView reloadData];
                });
            }];
            // 3.执行Task
            [download resume];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    DLog(@"didCloseWithCode");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    DLog(@"didReceivePong");
}

#pragma mark - HeaderCRViewDelegate

- (void)touchInputButton
{
    [self inputSocketHostAndPort];
}

@end
