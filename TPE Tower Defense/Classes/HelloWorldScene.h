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

/**
 *  The main scene
 */
@interface HelloWorldScene : CCScene

@property (strong) CCTiledMap * tileMap;
@property (strong) CCTiledMapLayer * background;
@property (strong) CCSprite * player;

@property (nonatomic, strong) CCSprite *jeff;
@property (nonatomic, strong) CCAction *walkAction;
@property (nonatomic, strong) CCAction *moveAction;

// -----------------------------------------------------------------------

+ (HelloWorldScene *) scene;
- (id)init;
+ (CCScene *) jeffScene;

// -----------------------------------------------------------------------
@end