#include "external1.h"
#include "external2.h"

int main()
{
	if( external1_test( 8 ) != 50 )
	{
		return 1;
	}

	if( external2_test( 3 ) != 1340 )
	{
		return 1;
	}

	return 0;
}