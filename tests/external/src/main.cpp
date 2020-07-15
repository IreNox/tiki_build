#include <stdio.h>

#include "box2d/b2_world.h"

int main()
{
	b2World world( b2Vec2( 0.0f, 9.81f ) );
	world.Dump();

	return 0;
}