
#ifdef DEBUG

#include <windows.h>

int z_verbose;
void z_error(char *m)
{
	if( z_verbose )
	{
		OutputDebugStringA( m );
	}

	__debugbreak();
}

#endif
