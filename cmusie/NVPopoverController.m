#import "NVPopoverController.h"
#import "NVAppDelegate.h"

@interface NVPopoverController ()

@property (strong, nonatomic) NSTimer *updateTimer;

@end

@implementation NVPopoverController

+ (NVPopoverController *)create {
    return [[NVPopoverController alloc] initWithNibName:@"NVPopoverViewController" bundle:NULL];
}

- (void)viewDidAppear {
    [NSApp activateIgnoringOtherApps:YES];
    [self updateUI];

    self.updateTimer = [NSTimer timerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updateUI];
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSDefaultRunLoopMode];
}

- (void)viewDidDisappear {
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
}

- (NVAppDelegate*)delegate {
    return (NVAppDelegate*)NSApp.delegate;
}

- (void)updateUI {
    NSDictionary *status = [[self delegate] playerStatus];
    
    self.fieldTitle.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"title"] ?: @"...";
    self.fieldArtist.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"artist"] ?: @"...";
    
    // Update album artwork
    NSString *filePath = status[@"file"];
    if (filePath.length > 0) {
        NSString *directory = [filePath stringByDeletingLastPathComponent];
        NSArray *artworkFiles = @[@"cover.jpg", @"cover.png", @"folder.jpg", @"folder.png", @"album.jpg", @"album.png"];
        
        NSImage *artwork = nil;
        for (NSString *artFile in artworkFiles) {
            NSString *artPath = [directory stringByAppendingPathComponent:artFile];
            if ([[NSFileManager defaultManager] fileExistsAtPath:artPath]) {
                artwork = [[NSImage alloc] initWithContentsOfFile:artPath];
                if (artwork) break;
            }
        }
        
        self.albumArtView.image = artwork ?: [NSImage imageNamed:@"NSImageNameApplicationIcon"];
    } else {
        self.albumArtView.image = [NSImage imageNamed:@"NSImageNameApplicationIcon"];
    }
    
    switch ([[self delegate] mediaKeysStatus]) {
        case MediaKeyStatusUnaccessible:
            [self.btnLock setImage:[NSImage imageNamed:@"unlock"]];
            break;
        case MediaKeyStatusEnabled:
            [self.btnLock setImage:[NSImage imageNamed:@"unlink"]];
            break;
        case MediaKeyStatusDisabled:
            [self.btnLock setImage:[NSImage imageNamed:@"link"]];
            break;
    }
    
    BOOL running = [status[@"running"] boolValue];
    self.btnPrev.enabled = running;
    self.btnNext.enabled = running;
    self.btnPlay.enabled = running;
    
    NSString* image = [status[@"playing"] boolValue] ? @"pause" : @"play";
    [self.btnPlay setImage:[NSImage imageNamed:image]];
}

- (IBAction)handlePrev:(id)sender {
    [[self delegate] playerPrev];
    [self updateUI];
}

- (IBAction)handleNext:(id)sender {
    [[self delegate] playerNext];
    [self updateUI];
}

- (IBAction)handlePlayToggle:(id)sender {
    [[self delegate] playerToggle];
    [self updateUI];
}

- (IBAction)handleMediaKeysUnlock:(id)sender {
    switch ([[self delegate] mediaKeysStatus]) {
        case MediaKeyStatusUnaccessible:
            [[self delegate] mediaKeysUnlock];
            break;
        case MediaKeyStatusEnabled:
            [[self delegate] mediaKeysStop];
            [self updateUI];
            break;
        case MediaKeyStatusDisabled:
            [[self delegate] mediaKeysStart];
            [self updateUI];
            break;
    }

}

@end
