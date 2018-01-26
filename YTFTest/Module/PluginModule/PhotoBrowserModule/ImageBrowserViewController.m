//
//  ImageBrowserViewController.m
//  PhotoBrower
//
//  Created by apple on 16/7/22.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "ImageBrowserViewController.h"
#import "PhotoView.h"
#import "MBProgressHUD.h"
#import "ToolsFunction.h"
#import "BrowserBottomView.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ImageBrowserViewController ()<UIScrollViewDelegate,PhotoViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray *_subViewArray;// scrollView的所有子视图
    MBProgressHUD *HUD;
}

/** 背景容器视图 */
@property(nonatomic,strong) UIScrollView *scrollView;

/** 底部快速浏览容器视图 */
@property(nonatomic,strong) UIScrollView *bottomScrollView;

/** 外部操作控制器 */
@property (nonatomic,weak) UIViewController *handleVC;

/** 图片浏览方式 */
@property (nonatomic,assign) PhotoBroswerVCType type;

/** 图片数组 */
@property (nonatomic,strong) NSArray <NSString *>*imagesArray;

/** 底部图片数组 */
@property (nonatomic,strong) NSArray <NSString *>*bottomImagesArray;

/** 初始显示的index */
@property (nonatomic,assign) NSUInteger index;

/** 底部选择的index */
@property (nonatomic,assign) NSInteger bottomSelectedindex;

/** 是否可以循环滚动 */
@property (nonatomic,assign) BOOL isLoop;

/** 是否显示底部 */
@property (nonatomic,assign) BOOL isNeedBottomBrowser;

/** 底部显示数量 */
@property (nonatomic,assign) NSInteger bottomCount;

/** 圆点指示器 */
@property(nonatomic,strong) UIPageControl *pageControl;

/** 记录当前的图片显示视图 */
@property(nonatomic,strong) PhotoView *photoView;

/** 图片数量提示 */
@property (nonatomic, strong) UILabel *topLabel;

/** 图片保存路径*/
@property (nonatomic, strong) NSString *savePath;

/** 保存图片的回调 */
@property (nonatomic, copy) YTFPhotoBrowser cusPhotoBrowser;

/** 底部图片间距 */
@property (nonatomic,assign) float bottomDistance;

@end

@implementation ImageBrowserViewController

-(instancetype)init{
    
    self=[super init];
    if (self) {
        _subViewArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor=[UIColor blackColor];
    
    //去除自动处理
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //设置contentSize
    self.scrollView.contentSize = CGSizeMake(WIDTH * self.imagesArray.count, 0);
    
    for (int i = 0; i < self.imagesArray.count; i++) {
        [_subViewArray addObject:[NSNull class]];
    }
    
    self.scrollView.contentOffset = CGPointMake(WIDTH*self.index, 0);//此句代码需放在[_subViewArray addObject:[NSNull class]]之后，因为其主动调用scrollView的代理方法，否则会出现数组越界
    
    if ((self.isLoop && self.imagesArray.count==3) ||
        (!self.isLoop && self.imagesArray.count==1)) {
        _pageControl.hidden=YES;
    }
    
    // 添加bottomScrollView
    if (_isNeedBottomBrowser)
    {
        [self loadBottomPhoto];
        
        if (self.isLoop)
        {
            [self loadPhote:self.index-1];// 显示当前索引的图片
        } else {
            [self loadPhote:self.index];// 显示当前索引的图片
        }
    } else {
        if (self.isLoop)
        {
            self.pageControl.currentPage=self.index - 1;
            [self loadPhote:self.index-1];// 显示当前索引的图片
        } else {
            self.pageControl.currentPage=self.index;
            [self loadPhote:self.index];// 显示当前索引的图片
        }
    }
    
    if (self.isLoop)
    {
        self.topLabel.text = [NSString stringWithFormat:@"%lu/%lu", self.index, self.imagesArray.count - 2];
    } else {
        self.topLabel.text = [NSString stringWithFormat:@"%lu/%lu", self.index + 1, self.imagesArray.count];
    }
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCurrentVC:)];
    [self.view addGestureRecognizer:tap];//为当前view添加手势，隐藏当前显示窗口
}

