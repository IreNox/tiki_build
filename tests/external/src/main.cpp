#include <stdio.h>

#include "box2d/b2_settings.h"
#include "freetype/freetype.h"
#include "imgui.h"
#include "stb.h"
#include "tinyxml2.h"

extern "C"
{
#include "trex.h"
}

void testBox2D()
{
	printf( "Box2D Version: %d.%d.%d\n", b2_version.major, b2_version.minor, b2_version.revision );
}

void testFreeType()
{
	FT_Library ftLibrary;
	FT_Init_FreeType( &ftLibrary );

	FT_Int major;
	FT_Int minor;
	FT_Int patch;
	FT_Library_Version( ftLibrary, &major, &minor, &patch );

	printf( "FreeType Version: %d.%d.%d\n", major, minor, patch );

	FT_Done_FreeType( ftLibrary );
}

void testImGui()
{
	IMGUI_CHECKVERSION();
	printf( "ImGui Version: %s\n", IMGUI_VERSION );
}

void testStb()
{
	printf( "stb Version: %d\n", STB_VERSION );
}

void testTinyXML2()
{
	printf( "TinyXML-2 Version: %d.%d.%d\n", TIXML2_MAJOR_VERSION, TIXML2_MINOR_VERSION, TIXML2_PATCH_VERSION );
}

void testTRex()
{
	TRex* pTest = trex_compile( (const TRexChar*)L".*", nullptr );
	trex_free( pTest );
}

int main()
{
	testBox2D();
	testFreeType();
	testImGui();
	testStb();
	testTinyXML2();
	testTRex();

	return 0;
}