//
//  ViewController.m
//  FlashPrintServer
//
//  Created by Hans on 2025/4/25.
//
#import "NSImageTools.h"
#import "ViewController.h"
#import "FlashPrinterService.h"
#import "FlashPrintTask.h"
#import "NSFlashPrinterSettingView.h"
#import "FlashPrinterService.h"
#import "FlashPrintModel.h"
#import "FlashPrinter.h"


typedef NS_OPTIONS(NSUInteger, FlashPrintStatus) {
    FlashPrintStatus_None                   = 0,
    FlashPrintStatus_Ready                  = 1,
    FlashPrintStatus_GetTaskList            = 2,
    FlashPrintStatus_GetTask                = 3,
    FlashPrintStatus_Downloading            = 6,
    FlashPrintStatus_Fixing                 = 7,
    FlashPrintStatus_TaskPrinting           = 4,
    FlashPrintStatus_SetTaskResult          = 5
} API_AVAILABLE(macos(10.10));


@interface ViewController(){
    NSMutableString *logString;
    NSButton *panelButton;
    FlashPrintStatus status;
    BOOL pauseWorking;
    FlashPrinter *currentPrinter;
}
@property (nonatomic) IBOutlet NSTextView *logsView;
@property (nonatomic) IBOutlet NSButton *controlButton;
@property (nonatomic) IBOutlet NSButton *settingsButton;
@property (nonatomic) IBOutlet NSTextField *serverField;
@property (nonatomic) IBOutlet NSTextField *printerInfoLabel;
@end

@implementation ViewController
@synthesize logsView;
@synthesize controlButton, settingsButton;
@synthesize serverField;
@synthesize printerInfoLabel;
-(void)appendLog:(NSString *)logText{
    if (nil == logString){
        logString = [[NSMutableString alloc] init];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self->logsView.string = [self->logsView.string stringByAppendingFormat:@"\n%@", logText];
        NSRange range = NSMakeRange(self->logsView.string.length, 0);
        [self->logsView scrollRangeToVisible:range];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    controlButton.enabled = NO;
}

#define BUTTON_TITLE_START @"Start"
#define BUTTON_TITLE_PAUSE @"Pause"

-(void)tellServerResult:(BOOL)result withTask:(FlashPrintTask *)task{
    status = FlashPrintStatus_SetTaskResult;
    [FlashPrinterService task:task.task_id print:result withHandler:^(BOOL success, NSString * _Nullable errorReason) {
        if (success){
            [self appendLog:@"服务器任务状态已修改."];
        }else{
            [self appendLog:@"服务器修改任务失败"];
        }
        self->status = FlashPrintStatus_None;
    }];
    return;
}

-(void)printTask:(FlashPrintTask *)task{
    status = FlashPrintStatus_TaskPrinting;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSImage *image = task.fixedImage;
        NSLog(@"Image size :%.0f x %.0f", image.size.width, image.size.height);
        NSImageView *view = [[NSImageView alloc] initWithFrame:NSMakeRect(0.f, 0.f, image.size.width, image.size.height)];
        [view setImage:image];

        if (self->currentPrinter.watermark){
            //add wartermark into view.
            [self appendLog:@"给图片加上水印。"];
            NSImage *waterImage = [[NSImage alloc] initWithData:self->currentPrinter.watermark];
            NSImageView *waterView = [[NSImageView alloc] init];
            waterView.image = waterImage;
            float y = 0.f;
            float height = view.frame.size.height * self->currentPrinter.watermarkHeight;
            switch ([self->currentPrinter.watermarkAlignment integerValue]) {
                case 0:
                    y = view.frame.size.height-height;
                    waterView.imageAlignment = NSImageAlignTopLeft;
                    break;
                case 1:
                    y = view.frame.size.height-height;
                    waterView.imageAlignment = NSImageAlignTopRight;
                    break;
                case 2:
                    y = 0.f;
                    waterView.imageAlignment = NSImageAlignTopLeft;
                    break;
                case 3:
                    y = 0.f;
                    waterView.imageAlignment = NSImageAlignTopRight;
                    break;
                default:
                    break;
            }
            [waterView setFrame:NSMakeRect(0.f, y, view.frame.size.width, height)];
            [view addSubview:waterView];
        }
        NSString *errorReason = nil;
        NSSize paperSize = NSMakeSize(self->currentPrinter.paperWidth, self->currentPrinter.paperHeight);
        BOOL success = [NSImageTools printWithView:view
                                   withPrinterName:self->currentPrinter.name
                                     withPaperName:self->currentPrinter.paperName
                                     withPaperSize:paperSize
                                       withJobName:@"自动打印"
                                         withError:&errorReason
                                         withPanel:NO];
        if (success){
            [self appendLog:@"打印成功."];
        }else{
            [self appendLog:@"打印失败."];
        }
        [self tellServerResult:success withTask:task];
    });
    return;
}