-(void)hideCurrentVC:(UIGestureRecognizer *)tap{
    [self hideScanImageVC];
}

- (void)loadBottomPhoto
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _bottomDistance = (WIDTH - _bottomCount*(WIDTH/6 - 20.0))/(_bottomCount + 1);
        
        // url数组或图片数组
        for (int i = 0; i < self.bottomImagesArray.count; i++)
        {
            CGRect frame = CGRectMake(_bottomDistance + i * (WIDTH/6 - 20.0 + _bottomDistance), 10, WIDTH/6 - 20.0, WIDTH/6 - 20.0);
            
            BrowserBottomView *bottomView = [[BrowserBottomView alloc] initWithFrame:frame];
            bottomView.tag = i;
            bottomView.imageView.tag = i;
            
            if (self.bottomSelectedindex == i)
            {
                bottomView.isChecked = true;
            } else {
                bottomView.isChecked = false;
            }
            
            NSString *imagePath = [self.bottomImagesArray objectAtIndex:i];
            
            if ([imagePath isKindOfClass:[NSNull class]])
            {
                imagePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"photoBrowser.png"];
            }
            
            if ([imagePath hasPrefix:@"http"])
            {
                NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:self.bottomImagesArray[i]] options:NSDataReadingMappedIfSafe error:nil];
                UIImage *image=[UIImage imageWithData:data];
                bottomView.imageView.image = image;
            } else {
                bottomView.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
            }
            
            bottomView.imageView.userInteractionEnabled = true;
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBottomImageView:)];
            [bottomView.imageView addGestureRecognizer:tap];//为当前imageView添加手势，隐藏当前显示窗口
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.bottomScrollView addSubview:bottomView];
            });
        }
        
        self.bottomScrollView.contentSize = CGSizeMake(self.bottomImagesArray.count * (WIDTH/6 - 20.0 + _bottomDistance) + _bottomDistance, WIDTH/6);
        self.bottomScrollView.contentOffset = CGPointMake(self.bottomSelectedindex * (WIDTH/6 - 20.0 + _bottomDistance), 0.0);
    });
}

- (void)tapBottomImageView:(UITapGestureRecognizer *)gestureRecognizer
{
    self.bottomSelectedindex = ((UIImageView *)gestureRecognizer.view).tag;
    [self changeBottomViewBackgroundColorWithIndex:self.bottomSelectedindex];
    
    if (_isLoop)
    {
        self.bottomSelectedindex += 1;
        self.topLabel.text = [NSString stringWithFormat:@"%lu/%lu", self.bottomSelectedindex, self.imagesArray.count - 2];
    } else {
        self.topLabel.text = [NSString stringWithFormat:@"%lu/%lu", self.bottomSelectedindex + 1, self.imagesArray.count];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width * self.bottomSelectedindex, 0)];
    });
}

- (void)changeBottomViewBackgroundColorWithIndex:(NSInteger)index
{
    for (UIView *subView in self.bottomScrollView.subviews)
    {
        if ([subView isKindOfClass:[BrowserBottomView class]] && subView.tag == index)
        {
            subView.backgroundColor = [UIColor redColor];
        } else {
            subView.backgroundColor = [UIColor clearColor];
        }
    }
}

#pragma mark - 显示图片
-(void)loadPhote:(NSInteger)index
{
    // 加载当前页
    [self loadForwardAndBackwardPhoto:index];
    // 加载前一页
    [self loadForwardAndBackwardPhoto:index - 1];
    // 加载后一页
    [self loadForwardAndBackwardPhoto:index + 1];
}

