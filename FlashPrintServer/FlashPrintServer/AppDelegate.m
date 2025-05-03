//
//  AppDelegate.m
//  FlashPrintServer
//
//  Created by Hans on 2025/4/25.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate
#pragma mark - System
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    return;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    [[NSApp windows].firstObject makeKeyAndOrderFront:self];
    return YES;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}


@end
