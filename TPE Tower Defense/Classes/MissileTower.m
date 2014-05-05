#import "MissileTower.h"

@implementation MissileTower : Tower

- (NSString *)getTowerName
{
    return @"Missile";
}

- (int)getPrice
{
    return 20;
}

- (int)getDamage
{
    return 50;
}

@end