//
//  PSRPiterDreamScene.m
//  HarryGuy
//
//  Created by n.shubenkov on 17/10/14.
//  Copyright 2014 n.shubenkov. All rights reserved.
//

#import "PSRPiterDreamScene.h"

@interface PSRPiterDreamScene() {

    CCSprite *_topBackground1;
    CCSprite *_topBackground2;
    
    CCSprite *_bottomBackground1;
    CCSprite *_bottomBackground2;
}

@end


@implementation PSRPiterDreamScene

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    self.userInteractionEnabled = YES;
//    [self setupLabels];
    [self setupBackgrounds];
//    [self setupPhysics];
//    [self setupButtons];
//    [self setupPlayer];
    // done
    return self;
}

#pragma mark - Update

- (void)update:(CCTime)delta
{
    static const CGFloat piterSpeed = 100;
    
    [self scrollButtomBackgroundsOnDelta:delta * piterSpeed];
    [self scrollTopBackgroundsOnDelta:delta    * piterSpeed / 3];
}

#pragma mark - Scroll Backgrounds

- (void)scrollButtomBackgroundsOnDelta:(CGFloat)delta
{
    _bottomBackground1.position = ccp( _bottomBackground1.position.x - delta, _bottomBackground1.position.y );
    _bottomBackground2.position = ccp( _bottomBackground2.position.x - delta, _bottomBackground2.position.y );
    
    if ( _bottomBackground1.position.x < -[_bottomBackground1 boundingBox].size.width ){
        _bottomBackground1.position = ccp(_bottomBackground2.position.x + [_bottomBackground2 boundingBox].size.width, _bottomBackground2.position.y );
    }
    
    if ( _bottomBackground2.position.x < -[_bottomBackground2 boundingBox].size.width ){
        _bottomBackground2.position = ccp(_bottomBackground1.position.x + [_bottomBackground1 boundingBox].size.width, _bottomBackground1.position.y );
    }
}

- (void)scrollTopBackgroundsOnDelta:(CGFloat)delta
{
    _topBackground1.position = ccp( _topBackground1.position.x - delta, _topBackground1.position.y );
    _topBackground2.position = ccp( _topBackground2.position.x - delta, _topBackground2.position.y );
    
    if ( _topBackground1.position.x < -[_topBackground1 boundingBox].size.width ){
        _topBackground1.position = ccp(_topBackground2.position.x + [_topBackground2 boundingBox].size.width, _topBackground2.position.y );
    }
    
    if ( _topBackground2.position.x < -[_topBackground2 boundingBox].size.width ){
        _topBackground2.position = ccp(_topBackground1.position.x + [_topBackground1 boundingBox].size.width, _topBackground1.position.y );
    }
}


#pragma mark - Setup

- (void)setupBackgrounds
{
    CCNodeColor *backgroundColor = [CCNodeColor nodeWithColor:[CCColor colorWithRed:123/255.0
                                                                              green:205/255.0
                                                                               blue:246/255.0]];
    [self addChild:backgroundColor];
    
    _topBackground1 = [CCSprite spriteWithImageNamed:@"sky.png"];
    _topBackground1.anchorPoint  = ccp(0, 0);
    _topBackground1.position     = ccp(0, self.contentSize.height - _topBackground1.contentSize.height);
    [self addChild:_topBackground1];
    
    _topBackground2 = [CCSprite spriteWithImageNamed:@"sky.png"];
    _topBackground2.anchorPoint  = ccp(0, 0);
    _topBackground2.position     = ccp(_topBackground2.contentSize.width, self.contentSize.height - _topBackground2.contentSize.height - 40);
    [self addChild:_topBackground2];
    
    _bottomBackground1 = [CCSprite spriteWithImageNamed:@"lake.png"];
    _bottomBackground1.anchorPoint = ccp(0, 0);
    _bottomBackground1.position    = ccp(0, 0);
    [self addChild:_bottomBackground1];
    
    _bottomBackground2 = [CCSprite spriteWithImageNamed:@"lake.png"];
    _bottomBackground2.anchorPoint = ccp(0, 0);
    _bottomBackground2.position    = ccp(_bottomBackground2.contentSize.width, 0);
    [self addChild:_bottomBackground2];
}




@end
