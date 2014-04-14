//
//  HelloWorldScene.h
//  TPE Tower Defense
//
//  Created by Franco Román Meola on 10/04/14.
//  Copyright Franco Román Meola 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------
#define SPRITE_SIZE 3
/**
 *  The main scene
 */
@interface HelloWorldScene : CCScene

@property (strong) CCTiledMap * tileMap;
@property (strong) CCTiledMapLayer * background;

@property (nonatomic, strong) CCSprite *character;
@property (nonatomic, strong) CCAction *walkAction;
@property (nonatomic, strong) CCAction *moveAction;
//@property (nonatomic, strong) CCAction *waitAction;
//@property (nonatomic, strong) CCActionSequence * sequenceAction;
@property (nonatomic, strong) CCAnimation *walkAnim;

// -----------------------------------------------------------------------

+ (HelloWorldScene *) scene;
- (id)init;

-(void)createScoreLabelWithInitialScore:(int)initial;
-(void)changeScore:(int)diff;
-(void)defaultScoreLabel;

-(void)createWavesLabel;
-(void)increaseWavesCount:(int)diff;
-(void)defaultWavesLabel;

-(void)createMoneyLabelWithInitialMoney:(int)initial;
-(void)changeMoney:(int)diff;
-(void)defaultMoneyLabel;

-(void)createTowerButtons;
-(void)createTower1Button;
-(void)createTower2Button;

-(void)createBackButton;

-(void)playAudioEffectNamed:(NSString *)name;

-(void)createCharacterSprite:(NSString *)characterName withPosition:(CGPoint)point;
-(void)updateCharacerSprite:(NSString *)characterName withPosition:(CGPoint)point;
// -----------------------------------------------------------------------
@end