//
//  ViewController.m
//  FiirstNetWorkH5
//
//  Created by leviduan on 2018/3/23.
//  Copyright © 2018年 leviduan. All rights reserved.
//

#import "ViewController.h"
#import "SSZipArchive.h"
#import <HTTPServer.h>

@interface ViewController () <NSURLSessionDownloadDelegate, SSZipArchiveDelegate>

@property (nonatomic, strong) UILabel *testLabel;

@property (nonatomic, strong) UIButton *testBtn;

@property (nonatomic, strong) UIButton *pauseBtn;

@property (nonatomic, strong) NSData *resumeData;

@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, assign) BOOL isPauseBool;

@property (nonatomic, strong) HTTPServer *localHttpServer;

@property (nonatomic, assign) BOOL startServerSuccess;

@property (nonatomic, copy) NSString *port;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 按钮恢复以及暂停
    _isPauseBool = NO;
    
    // 清除文档目录所有file
    [self removeAllfile];
    
    // 遍历打印文件夹中文件
    //[self traversalDirectory];
    [self addUIView];
}

- (void)removeAllfile
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/"];
    [manager removeItemAtPath:docsDir error:nil];
}

- (void)addUIView
{
    [self.view addSubview:self.testLabel];
    [self.view addSubview:self.testBtn];
    [self.view addSubview:self.pauseBtn];
    [self.testLabel sizeToFit];
    
    CGPoint center = self.testLabel.center;
    center.x = [UIScreen mainScreen].bounds.size.width / 2.0;
    center.y = [UIScreen mainScreen].bounds.size.height / 2.0;
    
    self.testLabel.center = center;
    self.testBtn.frame = CGRectMake(0, 0, 100, 30);
    
    CGPoint centerBtn = self.testBtn.center;
    centerBtn.x = [UIScreen mainScreen].bounds.size.width / 2.0;
    centerBtn.y = [UIScreen mainScreen].bounds.size.height / 2.0+100;
    self.testBtn.center = centerBtn;
    
    self.pauseBtn.frame = CGRectMake(0, 0, 100, 30);
    CGPoint centerBtn1 = self.pauseBtn.center;
    centerBtn1.x = [UIScreen mainScreen].bounds.size.width / 2.0;
    centerBtn1.y = [UIScreen mainScreen].bounds.size.height / 2.0+200;
    self.pauseBtn.center = centerBtn1;
    
    [self.testBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseBtn addTarget:self action:@selector(switchVoid) forControlEvents:UIControlEventTouchUpInside];
}

- (void)switchVoid
{
    if (!_isPauseBool) {
        _isPauseBool = YES;
        [self pause];
        [self.pauseBtn setTitle:@"恢复按钮" forState:UIControlStateNormal];
    }
    else {
        _isPauseBool = NO;
        [self resume];
        [self.pauseBtn setTitle:@"暂停按钮" forState:UIControlStateNormal];
    }
}

- (void)start
{
//    NSURL *url = [NSURL URLWithString:@"http://192.168.116.79/crazySnake.zip"];
    NSURL *url = [NSURL URLWithString:@"http://192.168.116.79/game.zip"];
//    NSURL *url = [NSURL URLWithString:@"https://gimg.gamdream.com/weplayGame/gamePackage/fanfanle.zip"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    self.task = [self.session downloadTaskWithRequest:request];
//    self.task = [self.session downloadTaskWithURL:[NSURL URLWithString:@"http://192.168.116.79/crazySnake.zip"]];
    [self.task resume];
}

- (void)pause
{
    __weak __typeof(self) weakSelf = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.resumeData = resumeData;
        weakSelf.task = nil;
    }];
}

- (void)resume
{
    self.task = [self.session downloadTaskWithResumeData:self.resumeData];
    [self.task resume];
    self.resumeData = nil;
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    self.testLabel.text = [NSString stringWithFormat:@"%lld%% ",(totalBytesWritten*100/totalBytesExpectedToWrite)];
    [self.testLabel sizeToFit];
}

