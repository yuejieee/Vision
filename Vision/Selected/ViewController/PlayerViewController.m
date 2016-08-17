//
//  PlayerViewController.m
//  自定义播放器
//
//  Created by dllo on 16/1/14.
//  Copyright © 2016年 dllo. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

// 滑动方向
typedef NS_ENUM(NSInteger, MoveDirection) {
    MoveDirectionNone,
    MoveDirectionUp,
    MoveDirectionDown,
    MoveDirectionRight,
    MoveDirectionLeft,
};
CGFloat const gestureMinimumTranslation = 5.0 ;

@interface PlayerViewController () <NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UIView *playerView;

// 开始按钮
@property (weak, nonatomic) IBOutlet UIButton *startButtoon;
@property (nonatomic, assign)BOOL isStart;
- (IBAction)startAction:(id)sender;

// 用来控制进度的触发方法
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgress;
// 用来修改内容的
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
// 假navigation
@property (weak, nonatomic) IBOutlet UIView *navigationView;
// 用来显示时间的
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *bottimView;

// 返回按钮
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backAction:(id)sender;

@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, strong)AVPlayerItem *playerItem;
@property (nonatomic, strong)AVPlayerLayer *plyerLayer;

@property (nonatomic, assign)BOOL isTap;

// 用来记录视频播放时长
@property (nonatomic, assign)CGFloat duration;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

// 方向
@property (nonatomic, assign) MoveDirection direction;
// 开始位置
@property (nonatomic, assign) CGPoint location;
// 当前音量
@property (nonatomic, assign) float volume;
// 实时位置
@property (nonatomic, assign) CGPoint curretn;

// 下载
- (IBAction)dowloadAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *downLoadLabel;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.isStart = YES;
    self.isStart = YES;
    self.progressSlider.value = 0;
    [self.progressSlider addTarget:self action:@selector(addProgressSlide) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    // 初始化播放器
    [self createPlayer];
    [self.player play];
    
    // 对播放进度进行设置
    [self setTimeLabel];
    
    // 给当前屏幕,添加一个监听横竖屏和视频结束的方法
    [self addNotificationCenters];
    
    // 创建一个轻点的手势
    [self addTapGestureRecognizer];
    
     [self.progressSlider addTarget:self action:@selector(sliderEndChange:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    [self addProgress];
    [self.backButton setTitle:self.data.title forState:UIControlStateNormal];
    
    // 添加轻扫手势
    [self addPanGestureRecognizer];
    
    // 下载
    [self setSession];
}

#pragma mark ---------- timeLabel设置 ----------
- (void)setTimeLabel {
    self.timeLabel.text = @"00:00/00:00";
    self.timeLabel.font = [UIFont systemFontOfSize:12];
}

#pragma mark ---------- 播放器创建 ----------
- (void)createPlayer {
    NSString *pathFile = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathDownload = [pathFile stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", self.data.title]];
    NSString *urlStr = nil;
    NSURL *url = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathDownload]) {
        urlStr = [[NSBundle mainBundle] pathForResource:self.data.title ofType:@"mp4"];
        url = [NSURL fileURLWithPath:pathDownload];
        self.downLoadLabel.text = @"已下载";
    } else {
        urlStr = self.data.playUrl;
        // 对网址进行转码
        urlStr =[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [NSURL URLWithString:urlStr];
    }
    
    // 根据网址,创建视频项目对象
    self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    // 创建一个播放器承载对象,把播放器放到上面
    self.plyerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.plyerLayer.frame = CGRectMake(5, 5, WIDTH - 10, HEIGHT - 10);
    // 视频的填充方式
    self.plyerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 把播放器添加到layer层上
    [self.playerView.layer insertSublayer:self.plyerLayer atIndex:0];
    [SVProgressHUD dismiss];
}

#pragma mark ---------- 添加监听方法 ----------
- (void)addNotificationCenters {
    // 监听当前视频播放情况,播放结束,触发方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 监听屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnScreen:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    // 监听播放状态
    [self addObserverToPlayerItem:self.playerItem];
}

#pragma mark ---------- 播放结束 ----------
- (void)movieEnd:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark ---------- 屏幕旋转 ----------
- (void)turnScreen:(NSNotification *)notification {
    UIInterfaceOrientation ori = [[UIApplication sharedApplication] statusBarOrientation];
    // 根据横竖屏调整播放器的frame
    if (ori == UIInterfaceOrientationLandscapeRight) {
        [self setPlayerLayerFrame];
    }
}

- (void)setPlayerLayerFrame {
    self.plyerLayer.frame = CGRectMake(5, 5, WIDTH - 10, HEIGHT - 10);
}

#pragma mark ---------- 开始播放和缓冲监听 ----------
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
            [self.activityView stopAnimating];
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        CGFloat progress = totalBuffer / CMTimeGetSeconds(playerItem.duration);
        self.bufferProgress.progress = progress;
        NSLog(@"共缓冲：%.2f",progress);
    }
}

