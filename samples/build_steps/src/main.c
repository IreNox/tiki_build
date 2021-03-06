#include <stdio.h>

int main()
{
	FILE* pFile = fopen( "copy.txt", "r" );

	char buffer[ 256u ];
	const size_t bytes = fread( buffer, 1u, sizeof( buffer ), pFile );
	buffer[ bytes ] = '\0';
	fclose( pFile );

	printf( buffer );
	return 0;
}
