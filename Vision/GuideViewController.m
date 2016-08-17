//
//  GuideViewController.m
//  Vision
//
//  Created by dllo on 16/3/19.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "GuideViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface GuideViewController ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *plyerLayer;
@property (weak, nonatomic) IBOutlet UILabel *detaillabel;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
- (IBAction)intoAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *intoBtn;
@end

@implementation GuideViewController

// 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:3 animations:^{
        self.titlelabel.alpha = 1;
        self.detaillabel.alpha = 1;
        self.intoBtn.alpha = 1;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createPlayer];
}

- (void)createPlayer {
    NSString *pathFile = [[NSBundle mainBundle] pathForResource:@"0" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:pathFile];
    self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    // 创建一个播放器承载对象,把播放器放到上面
    self.plyerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.plyerLayer.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    // 视频的填充方式
    self.plyerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    ;
    // 把播放器添加到layer层上
    [self.view.layer insertSublayer:self.plyerLayer atIndex:0];
    [self.player play];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void) movieEnd:(NSNotification *)notice{
    //注册的通知  可以自动把 AVPlayerItem 对象传过来，只要接收一下就OK
    
    AVPlayerItem * playItem = [notice object];
    //关键代码
    [playItem seekToTime:kCMTimeZero];
    
    [self.player play];
}

- (IBAction)intoAction:(id)sender {
    self.block();
}

- (void)viewWillAppear:(BOOL)animated {
    CATransition *transition = [CATransition animation];
    // 设置一下动画类型
    transition.type = @"fade";
    // 设置动画时长
    transition.duration = 0.2;
    transition.repeatCount = 1;
    [self.view.layer addAnimation:transition forKey:@"trasition"];
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