-(void)fixImage:(FlashPrintTask *)task{
    status = FlashPrintStatus_Fixing;
    task.image = [[NSImage alloc] initWithData:task.imageData];
    if (nil == task.image){
        NSLog(@"init image failed.");
        return;
    }
    task.fixedImage = [NSImageTools adjustSaturationOfImage:task.image saturation:currentPrinter.saturation bright:currentPrinter.bright contrast:currentPrinter.contrast];
    [self appendLog:@"修正图片完成"];
    [self printTask:task];
}

-(void)prepareTask:(FlashPrintTask *)task{
    //下载图片到本地
    status = FlashPrintStatus_Downloading;
    [FlashPrinterService downloadImageForTask:task.image_urlString withHandler:^(NSData * _Nullable imageData, NSString * _Nullable errorReason) {
        if (imageData){
            [self appendLog:@"下载图片成功"];
            task.imageData = imageData;
            [self fixImage:task];
        }else{
            
            [self appendLog:[NSString stringWithFormat:@"download image failed:%@", errorReason]];
            self->status = FlashPrintStatus_None;
        }
        return;
    }];
    return;
}

-(void)requestTask:(FlashPrintTask *)task{
    status = FlashPrintStatus_GetTask;
    [FlashPrinterService taskRequestPrinting:task.task_id withHandler:^(BOOL success, NSString * _Nullable errorReason) {
        if (success){
            [self appendLog:@"task status is printing, let print action in this thread."];
            [self prepareTask:task];
        }else{
            self->status = FlashPrintStatus_None;
            [self appendLog:[NSString stringWithFormat:@"request print the task, but failed. reason:%@", errorReason]];
        }
        return;
    }];
    return;
}

-(void)workingLoop{
    if (pauseWorking){
        [self appendLog:@"打印任务已终止."];
        return;
    }
    if (status == FlashPrintStatus_None){
        //check working
        [self appendLog:@"从服务器寻找打印任务..."];
        status = FlashPrintStatus_GetTaskList;
        [FlashPrinterService taskListWithHandler:^(NSArray * _Nullable tasks) {
            if (tasks.count > 0){
                FlashPrintTask *task = [[FlashPrintTask alloc] initWithDictionary:tasks.firstObject];
                [self requestTask:task];
            }else{
                [self appendLog:@"无打印任务"];
                self->status = FlashPrintStatus_None;
            }
            return;
        }];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(workingLoop) userInfo:nil repeats:NO];
    return;
}

-(IBAction)controlAction:(id)sender{
    serverBaseURL = serverField.stringValue;
    if (nil == serverBaseURL || serverBaseURL.length < 6){
        [self appendLog:@"Server URL NOT available."];
        return;
    }
    while ([[serverBaseURL substringFromIndex:serverBaseURL.length-1] isEqualToString:@"/"]){
        serverBaseURL = [serverBaseURL substringToIndex:serverBaseURL.length-1];
    }
    
    if ([controlButton.title isEqualToString:BUTTON_TITLE_START]){
        //start work
        controlButton.title = BUTTON_TITLE_PAUSE;
        pauseWorking = NO;
        serverBaseURL = serverField.stringValue;
        serverField.enabled = NO;
        settingsButton.enabled = NO;
        [self workingLoop];
        return;
    }
    
    if ([controlButton.title isEqualToString:BUTTON_TITLE_PAUSE]){
        //stop work
        pauseWorking = YES;
        controlButton.title = BUTTON_TITLE_START;
        serverField.enabled = YES;
        settingsButton.enabled = YES;
    }
    return;
}

-(IBAction)settingsAction:(id)sender{
    NSWindowController *wC = [[NSWindowController alloc] initWithWindowNibName:@"NSFlashPrinterSetting"];
    [wC showWindow:nil];
    return;
}

-(void)refreshItems{
    serverField.stringValue = [FlashPrinterService loadLastServer];
    currentPrinter = [FlashPrintModel.shared currentPrinter];
    printerInfoLabel.stringValue = [currentPrinter description];
    
    controlButton.title = BUTTON_TITLE_START;
    if (currentPrinter){
        controlButton.enabled = YES;
    }else{
        controlButton.enabled = NO;
    }
    return;
}

-(void)viewDidAppear{
    [super viewDidAppear];
    NSLog(@"Home:%@", NSHomeDirectory());
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refreshItems) name:NSWindowDidBecomeMainNotification object:self.view.window];
    [self refreshItems];
    return;
}
@end
