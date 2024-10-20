#include "function.h"

#include <iostream>

#if _MSC_VER
#	define CCALL __cdecl
#else
#	define CCALL  //__attribute__((cdecl))
#endif

CCALL void printHelloWorld()
{
	std::cout << "Hello World!" << std::endl;
}