- (void)createGameFolder
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dataFilePath = [docPath stringByAppendingPathComponent:@"game"]; // 在Caches目录下创建 "game" 文件夹
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        // 在Document目录下创建一个archiver目录
        [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)createGameFolderName:(NSString *)folderName
{
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Game/"];
    NSString *dataFilePath = [docPath stringByAppendingPathComponent:folderName]; // 在Caches目录下创建 "game" 文件夹
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        // 在Document目录下创建一个archiver目录
        [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;
{
    NSLog(@"FILE TRANSFER OVER");
    [self createGameFolder];
    [self createGameFolderName:@"snake"];
    //NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Game/snake/"];
    NSString *file = [docPath stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSError *error = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL result = [manager fileExistsAtPath:location.path];
    NSLog(@"移动之前 这个文件已经存在：%@",result?@"是的":@"不存在");
    if ([manager fileExistsAtPath:location.path]) {
        NSLog(@"移动之前文件大小为: %.1fM", [[manager attributesOfItemAtPath:location.path error:nil] fileSize]/1000000.0);
    }
    if (![[manager attributesOfItemAtPath:location.path error:nil] fileSize]) {
        NSLog(@"文件为空返回");
        return;
    }
    // 判断文件是否存在
    BOOL ret = [manager moveItemAtPath:location.path toPath:file error:&error];
    if (!ret) {
        NSLog(@"MOVE FILE IS WRONG");
    }
    if (error) {
        NSLog(@"move failed:%@", [error localizedDescription]);
    }
    
    BOOL resultdd = [manager fileExistsAtPath:file];
    NSLog(@"移动之后 这个文件已经存在：%@",resultdd?@"是的":@"不存在");
    
    NSLog(@"储存路径 移动之后:%@, \n移动之前:%@",file,location.path);
    
    NSString *destination = [NSString stringWithFormat:@"%@/", docPath];
    BOOL ret1 = [SSZipArchive unzipFileAtPath:file toDestination:destination delegate:self];
    if (!ret1) {
        NSLog(@"解压失败");
        return;
    }
    [manager removeItemAtPath:file error:nil];
    
    // 遍历文件
    NSDirectoryEnumerator *dirEnum = [manager enumeratorAtPath:docPath];
    NSString *fileName;
    while (fileName = [dirEnum nextObject]) {
        NSLog(@"FielName>> : %@" , fileName);
        NSLog(@"FileFull>>> : %@" , [docPath stringByAppendingPathComponent:fileName]) ;
    }
    [self _configLocalHttpServer];
    [self.session finishTasksAndInvalidate];
    _session = nil;
}

- (long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    NSLog(@"%@",error);
}

- (void)zipArchiveWillUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo
{
    NSLog(@"path1 is :%@", path);
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    NSLog(@"path2 is :%@", path);
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"value:%lld,expetec:%lld",fileOffset,expectedTotalBytes);
}

- (void)_configLocalHttpServer
{
//    NSString *webPath = [[NSBundle mainBundle] pathForResource:@"crazySnake" ofType:nil];
    //NSString *webPath = [NSHomeDirectory() stringByAppendingPathComponent:@"crazySnake"];
    NSString *webPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Game/snake/game/"];
    _localHttpServer = [[HTTPServer alloc] init];
    [_localHttpServer setType:@"_http.tcp"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSLog(@"%@", webPath);
    
    if (![fileManager fileExistsAtPath:webPath]) {
        NSLog(@"File path error!");
    }
    else {
        NSString *webLocalPath = webPath;
        [_localHttpServer setDocumentRoot:webLocalPath];
        NSLog(@"webLocalPath:%@", webLocalPath);
        [self _startWebServer];
    }
}

- (void)_startWebServer
{
    NSError *error;
    if ([_localHttpServer start:&error]) {
        NSLog(@"Started HTTP Server on port %hu", [_localHttpServer listeningPort]);
        NSLog(@"Start Server Successfully.");
        self.port = [NSString stringWithFormat:@"%d", [_localHttpServer listeningPort]];
        _startServerSuccess = YES;
        
        UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self.view addSubview:webView];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:%@/match/index.html", self.port]];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        
    }
    else {
        NSLog(@"Error starting HTTP Server: %@", error);
        _startServerSuccess = NO;
    }
}

- (void)traversalDirectory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    NSDirectoryEnumerator *dirEnum = [manager enumeratorAtPath:docsDir];
    NSString *fileName;
    while (fileName = [dirEnum nextObject]) {
        NSLog(@"FielName>>>>>> : %@" , fileName);
        NSLog(@"FileFullPath>>>>>>>>>>>>>>> : %@" , [docsDir stringByAppendingPathComponent:fileName]) ;
    }
    
    NSLog(@"OVER>>>>>> : %@" , fileName);
}

- (UILabel *)testLabel
{
    if (!_testLabel) {
        _testLabel = [[UILabel alloc] init];
        _testLabel.text = @"Test H5 Page";
        _testLabel.font = [UIFont systemFontOfSize:24];
        _testLabel.textColor = [UIColor blackColor];
    }
    [_testLabel sizeToFit];
    CGPoint center = _testLabel.center;
    center.x = [UIScreen mainScreen].bounds.size.width / 2.0;
    center.y = [UIScreen mainScreen].bounds.size.height / 2.0;
    return _testLabel;
}

- (UIButton *)testBtn
{
    if (!_testBtn) {
        _testBtn = [[UIButton alloc] init];
        [_testBtn setTitle:@"点击下载" forState:UIControlStateNormal];
        [_testBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
    return _testBtn;
}

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (UIButton *)pauseBtn
{
    if (!_pauseBtn) {
        _pauseBtn = [[UIButton alloc] init];
        [_pauseBtn setTitle:@"暂停按钮" forState:UIControlStateNormal];
        [_pauseBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
    return _pauseBtn;
}

@end
