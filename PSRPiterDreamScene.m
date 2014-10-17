//
//  PSRPiterDreamScene.m
//  HarryGuy
//
//  Created by n.shubenkov on 17/10/14.
//  Copyright 2014 n.shubenkov. All rights reserved.
//

#import "PSRPiterDreamScene.h"

#import "CGPointExtension.h"

@interface PSRPiterDreamScene() {

    CCScene *_player;
    
    CCSprite *_topBackground1;
    CCSprite *_topBackground2;
    
    CCSprite *_bottomBackground1;
    CCSprite *_bottomBackground2;
    
    CCPhysicsNode *_physicalWorld;
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
    [self setupPhysics];
//    [self setupButtons];
    [self setupPlayer];
    // done
    return self;
}

- (void)setupPlayer
{
    _player = [CCSprite spriteWithImageNamed:@"PiterIcon.png"];
    _player.position    = ccp(self.contentSize.width / 2 , self.contentSize.height / 2);
    _player.anchorPoint = ccp(0.5,0.5);
    
    _player.physicsBody.mass = 100;
    _player.physicsBody.affectedByGravity = YES;
    _player.physicsBody.type = CCPhysicsBodyTypeStatic;
    _player.physicsBody      = [CCPhysicsBody bodyWithRect:(CGRect){ CGPointZero,_player.contentSize }
                                                            cornerRadius:15];
    //    _player.physicsBody.sensor         = YES;
//    _player.physicsBody.collisionGroup = kPSRPlayerCollisionGroupName;
//    _player.physicsBody.collisionType  = kPSRPlayerCollisionType;
//    
    [_physicalWorld addChild: _player];
}

- (void)setupPhysics
{
    _physicalWorld = [CCPhysicsNode node];
    _physicalWorld.gravity   = ccp(0, -350);
    //    _physicalWorld.debugDraw = YES;
//    _physicalWorld.collisionDelegate = self;
    [self addChild:_physicalWorld];
}

#pragma mark - Update

- (void)update:(CCTime)delta
{
    static const CGFloat piterSpeed = 100;
    
    [self updatePlayerRotation];
    
    [self scrollButtomBackgroundsOnDelta:delta * piterSpeed];
    [self scrollTopBackgroundsOnDelta:delta    * piterSpeed / 3];
}

- (void)updatePlayerRotation
{
    CGFloat rotateAngleKoeff =  _player.physicsBody.velocity.y / 3;
    if (rotateAngleKoeff < 0){
        rotateAngleKoeff = MAX(-90, rotateAngleKoeff);
    }
    else {
        rotateAngleKoeff = MIN(90, rotateAngleKoeff);
    }
    
    CCActionRotateBy *rotateAction = [[CCActionRotateBy alloc]initWithDuration:0.2
                                                                         angle:-rotateAngleKoeff / 2];
    [_player stopAllActions];
    [_player runAction:rotateAction];
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

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // -----------------------------------------------------------------------
#pragma mark - Touch Handler
    // -----------------------------------------------------------------------
    
    [_player.physicsBody applyForce:ccp(0,25000)];
}



@end
