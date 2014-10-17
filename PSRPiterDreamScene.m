//
//  PSRPiterDreamScene.m
//  HarryGuy
//
//  Created by n.shubenkov on 17/10/14.
//  Copyright 2014 n.shubenkov. All rights reserved.
//

#import "PSRPiterDreamScene.h"

#import "CGPointExtension.h"

#import "HighScoreScene.h"

#define kFLOOR_HEIGHT 0
#define kTUBES_ANIMATION_TIMER 2.0

NSString * const kPSRPlayerCollisionGroupName = @"PSRPlayerCollisionGroupName";
NSString * const kPSRDonutCollisionGroupName  = @"PSRDonutCollisionGroupName";
NSString * const kPSRPlayerCollisionType      = @"psr_player";
NSString * const kPSRDonutPointCollisionType  = @"psr_donut";

@interface PSRPiterDreamScene() {

    NSMutableArray *_donuts;
    NSMutableArray *_tubes;
    CCScene *_player;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_piterMassLabel;
    
    CCSprite *_topBackground1;
    CCSprite *_topBackground2;
    
    CCSprite *_bottomBackground1;
    CCSprite *_bottomBackground2;
    
    CCPhysicsNode *_physicalWorld;
}

@property (nonatomic) int score;

@end


@implementation PSRPiterDreamScene

- (void)setScore:(int)score
{
    _score = score;
    if (_score % 10 == 0){
        [[OALSimpleAudio sharedInstance]playEffect:@"PiterLaugh.m4a"];
        NSParameterAssert(_scoreLabel.parent == self);
    }
    [self p_updateScoreLabel];
}

- (void)p_updateScoreLabel
{
    _scoreLabel.string = [NSString stringWithFormat:@"score %d",_score];
}

- (void)p_updateMassLabel
{
    _piterMassLabel.string = [NSString stringWithFormat:@"%.2f kg", 100 + _player.physicsBody.mass * 10 - 10];
}

#pragma mark life cycle

- (void)onEnter
{
    [super onEnter];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addDonut];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addTubes:1.5];
    });
    [[OALSimpleAudio sharedInstance] playBg:@"Weird Bird song.mp3"
                                     volume:0.2
                                        pan:0
                                       loop:1];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    self.userInteractionEnabled = YES;
    [self setupLabels];
    [self setupBackgrounds];
    [self setupPhysics];
//    [self setupButtons];
    [self setupPlayer];
    // done
    return self;
}

- (void)setupLabels
{
    // Hello world
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"HungryPeter"
                                           fontName:@"Chalkduster"
                                           fontSize:16];
    label.positionType = CCPositionTypeNormalized;
    label.color        = [CCColor blackColor];
    //    ccp = CGPointMake(0.5, 0.38);
    label.position     = ccp(0.5f, 0.95); // Middle of screen
    _scoreLabel        = label;
    _scoreLabel.zOrder = 10;
    [self p_updateScoreLabel];
    [self addChild:label];
    
    CCLabelTTF *massLabel = [CCLabelTTF labelWithString:@""
                                               fontName:@"Chalkduster"
                                               fontSize:16];
    massLabel.positionType = CCPositionTypeNormalized;
    massLabel.color        = [CCColor blackColor];
    massLabel.position     = ccp(0.15f, 0.95); // Middle of screen
    _piterMassLabel        = massLabel;
    _piterMassLabel.zOrder = 10;
    [self p_updateMassLabel];
    [self addChild:massLabel];
    
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
    _player.physicsBody.collisionGroup = kPSRPlayerCollisionGroupName;
    _player.physicsBody.collisionType  = kPSRPlayerCollisionType;
//
    [_physicalWorld addChild: _player];
}

- (void)setupPhysics
{
    _physicalWorld = [CCPhysicsNode node];
    _physicalWorld.gravity   = ccp(0, -350);
    //    _physicalWorld.debugDraw = YES;
    _physicalWorld.collisionDelegate = self;
    [self addChild:_physicalWorld];
}

#pragma mark - dynamic object


- (void) addTubes:(CCTime)dt
{
    if (!self.visible){
        return;
    }
    if ( dt == 0.0f ) return;
    
    int max = 4;
    int rUp = arc4random() % max;
    if (rUp == 0) rUp++;
    
    [self addTubeBodies:rUp       up:YES];
    [self addTubeBodies:max - rUp up:NO ];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 + ((arc4random() % 300) / (300.0f + _score))  * 3.0f) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self addTubes:1];
    });
}

