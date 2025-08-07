#pragma once



typedef void(__cdecl* OnTokenChangedHandlerSignature)(long  numeroDeMarcasAntes, long numeroDeMarcasAgora);
typedef bool(__cdecl* OnTokenInPlaceHandlerSignature)(long  numeroDeMarcas);
typedef bool(__cdecl* TransitionHandlerSignature)();




#define CHECK_SIGNATURE_PLACE_HANDLER(signature)            if(signature != (OnTokenInPlaceHandlerSignature)NULL){}
#define CHECK_SIGNATURE_TOKEN_CHANGED_HANDLER(signature)    if(signature != (OnTokenChangedHandlerSignature)NULL){}
#define CHECK_SIGNATURE_TRANSITION_HANDLER(signature)       if(signature != (TransitionHandlerSignature    )NULL){}


#define PLACE_HANDLER          extern "C" __declspec(dllexport) bool __cdecl
#define TOKEN_CHANGED_HANDLER  extern "C" __declspec(dllexport) void __cdecl
#define TRANSITION_HANDLER     extern "C" __declspec(dllexport) bool __cdecl
#define LOG_HANDLER            extern "C" __declspec(dllexport) const char* __cdecl
#define LOG_ALERT_HANDLER            extern "C" __declspec(dllexport) bool __cdecl