- (void)loadForwardAndBackwardPhoto:(NSInteger)index
{
    if (index<0 || index >=self.imagesArray.count) {
        return;
    }
    
    id currentPhotoView = [_subViewArray objectAtIndex:index];
    if (![currentPhotoView isKindOfClass:[PhotoView class]]) {
        // url数组或图片数组
        CGRect frame = CGRectMake(index*_scrollView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        NSString *imagePath = [self.imagesArray objectAtIndex:index];
        
        if ([imagePath isKindOfClass:[NSNull class]])
        {
            imagePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"photoBrowser.png"];
        }
        
        // 网络图片
        if ([imagePath hasPrefix:@"http"])
        {
            PhotoView *photoV = [[PhotoView alloc] initWithFrame:frame withPhotoUrl:imagePath];
            photoV.delegate = self;
            
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewArray replaceObjectAtIndex:index withObject:photoV];
            self.photoView=photoV;
            
        } else { // 本地图片
            PhotoView *photoV = [[PhotoView alloc] initWithFrame:frame withPhotoImage:[UIImage imageWithContentsOfFile:imagePath]];
            photoV.delegate = self;
                [self.scrollView insertSubview:photoV atIndex:0];
                [_subViewArray replaceObjectAtIndex:index withObject:photoV];
                self.photoView=photoV;
        }
    }
}


#pragma mark - 生成显示窗口
+ (void)show:(UIViewController *)handleVC
        type:(PhotoBroswerVCType)type
       index:(NSUInteger)index
      isLoop:(BOOL)isLoop
    isBottom:(BOOL)isBottom
       count:(NSUInteger)count
      intNum:(NSUInteger)intNum
    savePath:(NSString *)savePath
 imagesBlock:(NSArray *(^)())imagesBlock
browserBlock:(YTFPhotoBrowser)photoBrowser
{
    NSArray *photoModels = imagesBlock(); // 取出相册数组
    
    if(photoModels == nil || photoModels.count == 0) {
        return;
    }
    
    ImageBrowserViewController *imgBrowserVC = [[self alloc] init];
    
    if(index >= photoModels.count){
        return;
    }
    
    imgBrowserVC.isLoop = isLoop;
    
    // 判断是否为循环滚动 改变数据源photoModels 和 index
    NSMutableArray *arrayResult = [NSMutableArray arrayWithArray:photoModels];
    NSUInteger indexResult = index;
    
    if (isLoop)
    {
        [arrayResult insertObject:[photoModels lastObject] atIndex:0];
        [arrayResult addObject:[photoModels firstObject]];
        
        indexResult += 1;
    }
    
    imgBrowserVC.index = indexResult;
    
    imgBrowserVC.imagesArray = arrayResult;
    imgBrowserVC.bottomImagesArray = photoModels;
    
    imgBrowserVC.type =type;
    
    imgBrowserVC.handleVC = handleVC;
    
    imgBrowserVC.savePath = savePath;
    
    imgBrowserVC.isNeedBottomBrowser = isBottom;
    
    imgBrowserVC.bottomCount = count;
    
    imgBrowserVC.bottomSelectedindex = intNum;
    
    imgBrowserVC.cusPhotoBrowser = photoBrowser;
    
    [imgBrowserVC show]; //展示
}

/** 真正展示 */
-(void)show{
    
    switch (_type) {
        case PhotoBroswerVCTypePush://push
            
            [self pushPhotoVC];
            
            break;
        case PhotoBroswerVCTypeModal://modal
            
            [self modalPhotoVC];
            
            break;
            
        case PhotoBroswerVCTypeZoom://zoom
            
            [self zoomPhotoVC];
            
            break;
            
        default:
            break;
    }
}

/** push */
-(void)pushPhotoVC{
    
    [_handleVC.navigationController pushViewController:self animated:YES];
}


/** modal */
-(void)modalPhotoVC{
    
    [_handleVC presentViewController:self animated:YES completion:nil];
}

/** zoom */
-(void)zoomPhotoVC{
    
    //拿到window
    UIWindow *window = _handleVC.view.window;
    
    if(window == nil){
        NSLog(@"错误：窗口为空！");
        return;
    }
    
    self.view.frame=[UIScreen mainScreen].bounds;
    
    [window addSubview:self.view]; //添加视图
    
    [_handleVC addChildViewController:self]; //添加子控制器
}

