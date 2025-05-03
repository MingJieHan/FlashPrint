//
//  NSFlashPrinterSettingView.m
//  FlashPrintServer
//
//  Created by Hans on 2025/4/28.
//
#import <CoreServices/CoreServices.h>
#import "NSFlashPrinterSettingView.h"
#import "NSImageTools.h"
#import "FlashPrintModel.h"

@interface NSFlashPrinterSettingView()<NSComboBoxDelegate>{
    CFArrayRef printerList;
    FlashPrinter *currentPrinter;
}
@end

@implementation NSFlashPrinterSettingView
@synthesize printer;
@synthesize sourceImageView,previewImageView;
@synthesize saveButton,cancelButton;
@synthesize printerNameComboBox,printerPaperComboBox;
@synthesize saturationLabel,brightLabel,contrastLabel;
@synthesize saturationSlider,brightSlider,contrastSlider;
@synthesize watermarkSeg, watermarkButton, watermarkPreview, watermarkHeightSlider;

-(id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self){
        printerList = NULL;
    }
    return self;
}


-(void)setPrinter:(FlashPrinter *)printer{
    currentPrinter = printer;
    printerNameComboBox.stringValue = currentPrinter.name;
    printerPaperComboBox.stringValue = [NSString stringWithFormat:@"%@ (%.1f x %.1f)", currentPrinter.paperName, currentPrinter.paperWidth, currentPrinter.paperHeight];

    saturationSlider.floatValue = currentPrinter.saturation;
    brightSlider.floatValue = currentPrinter.bright;
    contrastSlider.floatValue = currentPrinter.contrast;
    
    if (currentPrinter.watermark){
        watermarkPreview.image = [[NSImage alloc] initWithData:currentPrinter.watermark];
        watermarkButton.title = @"移除水印";
    }else{
        watermarkPreview.image = nil;
        watermarkButton.title = @"选择水印";
    }
    [watermarkSeg setSelectedSegment:[currentPrinter.watermarkAlignment integerValue]];
    watermarkHeightSlider.floatValue = currentPrinter.watermarkHeight;
    
    [self refreshWatermark];
    [self reFreshPreview];
    return;
}

//return default printer.
-(PMPrinter)freshPrinterInfo{
    //Printer start
    printerNameComboBox.delegate = self;
    [printerNameComboBox removeAllItems];
    NSPrintInfo *info = NSPrintInfo.sharedPrintInfo;
    PMPrintSession session = [info PMPrintSession];
    
    printerList = NULL;
    OSStatus status = PMServerCreatePrinterList(NULL, &printerList);
    if (status != noErr || printerList == NULL){
        return nil;
    }
    
    PMPrinter defaultPrinter = NULL;
    PMSessionGetCurrentPrinter(session, &defaultPrinter);
    NSString *defaultPrinterName = (__bridge NSString *)PMPrinterGetName(defaultPrinter);
    
    CFIndex selectedIndex = 0;
    CFIndex count = CFArrayGetCount(printerList);
    for (CFIndex i=0;i<count;i++){
        PMPrinter printer = (PMPrinter)CFArrayGetValueAtIndex(printerList, i);
        NSString *printerName = (__bridge NSString *)PMPrinterGetName(printer);
        [printerNameComboBox addItemWithObjectValue:printerName];
        if ([printerName isEqualToString:defaultPrinterName]){
            selectedIndex = i;
        }
    }
    //set Default printer as selected
    [printerNameComboBox selectItemWithObjectValue:defaultPrinterName];
    return defaultPrinter;
}

-(void)freshPaperInfoWithPrinter:(PMPrinter)selectedPrinter{
    //Paper start
    printerPaperComboBox.delegate = self;
    [printerPaperComboBox removeAllItems];
    CFArrayRef paperList = NULL;
    PMPrinterGetPaperList(selectedPrinter, &paperList);
    
    
    CFIndex paperCount = CFArrayGetCount(paperList);
    int selectedIndex = 0;
    for (int index=0;index < paperCount; index++){
        PMPaper paper = (PMPaper)CFArrayGetValueAtIndex(paperList, index);
        CFStringRef paperName = NULL;
        double paperHeight = 0.f;
        double paperWidth = 0.f;
        PMPaperGetPPDPaperName(paper, &paperName);
        PMPaperGetHeight(paper, &paperHeight);
        PMPaperGetWidth(paper, &paperWidth);
        [printerPaperComboBox addItemWithObjectValue:[NSString stringWithFormat:@"%@ (%.1f x %.1f)", paperName, paperWidth, paperHeight]];

        if ([currentPrinter.paperName isEqualToString:(__bridge NSString *)paperName]){
            selectedIndex = index;
        }
    }
    [printerPaperComboBox selectItemAtIndex:selectedIndex];
    return;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (nil == sourceImageView.image){
        printerNameComboBox.editable = NO;
        printerPaperComboBox.editable = NO;
        
        
        sourceImageView.layer.backgroundColor = [NSColor separatorColor].CGColor;
        sourceImageView.image = [[NSImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"test" ofType:@"png"]];
        previewImageView.image = sourceImageView.image;
        previewImageView.layer.backgroundColor = [NSColor separatorColor].CGColor;
        
        saturationSlider.minValue = -10.f;
        saturationSlider.maxValue = 10.f;
        saturationSlider.floatValue = 1.f;
        saturationLabel.stringValue = @"";
        
        brightSlider.minValue = -1.f;
        brightSlider.maxValue = 1.f;
        brightSlider.floatValue = 0.f;
        brightLabel.stringValue = @"";
        
        contrastSlider.minValue = 0.f;
        contrastSlider.maxValue = 4.f;
        contrastSlider.floatValue = 1.f;
        contrastLabel.stringValue = @"";
        
        PMPrinter defaultPrinter = [self freshPrinterInfo];
        [self freshPaperInfoWithPrinter:defaultPrinter];
        
        //Watermark start
        watermarkPreview.layer.backgroundColor = [NSColor separatorColor].CGColor;
        watermarkHeightSlider.minValue = 0.0f;
        watermarkHeightSlider.maxValue = 0.2f;
        
        NSArray *printers = [FlashPrintModel.shared existPrinters];
        if (printers.count > 0){
            self.printer = printers.firstObject;
        }
    }else{
        [self refreshWatermark];
    }
    return;
}