#pragma mark ---------- 点击手势 ----------
- (void) addTapGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.isTap = YES;
    self.playerView.userInteractionEnabled = YES;
    [self.playerView addGestureRecognizer:tap];
}

#pragma mark ---------- 轻点触发 ----------
- (void)tap:(UITapGestureRecognizer *)tap {
    if (self.isTap == YES) {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomView.alpha = 0;
            self.navigationView.alpha = 0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomView.alpha = 1;
            self.navigationView.alpha = 1;
        }];
    }
    self.isTap = !self.isTap;
}

#pragma mark ----------- 添加进度设置 ----------
/**
 *  @author yueJie, 16-03-18 14:03:08
 *  
 *  CMTime是专门用来表示视频时间的
 *  CMTimeMake是用来创建CMTime的
 *  用法就是CMTimeMake(time, timeScale)
 *  time指的是时间.但不是秒
 *  timeScale指的是1秒需要多少帧构成,而真正的时间是time/timeScale
 */
- (void)addProgressSlide {
    [self.startButtoon setImage:[UIImage imageNamed:@"btn_pause@3x"] forState:UIControlStateNormal];
    self.isStart = YES;
}

- (void)addProgress {
    // 设置成(1, 1), 毎1s执行一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 当前视频的总时间 , 将CMTime转换成CGFloat
        CGFloat durationTime = CMTimeGetSeconds(self.playerItem.duration);
        // 当前时间
        CGFloat currentTime = CMTimeGetSeconds(self.playerItem.currentTime);
        // 倒计时
        CGFloat rem = durationTime - currentTime;
        
        NSString *str = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d", (int)rem / 60, (int)rem % 60, (int)currentTime / 60, (int)currentTime % 60];
        self.timeLabel.text = str;
        
        self.progressSlider.value = currentTime / durationTime;
        // 保存总时长, 用于手动快进
        self.duration = durationTime;
    }];
}

#pragma mark ---------- 轻扫手势 ----------
- (void)addPanGestureRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.playerView addGestureRecognizer:pan];
}

- (void)panAction:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // 无方向
        self.direction = MoveDirectionNone;
        // 开始滑动位置
        self.location = [recognizer locationInView:self.playerView];
        // 获取当前音量
        self.volume	= self.player.volume;
    }
    // 事实移动位置 增量
    CGPoint translation = [recognizer translationInView:self.playerView];
    self.direction = [self determineDirectionIfNeeded:translation];
    self.curretn = [recognizer locationInView:self.playerView];
    
    // 声音调节
    if (self.direction == 1 || self.direction == 2) {
        self.volume = [self getSystemVolume];
        float currentVolume = self.volume + ((self.location.y - self.curretn.y) / self.playerView.frame.size.height) * 0.1;
        if (currentVolume <= 0 ) {
            currentVolume = 0;
        } else if(currentVolume >= 1) {
            currentVolume = 1;
        }
        [self.player setVolume:currentVolume];
        [self setSystemVolme:currentVolume];
        
    } else if(self.direction == 3 || self.direction == 4) {
        //		translation.x	移动偏移量
        //		velocity.x		移动速度
        if (self.curretn.y >= (self.playerView.bounds.size.height - 30)) {
            return;
        }
        
        // 移动快进速度
        CGFloat speed = 150 / self.playerView.frame.size.width;
        
        long add =  (long)(translation.x);
        
        CMTime currentTime	= self.player.currentTime;
        CMTime addTime	= CMTimeMake(add, 1);
        CMTime newTime	= CMTimeAdd(currentTime, addTime);
        
        self.progressSlider.value += translation.x / self.playerView.frame.size.width * speed;
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            if (CMTimeRangeContainsTime(CMTimeRangeMake(kCMTimeZero, self.playerItem.duration), newTime)) {
                [self.player seekToTime:newTime completionHandler:^(BOOL finished) {
                }];
            } else if (newTime.value <=0) {
                [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                }];
            } else if ((newTime.value / newTime.timescale) >= (self.playerItem.duration.value / self.playerItem.duration.timescale)) {
                [self.player seekToTime:self.playerItem.duration completionHandler:^(BOOL finished) {
                }];
            }
        }
    }

}

