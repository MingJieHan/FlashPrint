//
//  NSFlashPrinterSettingView.h
//  FlashPrintServer
//
//  Created by Hans on 2025/4/28.
//

#import <Cocoa/Cocoa.h>
#import "FlashPrinter.h"

NS_ASSUME_NONNULL_BEGIN
@interface NSFlashPrinterSettingView : NSView
@property (nonatomic) FlashPrinter *printer;
@property (nonatomic) IBOutlet NSButton *saveButton;
@property (nonatomic) IBOutlet NSButton *cancelButton;
@property (nonatomic) IBOutlet NSComboBox *printerNameComboBox;
@property (nonatomic) IBOutlet NSComboBox *printerPaperComboBox;
@property (nonatomic) IBOutlet NSImageView *sourceImageView;
@property (nonatomic) IBOutlet NSImageView *previewImageView;
@property (nonatomic) IBOutlet NSTextField *saturationLabel;
@property (nonatomic) IBOutlet NSSlider *saturationSlider;
@property (nonatomic) IBOutlet NSTextField *brightLabel;
@property (nonatomic) IBOutlet NSSlider *brightSlider;
@property (nonatomic) IBOutlet NSTextField *contrastLabel;
@property (nonatomic) IBOutlet NSSlider *contrastSlider;


@property (nonatomic) IBOutlet NSSegmentedControl *watermarkSeg;
@property (nonatomic) IBOutlet NSButton *watermarkButton;
@property (nonatomic) IBOutlet NSImageView *watermarkPreview;
@property (nonatomic) IBOutlet NSSlider *watermarkHeightSlider;

-(IBAction)watermarkButtonAction:(id)sender;
-(IBAction)watermarkSegAction:(id)sender;
-(IBAction)watermarkSliderChanged:(id)sender;

-(IBAction)sliderChanged:(id)sender;
-(IBAction)resetAction:(id)sender;

-(IBAction)saveAction:(id)sender;
-(IBAction)cancelAction:(id)sender;
@end
NS_ASSUME_NONNULL_END
