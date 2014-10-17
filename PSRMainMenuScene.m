//
//  PSRMainMenuScene.m
//  HarryGuy
//
//  Created by n.shubenkov on 17/10/14.
//  Copyright 2014 n.shubenkov. All rights reserved.
//

#import "PSRMainMenuScene.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCDirector.h"
#import "PSRPiterDreamScene.h"

@implementation PSRMainMenuScene

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    CCNodeColor * backgroundColor = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
    [self addChild:backgroundColor];
    
    CCSprite *backgroundImage = [CCSprite spriteWithImageNamed:@"menu@2x.jpg"];
    [backgroundImage setTextureRect:CGRectMake(0, 0, 640, 480)];
    backgroundImage.anchorPoint = CGPointZero;
    backgroundImage.position    = CGPointZero;
    [self addChild:backgroundImage];
    
    // Hello world
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"HungryPeter"
                                           fontName:@"Chalkduster"
                                           fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    //    ccp = CGPointMake(0.5, 0.38);
    label.position = ccp(0.5f, 0.38f); // Middle of screen
    [self addChild:label];
    
    // Helloworld scene button
    CCButton *helloWorldButton = [CCButton buttonWithTitle:@"[ Start ]"
                                                  fontName:@"Chalkduster"
                                                  fontSize:18.0f];
    helloWorldButton.color = [CCColor blackColor];
    [helloWorldButton setLabelColor:[CCColor lightGrayColor]
                           forState:CCControlStateHighlighted];
    helloWorldButton.positionType = CCPositionTypeNormalized;
    helloWorldButton.position = ccp(0.5f, 0.28f);
    
    [helloWorldButton setTarget:self
                       selector:@selector(onStartClicked:)];
    
    [self addChild:helloWorldButton];
    
    CCButton *aboutButton = [CCButton buttonWithTitle:@"[ About ]"
                                             fontName:@"Chalkduster"
                                             fontSize:18.0f];
    
    aboutButton.color = [CCColor blackColor];
    [aboutButton setLabelColor:[CCColor lightGrayColor]
                      forState:CCControlStateHighlighted];
    aboutButton.positionType = CCPositionTypeNormalized;
    aboutButton.position     = ccp(0.5f, 0.2f);
    
    [aboutButton setTarget:self
                  selector:@selector(onAboutClicked:)];
    
    [self addChild:aboutButton];
    
    CCButton *hightScoreButton = [CCButton buttonWithTitle:@"[ HighScore ]"
                                                  fontName:@"Chalkduster"
                                                  fontSize:18.0f];
    
    hightScoreButton.color = [CCColor blackColor];
    [hightScoreButton setLabelColor:[CCColor lightGrayColor]
                           forState:CCControlStateHighlighted];
    hightScoreButton.positionType = CCPositionTypeNormalized;
    hightScoreButton.position     = ccp(0.5f, 0.12f);
    
    [hightScoreButton setTarget:self
                       selector:@selector(onHighScoreClicked:)];
    
    [self addChild:hightScoreButton];
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    [[OALSimpleAudio sharedInstance] playBg:@"disco song.mp3"
                                     volume:1
                                        pan:0
                                       loop:0];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------
- (void)onStartClicked:(CCButton *)aButton
{
    [[CCDirector sharedDirector]pushScene:[PSRPiterDreamScene new]
                           withTransition:[CCTransition transitionRevealWithDirection:CCTransitionDirectionRight
                                                                             duration:1.0]];
}

@end