- (void) addTubeBodies:(int) body up:(BOOL)up
{
    int incrementalY = up ? 0 : self.contentSize.height - kFLOOR_HEIGHT;
    CGPoint bodyPos  = CGPointZero;
    int bodyTotalHeigth = 0;
    
    for ( int i=0; i<body; i++ )
    {
        CCSprite *tubeBody = [CCSprite spriteWithImageNamed: !up ? @"MarioTube_Body.png" : @"MarioTube_Body_Rev.png"];
        
        bodyPos =  CGPointMake(self.contentSize.width + tubeBody.contentSize.width/2 , self.contentSize.height - incrementalY);
        if ( up ) incrementalY += tubeBody.contentSize.height;
        else incrementalY -= tubeBody.contentSize.height;
        
        tubeBody.position                   = bodyPos;
        tubeBody.physicsBody                = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, tubeBody.contentSize} cornerRadius:0];
        tubeBody.physicsBody.type           = CCPhysicsBodyTypeStatic;
        tubeBody.physicsBody.collisionGroup = @"monsterGroup";
        tubeBody.physicsBody.collisionType  = @"monsterCollision";
        
        [_physicalWorld addChild:tubeBody];
        [_tubes addObject:tubeBody];
        CCAction *actionMoveBody   = [CCActionMoveTo actionWithDuration:kTUBES_ANIMATION_TIMER position:CGPointMake(-tubeBody.contentSize.width/2, tubeBody.position.y)];
        CCAction *actionRemoveBody = [CCActionRemove action];
        [tubeBody runAction:[CCActionSequence actionWithArray: @[actionMoveBody, actionRemoveBody] ]];
        
        bodyTotalHeigth += tubeBody.contentSize.height;
    }
    
    if ( up )
    {
        CCSprite *tubeUp                  = [CCSprite spriteWithImageNamed:@"MarioTubePlant_open_Rev.png"];
        
        tubeUp.position                   = CGPointMake(self.contentSize.width + tubeUp.contentSize.width/2, self.contentSize.height - incrementalY);// + tubeUp.contentSize.height / 2 );
        tubeUp.physicsBody                = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, tubeUp.contentSize} cornerRadius:0];
        tubeUp.physicsBody.type           = CCPhysicsBodyTypeStatic;
        tubeUp.physicsBody.collisionGroup = @"monsterGroup";
        tubeUp.physicsBody.collisionType  = @"monsterCollision";
        
        [_physicalWorld addChild:tubeUp];
        [_tubes addObject:tubeUp];
        CCAction *actionMoveUp   = [CCActionMoveTo actionWithDuration:kTUBES_ANIMATION_TIMER position:CGPointMake(-tubeUp.contentSize.width/2, tubeUp.position.y)];
        CCAction *actionRemoveUp = [CCActionRemove action];
        [tubeUp runAction:[CCActionSequence actionWithArray: @[actionMoveUp, actionRemoveUp] ]];
    }
    else
    {
        CCSprite *tubeDw = [CCSprite spriteWithImageNamed:@"MarioTube_Top.png"];
        
        tubeDw.position                   = CGPointMake(self.contentSize.width + tubeDw.contentSize.width/2, self.contentSize.height - incrementalY - tubeDw.contentSize.height/2);
        tubeDw.physicsBody                = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, tubeDw.contentSize} cornerRadius:0];
        tubeDw.physicsBody.type           = CCPhysicsBodyTypeStatic;
        tubeDw.physicsBody.collisionGroup = @"monsterGroup";
        tubeDw.physicsBody.collisionType  = @"monsterCollision";
        
        [_physicalWorld addChild:tubeDw];
        [_tubes addObject:tubeDw];
        CCAction *actionMoveDown   = [CCActionMoveTo actionWithDuration:kTUBES_ANIMATION_TIMER position:CGPointMake(-tubeDw.contentSize.width/2, tubeDw.position.y)];
        CCAction *actionRemoveDown = [CCActionRemove action];
        [tubeDw runAction:[CCActionSequence actionWithArray: @[actionMoveDown, actionRemoveDown] ]];
    }
    [self p_removeUnnecessaryTubes];
}