- (CGFloat)getSystemVolume {
    MPMusicPlayerController *musicPlayer;
    musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    return musicPlayer.volume;
}

- (void)setSystemVolme:(float)currentVolume {
    MPMusicPlayerController *musicPlayer;
    musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [musicPlayer setVolume:currentVolume];
}

#pragma mark ---------- 滑动方向判断 ---------
- (MoveDirection)determineDirectionIfNeeded:(CGPoint)translation {

    if (self.direction != MoveDirectionNone) {
        return self.direction;
    }
    if (fabs(translation.x) > gestureMinimumTranslation) {
        
        BOOL gestureHorizontal = NO;
        if (translation.y == 0.0 ) {
            gestureHorizontal = YES;
        } else {
            gestureHorizontal = (fabs(translation.x / translation.y) > 5.0 );
        }
        if (gestureHorizontal) {
            if (translation.x > 0.0 ) {
                return MoveDirectionRight;
            } else {
                return MoveDirectionLeft;
            }
        }
    } else if (fabs(translation.y) > gestureMinimumTranslation) {
        BOOL gestureVertical = NO;
        if (translation.x == 0.0 )
            gestureVertical = YES;
        else
            gestureVertical = (fabs(translation.y / translation.x) > 5.0 );
        if (gestureVertical) {
            if (translation.y > 0.0 ) {
                return MoveDirectionDown;
            } else {
                return MoveDirectionUp;
            }
        }
    }
    return self.direction;
}

#pragma mark ---------- 播放进度条 ----------
- (void)sliderEndChange:(UISlider *)slider {
    // 获取当前时间
    double currentTime = self.duration * self.progressSlider.value;
    CMTime drage = CMTimeMake(currentTime, 1);
    [self.player seekToTime:drage completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}

#pragma mark ---------- 播放按钮 ----------
- (IBAction)startAction:(id)sender {
    if (self.isStart == YES) {
        [self.player pause];
        [self.startButtoon setImage:[UIImage imageNamed:@"btn_play@3x"] forState:UIControlStateNormal];
    } else {
        [self.player play];
        [self.startButtoon setImage:[UIImage imageNamed:@"btn_pause@3x"] forState:UIControlStateNormal];
    }
    self.isStart = !self.isStart;
}

#pragma mark ---------- 下载按钮 ----------
- (IBAction)dowloadAction:(id)sender {
    NSString *pathFile = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathDownload = [pathFile stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", self.data.title]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathDownload]) {
        NSLog(@"已下载");
    } else {
        [self downloadFile];
    }
}

- (void)setSession {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

- (void)downloadFile {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.data.playUrl] cachePolicy:1 timeoutInterval:15];
    [[self.session downloadTaskWithRequest:request]resume];
}

#pragma mark ----------- 协议方法 ----------
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *pathFile = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathDownload = [pathFile stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", self.data.title]];
    NSFileManager *manger = [NSFileManager defaultManager];
    [manger copyItemAtPath:location.path toPath:pathDownload error:NULL];
}

// 进度数据
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    self.downLoadLabel.text = [NSString stringWithFormat:@"%.2f %%", progress * 100];
    NSLog(@"%f",progress);
}

// 下载完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (![error isEqual:@""]) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *pathDataContent = [path stringByAppendingPathComponent:@"cachesData.plist"];
        NSMutableArray *temp = [NSKeyedUnarchiver unarchiveObjectWithFile:pathDataContent];
        NSMutableArray *downloadArray = [NSMutableArray arrayWithArray:temp];
        [downloadArray addObject:self.data];
        [NSKeyedArchiver archiveRootObject:downloadArray toFile:pathDataContent];
        self.downLoadLabel.text = @"下载完成";
    } else {
        NSLog(@"%@", error);
    }
}

- (IBAction)backAction:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserverFromPlayerItem:self.playerItem];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.player pause];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.player play];

}

#pragma mark ---------- 强制横屏代码 ----------
- (BOOL)shouldAutorotate {
    //是否支持转屏
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //支持哪些转屏方向
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
