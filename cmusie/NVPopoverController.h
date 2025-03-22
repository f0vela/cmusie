#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NVPopoverController : NSViewController

+ (NVPopoverController*)create;


@property (weak) IBOutlet NSTextField *fieldTitle;
@property (weak) IBOutlet NSTextField *fieldArtist;

@property (weak) IBOutlet NSButton *btnPrev;
@property (weak) IBOutlet NSButton *btnNext;
@property (weak) IBOutlet NSButton *btnPlay;
@property (weak) IBOutlet NSButton *btnLock;
@property (weak) IBOutlet NSImageView *albumArtView;

@end

NS_ASSUME_NONNULL_END
