//
//  ViewController.m
//  ALMoviePlayerController
//
//  Created by Anthony Lobianco on 10/8/13.
//  Copyright (c) 2013 Anthony Lobianco. All rights reserved.
//

#import "ViewController.h"
#import "ALMoviePlayerController.h"

@interface ViewController () <ALMoviePlayerControllerDelegate>

@property (nonatomic, strong) ALMoviePlayerController *moviePlayer;
@property (nonatomic) CGRect defaultFrame;

@end

@implementation ViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"ALMoviePlayerController", @"ALMoviePlayerController");
    }
    return self;
}

- (void)orientChange:(NSNotification *)notification{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSLog(@"%ld",(long)orientation);
    NSLog(@"%@",notification);
    if (orientation != UIInterfaceOrientationPortrait) {
        [self configureViewForOrientation:UIInterfaceOrientationLandscapeLeft];
    }else {
        [self configureViewForOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
	// Do any additional setup after loading the view.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    //create a player
    self.moviePlayer = [[ALMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.moviePlayer.view.alpha = 0.f;
    self.moviePlayer.delegate = self; //IMPORTANT!
    
    //create the controls
    ALMoviePlayerControls *movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.moviePlayer style:ALMoviePlayerControlsStyleDefault];
    //[movieControls setAdjustsFullscreenImage:NO];
    [movieControls setBarColor:[UIColor colorWithRed:195/255.0 green:29/255.0 blue:29/255.0 alpha:0.5]];
    [movieControls setTimeRemainingDecrements:YES];
    //[movieControls setFadeDelay:2.0];
    //[movieControls setBarHeight:100.f];
    //[movieControls setSeekRate:2.f];
    
    //assign controls
    [self.moviePlayer setControls:movieControls];
    [self.view addSubview:self.moviePlayer.view];
//    [UIColor redColor];
    //THEN set contentURL
//    NSURL *url = [NSURL fileURLWithPath:@"/Users/xuchangyuan/Downloads/ALMoviePlayerController-master/ALMoviePlayerControllerDemo/popeye.mp4"];
//    NSURL *url = [NSURL URLWithString:@"http://d.gsxservice.com/logo_video_start_wswx.mp4?v=20150127"];
    NSURL *url = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
//    NSURL *url = [NSURL URLWithString:@"http://192.168.2.144:8082/docserver/movices.mov"];
//    [self.moviePlayer setContentURL:[NSURL URLWithString:@"http://d.gsxservice.com/logo_video_start_wswx.mp4?v=20150127"]];
    self.moviePlayer.contentURL = url;
    
    //delay initial load so statusBarOrientation returns correct value
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self configureViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.moviePlayer.view.alpha = 1.f;
        } completion:^(BOOL finished) {
            self.navigationItem.leftBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    });
}

- (void)configureViewForOrientation:(UIInterfaceOrientation)orientation {
    CGFloat videoWidth = 0;
    CGFloat videoHeight = 0;
    if (UIDeviceOrientationLandscapeRight == orientation || UIDeviceOrientationLandscapeLeft == orientation) {
        videoWidth = self.view.frame.size.width;
        videoHeight = self.view.frame.size.height;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden: YES];
    }else{
        videoWidth = self.view.frame.size.width;
        videoHeight = 200;
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden: NO];
    }
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        videoWidth = 700.f;
//        videoHeight = 535.f;
//    } else {
  
//    }

    self.defaultFrame = CGRectMake(0,0, videoWidth, videoHeight);
    
    //only manage the movie player frame when it's not in fullscreen. when in fullscreen, the frame is automatically managed
    
    if (self.moviePlayer.isFullscreen)return;
    
    //you MUST use [ALMoviePlayerController setFrame:] to adjust frame, NOT [ALMoviePlayerController.view setFrame:]
    [self.moviePlayer setFrame:self.defaultFrame];
}

//these files are in the public domain and no longer have property rights
- (void)localFile {
    [self.moviePlayer stop];
    [self.moviePlayer setContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"popeye" ofType:@"mp4"]]];
    [self.moviePlayer play];
}

- (void)remoteFile {
    [self.moviePlayer stop];
    [self.moviePlayer setContentURL:[NSURL URLWithString:@"http://m.genshuixue.com/video/view/2ec239a2f0"]];
    [self.moviePlayer play];
}

//IMPORTANT!
- (void)moviePlayerWillMoveFromWindow {
    //movie player must be readded to this view upon exiting fullscreen mode.
    if (![self.view.subviews containsObject:self.moviePlayer.view])
        [self.view addSubview:self.moviePlayer.view];
    
    //you MUST use [ALMoviePlayerController setFrame:] to adjust frame, NOT [ALMoviePlayerController.view setFrame:]
    [self.moviePlayer setFrame:self.defaultFrame];
}

- (void)movieTimedOut {
    NSLog(@"MOVIE TIMED OUT");
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self configureViewForOrientation:toInterfaceOrientation];
}

@end
