#import "Tower.h"
#import "CCDrawingPrimitives.h"

@implementation Tower

+ (id)nodeWithTheGame:(HelloWorldScene *)game location:(CGPoint)location
{
    return [[self alloc] initWithTheGame:game location:location];
}

- (id)initWithTheGame:(HelloWorldScene *)game location:(CGPoint)location
{
	if( (self=[super init])) {
		_theGame = game;
        _towerSprite = [CCSprite spriteWithImageNamed:
                    [NSString stringWithFormat:@"%@.png",[self getTowerName]]];
		[self addChild:_towerSprite z:4 name:@"torre"];
        [_towerSprite setPosition:[self getCorrectLocationOnTileMap:location]];
        [_theGame addChild:self];
        _isShooting = NO;
	}
	return self;
}

- (NSString *)getTowerName
{
    return @"Tower";
}

- (int)getPrice
{
    return 10;
}

- (void)draw
{
    ccDrawColor4B(255,255,255,255);
    ccDrawCircle(_towerSprite.position, [self getAttackRange], 360, 30, false);
    [super draw];
}

- (CGPoint)getCorrectLocationOnTileMap:(CGPoint)location
{
    return ccp(location.x+20, location.y+20);
}

- (int)getDamage
{
    return 5;
}

-(int)getAttackRange
{
    return 80;
}

@end