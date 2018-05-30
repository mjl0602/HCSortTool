//
//  HCSortingToolUITests.m
//  HCSortingToolUITests
//
//  Created by 马嘉伦 on 2018/3/28.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface HCSortingToolUITests : XCTestCase

@end

@implementation HCSortingToolUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    /*
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [[[[app.otherElements containingType:XCUIElementTypeStaticText identifier:@"\U6df1\U5733\U5e02\U6d77\U8fb0\U914d\U9001\U6709\U9650\U516c\U53f8"] childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:0] tap];
    [app.navigationBars[@"\U6df1\U5733\U6d77\U8fb0\U914d\U9001\U4ed3\U50a8\U8d27\U7269\U5206\U62e3\U7cfb\U7edf"].buttons[@"Refresh"] tap];
    [app.alerts[@"\U84dd\U7259\U64cd\U4f5c"].buttons[@"\U91cd\U7f6e\U84dd\U7259\U8fde\U63a5"] tap];
    */
    
    
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