- (void)p_removeUnnecessaryTubes
{
    [NSPredicate predicateWithFormat:@"length < 5"];
    NSArray *strings = @[];
    [strings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length < 5"]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = NO", NSStringFromSelector(@selector(visible))];
    [[_tubes filteredArrayUsingPredicate:predicate] makeObjectsPerformSelector:@selector(removeFromParent)];
}

- (void)addDonut
{
    if (!self.visible){
        return;
    }
    CCSprite *aCoin = [self findFreeCoinOrCreateNew];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    aCoin.position  = ccp(screenWidth,
                          arc4random() % (int) ([[UIScreen mainScreen] bounds].size.height -
                                                aCoin.contentSize.height));
    
//    CGFloat x = (CGFloat) -(5000.0f + (arc4random() % 5000));
//    CGFloat y = (CGFloat) (((arc4random() % 2) == 0) ? (1) : (-1)) * (arc4random() % 5000);
    
    //    NSLog(@"x = %f y = %f",x, y);
    aCoin.physicsBody.force = CGPointMake(-5000,0);
    [_donuts addObject:aCoin];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addDonut];
    });
}


- (CCSprite *)findFreeCoinOrCreateNew
{
    CCSprite *vacantDonut;
    for (CCSprite *aCoin in _donuts){
        if (aCoin.position.x + aCoin.contentSize.width < 0){
            vacantDonut = aCoin;
            break;
        }
    }
    if (!vacantDonut){
        vacantDonut = [self createDonut];
    }
    vacantDonut.physicsBody.velocity = CGPointZero;
    vacantDonut.physicsBody.force    = CGPointZero;
    return vacantDonut;
}

- (CCSprite *)createDonut
{
    CCSprite *freeCoin = [CCSprite spriteWithImageNamed:@"donut_small.png"];
    freeCoin.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){
        CGPointZero,
        freeCoin.contentSize
    }
                                          cornerRadius:CGRectGetHeight(freeCoin.boundingBox) / 2];
    freeCoin.physicsBody.collisionGroup = kPSRDonutCollisionGroupName;
    freeCoin.physicsBody.collisionType  = kPSRDonutPointCollisionType;
    freeCoin.physicsBody.type           = CCPhysicsBodyTypeDynamic;
    freeCoin.physicsBody.mass           = 1;
    freeCoin.physicsBody.affectedByGravity = NO;
    [_donuts addObject:freeCoin];
    [_physicalWorld addChild:freeCoin];
    return freeCoin;
}

#pragma mark - Update

- (void)update:(CCTime)delta
{
    [self checkIfPlayerDropped];
    static const CGFloat piterSpeed = 100;
    
    [self updatePlayerRotation];
    [self helpPlayerToMoveToCenterOnDelta:delta];
    [self scrollButtomBackgroundsOnDelta:delta * piterSpeed];
    [self scrollTopBackgroundsOnDelta:delta    * piterSpeed / 3];
}

- (void)helpPlayerToMoveToCenterOnDelta:(CCTime)delta
{
    CGFloat force = self.contentSize.width / 2 - _player.position.x;
    if (fabs(force) < 2){
        _player.physicsBody.velocity = ccp(0, _player.physicsBody.velocity.y);
        _player.physicsBody.force = ccp(0,_player.physicsBody.force.y);
    }
    force *= delta;
    CGFloat muliplier = 180;
    force *= muliplier;
    _player.physicsBody.force = ccpAdd(_player.physicsBody.force, ccp(force, 0));
}


- (void)checkIfPlayerDropped
{
    if (_player.position.y < 0){
        [self gameOver];
    }
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

#pragma mark - Physics

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair psr_player:(CCNode *)player psr_donut:(CCNode *)donut
{
    [donut runAction:[CCActionFadeOut actionWithDuration:0.1]];
    donut.physicsBody.sensor = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _player.physicsBody.mass  += 0.02;
        [self p_updateMassLabel];
        self.score ++;
        _player.scale = 1 * sqrt(sqrt(_player.physicsBody.mass));
        donut.physicsBody.velocity = CGPointZero;
        donut.physicsBody.force    = CGPointZero;
        [donut runAction:[CCActionPlace actionWithPosition:ccp(-donut.contentSize.width * 2, 0)]];
        [donut runAction:[CCActionFadeIn actionWithDuration:0]];
    });
    return NO;
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


#pragma mark - Move to other scenes

- (void)gameOver
{
    [[CCDirector sharedDirector]pushScene:[HighScoreScene hightScoreWithNewScore:self.score]
                           withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight
                                                                           duration:1]];
}



@end