-(void)reFreshPreview{
    NSImage *sourceImage = [NSImageTools adjustSaturationOfImage:sourceImageView.image
                                                 saturation:saturationSlider.floatValue
                                                     bright:brightSlider.floatValue
                                                   contrast:contrastSlider.floatValue];
    saturationLabel.stringValue = [NSString stringWithFormat:@"%.2f", saturationSlider.floatValue];
    brightLabel.stringValue = [NSString stringWithFormat:@"%.2f", brightSlider.floatValue];
    contrastLabel.stringValue = [NSString stringWithFormat:@"%.2f", contrastSlider.floatValue];
    previewImageView.image = sourceImage;
    return;
}

-(IBAction)sliderChanged:(id)sender{
    NSLog(@"Saturation:%.2f, Bright:%.2f, Contrast:%.2f", saturationSlider.floatValue, brightSlider.floatValue, contrastSlider.floatValue);
    [self reFreshPreview];
    return;
}

-(IBAction)resetAction:(id)sender{
    saturationSlider.floatValue = 1.f;
    brightSlider.floatValue = 0.f;
    contrastSlider.floatValue = 1.f;
    [self reFreshPreview];
}

-(IBAction)saveAction:(id)sender{
    if (nil == currentPrinter){
        currentPrinter = [FlashPrintModel.shared createFlashPrinter];
    }
    currentPrinter.name = printerNameComboBox.stringValue;
    NSString *ss = printerPaperComboBox.stringValue;
    char name[100];
    float width;
    float height;
    sscanf([ss UTF8String], "%s (%f x %f)", name, &width, &height);
    currentPrinter.paperName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    currentPrinter.paperWidth = width;
    currentPrinter.paperHeight = height;
    currentPrinter.saturation = saturationSlider.floatValue;
    currentPrinter.bright = brightSlider.floatValue;
    currentPrinter.contrast = contrastSlider.floatValue;
    if (watermarkPreview.image){
        currentPrinter.watermark = watermarkPreview.image.TIFFRepresentation;
    }else{
        currentPrinter.watermark = nil;
    }
    currentPrinter.watermarkAlignment = [NSNumber numberWithInteger:watermarkSeg.indexOfSelectedItem];
    currentPrinter.watermarkHeight = watermarkHeightSlider.floatValue;
    
    [FlashPrintModel.shared save];
    [self.window orderOut:nil];
    return;
}

-(IBAction)cancelAction:(id)sender{
    [self.window orderOut:nil];
    return;
}

-(IBAction)watermarkButtonAction:(id)sender{
    if (watermarkPreview.image){
        //remove exist watermark
        watermarkPreview.image = nil;
        watermarkButton.title = watermarkButton.title = @"选择水印";
    }else{
        //select file for the watermark
        NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
        openPanel.title = @"Choose a File";
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        openPanel.allowedFileTypes = @[ @"png" ];
#pragma clang diagnostic pop
        
        openPanel.canChooseDirectories = false;
        openPanel.canChooseFiles = true;
        openPanel.allowsMultipleSelection = false;
        NSModalResponse res = [openPanel runModal];
        if (1 == res){
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:openPanel.URL];
            if (nil == image){
                NSLog(@"open watermark failed:%@", openPanel.URL);
            }else{
                watermarkPreview.image = image;
            }
        }
    }
    return;
}

-(void)refreshWatermark{
    float x = previewImageView.frame.origin.x;
    float y = previewImageView.frame.origin.y;
    float width = previewImageView.frame.size.width;
    float height = previewImageView.frame.size.height;
    switch (watermarkSeg.selectedSegment) {
        case 0:
            watermarkPreview.imageAlignment = NSImageAlignLeft;
            y += height * (1.f - watermarkHeightSlider.floatValue);
            break;
        case 1:
            watermarkPreview.imageAlignment = NSImageAlignRight;
            y += height * (1.f - watermarkHeightSlider.floatValue);
            break;
        case 2:
            watermarkPreview.imageAlignment = NSImageAlignLeft;
            break;
        case 3:
            watermarkPreview.imageAlignment = NSImageAlignRight;
            break;
        default:
            break;
    }
    [watermarkPreview setFrame:NSMakeRect(x, y, width, height * watermarkHeightSlider.floatValue)];
    return;
}

-(IBAction)watermarkSegAction:(id)sender{
    [self refreshWatermark];
    return;
}

-(IBAction)watermarkSliderChanged:(id)sender{
    [self refreshWatermark];
    return;
}


-(void)dealloc{
    CFRelease(printerList);
}

#pragma mark - NSComboBoxDelegate
- (void)comboBoxSelectionDidChange:(NSNotification *)notification NS_SWIFT_UI_ACTOR{
    if (printerNameComboBox == notification.object){
        if (nil == printerList){
            return;
        }
//        CFIndex count = CFArrayGetCount(printerList);
        PMPrinter selectedPrinter = (PMPrinter)CFArrayGetValueAtIndex(printerList, printerNameComboBox.indexOfSelectedItem);
        [self freshPaperInfoWithPrinter:selectedPrinter];
        return;
    }
    if (printerPaperComboBox == notification.object){
        return;
    }
    return;
}
@end
