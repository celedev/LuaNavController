//
//  CIMAppDelegate.m
//  TouchCells
//
//  Created by Jean-Luc on 03/04/13.
//  Copyright (c) 2013 Celedev. All rights reserved.
//

#import "CIMAppDelegate.h"

#import "CIMLua/CIMLua.h"
#import "CIMLua/CIMLuaContextMonitor.h"

@implementation CIMAppDelegate
{
    CIMLuaContext* _collectionLuaContext;
    CIMLuaContextMonitor* _collectionLuaContextMonitor;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create a Lua Context for this application
    _collectionLuaContext = [[CIMLuaContext alloc] initWithName:@"Main" mainSourcePackageId:@"fruit_basket"];
    _collectionLuaContextMonitor = [[CIMLuaContextMonitor alloc] initWithLuaContext:_collectionLuaContext connectionTimeout:5];
    
    // Create the application window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // Run the code for this Lua context
    [_collectionLuaContext loadLuaModuleNamed:@"CheckerTableController" withCompletionBlock:^(Class viewControllerClass) {
        
        if ([viewControllerClass isSubclassOfClass:[UIViewController class]] && 
            (viewControllerClass != [self.navController.viewControllers.firstObject class]))
        {
            [self.navController setViewControllers:@[ [viewControllerClass new] ] animated:YES];
        }
        
    }];
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
