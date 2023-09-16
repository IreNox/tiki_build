#include <stdio.h>

#include <imapp/imapp.h>

struct TestContext
{
};

void* __cdecl ImAppProgramInitialize( ImAppParameters* pParameters )
{
	return new TestContext();
}

void __cdecl ImAppProgramDoUi( ImAppContext* pImAppContext, void* pProgramContext )
{
}

void __cdecl ImAppProgramShutdown( ImAppContext* pImAppContext, void* pProgramContext )
{
	TestContext* pTestContext = (TestContext*)pProgramContext;
	delete pTestContext;
}