#pragma mark - 隐藏当前显示窗口
-(void)hideScanImageVC{
    
    switch (_type) {
        case PhotoBroswerVCTypePush://push
            
            [self.navigationController popViewControllerAnimated:YES];
            
            break;
        case PhotoBroswerVCTypeModal://modal
            
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
            
        case PhotoBroswerVCTypeZoom://zoom
            
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
            break;
            
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView)
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
        if (page<0||page>=self.imagesArray.count) {
            return;
        }
        
        for (UIView *view in scrollView.subviews) {
            if ([view isKindOfClass:[PhotoView class]]) {
                PhotoView *photoV=(PhotoView *)[_subViewArray objectAtIndex:page];
                if (photoV!=self.photoView) {
                    [self.photoView.scrollView setZoomScale:1.0 animated:YES];
                    self.photoView=photoV;
                }
            }
        }
        
        [self loadPhote:page];
    } else {
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView)
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        NSUInteger currentIndex = 0;
        
        if (self.isLoop)
        {
            if (page == 0)
            {
                currentIndex = self.imagesArray.count - 3;
                [scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width * (self.imagesArray.count - 2), 0)];
            } else if (page == self.imagesArray.count - 1)
            {
                currentIndex = 0;
                [scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0)];
            } else {
                currentIndex = page - 1;
            }
            
            self.topLabel.text = [NSString stringWithFormat:@"%lu/%lu", currentIndex + 1, self.imagesArray.count - 2];
        } else {
            currentIndex = page;
            self.topLabel.text = [NSString stringWithFormat:@"%lu/%lu", currentIndex + 1, self.imagesArray.count];
        }
        
        if (!self.isNeedBottomBrowser)
        {
            self.pageControl.currentPage = currentIndex;
        } else {
            // 正方向
            if (currentIndex > self.bottomSelectedindex)
            {
                if (currentIndex%_bottomCount==0)
                {
                    [self.bottomScrollView setContentOffset:CGPointMake(currentIndex * (WIDTH/6 - 20.0 + _bottomDistance), 0.0)];
                }
            } else {
                // 反方向
                if (self.bottomSelectedindex%_bottomCount==0 && self.bottomSelectedindex - _bottomCount >= 0)
                {
                    [self.bottomScrollView setContentOffset:CGPointMake((self.bottomSelectedindex - _bottomCount) * (WIDTH/6 - 20.0 + _bottomDistance), 0.0)];
                }
            }
            
            self.bottomSelectedindex = currentIndex;
            [self changeBottomViewBackgroundColorWithIndex:currentIndex];
        }
    } else {
        
    }
}

#pragma mark - PhotoViewDelegate
-(void)tapHiddenPhotoView{
    [self hideScanImageVC];//隐藏当前显示窗口
}

- (void)longPressPhotoView:(UIImage *)saveImage
{   
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(actionSheet) weakActionSheet = actionSheet;
    __weak typeof(self) weakSelf = self;
    UIAlertAction *actionSave = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        HUD = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.label.text = @"Saving...";
        // UIImageWriteToSavedPhotosAlbum(saveImage, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)weakSelf);
        [weakSelf saveImageToPhotos:saveImage];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakActionSheet dismissViewControllerAnimated:true completion:nil];
    }];
    
    [actionSheet addAction:actionSave];
    [actionSheet addAction:actionCancel];
    
    [self presentViewController:actionSheet animated:true completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *strResult = nil;
    
    if (error)
    {
        strResult = @"Save Fail";
        self.cusPhotoBrowser(false, @"Save Fail");
    } else {
        strResult = @"Save Success";
        self.cusPhotoBrowser(true, @"Save Success");
    }

    HUD.label.text = strResult;
    [HUD hideAnimated:true afterDelay:0.5];
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    NSData *imageData = UIImageJPEGRepresentation(savedImage, 1);
    BOOL isSuccess = false;
    if (self.savePath == nil)
    {
        // 默认路径：
        // 默认存储二维码图片路径
        NSString *imagePath =  [NSString stringWithFormat:@"%@/ytffs/%@.png", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject, [ToolsFunction getCurrentTimeIntervalString]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        {
            // 创建文件路径
            NSString *directoryPath = [NSString stringWithFormat:@"%@/ytffs", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject];
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
            // 创建文件
            [[NSFileManager defaultManager] createFileAtPath:imagePath contents:nil attributes:nil];
            isSuccess = [imageData writeToFile:imagePath atomically:false];
            if (isSuccess)
            {
                self.cusPhotoBrowser(isSuccess, imagePath);
            } else {
                self.cusPhotoBrowser(isSuccess, nil);
            }
        } else {
            isSuccess = [imageData writeToFile:imagePath atomically:false];
            if (isSuccess)
            {
                self.cusPhotoBrowser(isSuccess, imagePath);
            } else {
                self.cusPhotoBrowser(isSuccess, nil);
            }
        }
    } else {
        // savePath：
        NSString *imageResult = [NSString stringWithFormat:@"%@/%@.png", self.savePath, [ToolsFunction getCurrentTimeIntervalString]];
        [[NSFileManager defaultManager] createDirectoryAtPath:self.savePath withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createFileAtPath:imageResult contents:nil attributes:nil];
        isSuccess = [imageData writeToFile:imageResult atomically:false];
        
        if (isSuccess)
        {
            self.cusPhotoBrowser(isSuccess, imageResult);
        } else {
            self.cusPhotoBrowser(isSuccess, nil);
        }
    }
    
    NSString *strResult = nil;
    
    if (isSuccess == false)
    {
        strResult = @"Save Fail";
    } else {
        strResult = @"Save Success";
    }
    
    HUD.label.text = strResult;
    [HUD hideAnimated:true afterDelay:0.5];
}

#pragma mark - 懒加载
-(UIScrollView *)scrollView
{
    if (_scrollView==nil) {
        _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        _scrollView.delegate=self;
        _scrollView.pagingEnabled=YES;
        _scrollView.contentOffset=CGPointZero;
        //设置最大伸缩比例
        _scrollView.maximumZoomScale=3;
        //设置最小伸缩比例
        _scrollView.minimumZoomScale=1;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIScrollView *)bottomScrollView
{
    if (_bottomScrollView==nil) {
        _bottomScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, HEIGHT - WIDTH/6, WIDTH, WIDTH/6)];
        _bottomScrollView.userInteractionEnabled = true;
        _bottomScrollView.bounces = false;
        _bottomScrollView.backgroundColor = [UIColor blackColor];
        _bottomScrollView.delegate=self;
        _bottomScrollView.contentOffset=CGPointZero;
        _bottomScrollView.showsHorizontalScrollIndicator = NO;
        _bottomScrollView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:_bottomScrollView];
    }
    return _bottomScrollView;
}


-(UIPageControl *)pageControl{
    if (_pageControl==nil) {
        UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-40, WIDTH, 30)];
        bottomView.backgroundColor=[UIColor clearColor];
        _pageControl = [[UIPageControl alloc] initWithFrame:bottomView.bounds];
        
        if (self.isLoop)
        {
            _pageControl.currentPage = self.index - 1;
            _pageControl.numberOfPages = self.imagesArray.count - 2;
        } else {
            _pageControl.currentPage = self.index;
            _pageControl.numberOfPages = self.imagesArray.count;
        }
        
        _pageControl.currentPageIndicatorTintColor = [UIColor yellowColor];
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        [bottomView addSubview:_pageControl];
        [self.view addSubview:bottomView];
    }
    return _pageControl;
}

- (UILabel *)topLabel
{
    if (_topLabel==nil)
    {
        _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, WIDTH, 20)];
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.textColor = [UIColor whiteColor];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.font = [UIFont systemFontOfSize:24.0];
        
        [self.view addSubview:_topLabel];
    }
    
    return _topLabel;
}

#pragma mark - 系统自带代码
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
