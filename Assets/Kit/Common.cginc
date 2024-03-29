﻿#ifndef COMMON_INCLUDED
#define COMMON_INCLUDED

#define PIXELTYPES 16 // # of fields
#define PIXELSIZE 1 
#define PIXELWIDTH (PIXELTYPES*PIXELSIZE) 
#define PIXELHEIGHT PIXELSIZE 
#define TEXSIZE 512 // Note that this needs to be divisible by pixeltypes
//and probably both texsize and pixeltypes should be power of 2
#ifndef USE_GRABPASS
#define USE_GRABPASS 0
#endif

//Merlin. For details see https://github.com/pema99/shader-knowledge/blob/main/tips-and-tricks.md#encoding-and-decoding-data-in-a-grabpass
float uint14ToFloat(uint input)
{
	precise float output = (f16tof32((input & 0x00003fff)));
	return output;
}

uint floatToUint14(precise float input)
{
	uint output = (f32tof16(input)) & 0x00003fff;
	return output;
}

// Encodes a 32 bit uint into 3 half precision floats
float3 uintToHalf3(uint input)
{
	precise float3 output = float3(uint14ToFloat(input), uint14ToFloat(input >> 14), uint14ToFloat((input >> 28) & 0x0000000f));
	return output;
}

uint half3ToUint(precise float3 input)
{
	return floatToUint14(input.x) | (floatToUint14(input.y) << 14) | ((floatToUint14(input.z) & 0x0000000f) << 28);
}

Texture2D<float4> _MainTex; 
float4 _MainTex_TexelSize;

     

struct OverlyComplex {
	float3 wpos;
	float3 velocity;
	float4 rh;
	float up;
};

static float gpvals[PIXELTYPES+1];

#if USE_GRABPASS // Grabpass version

Texture2D< float4 > _GarbPass;
float4 _GarbPass_TexelSize;    

#define GRABSIZE _GarbPass_TexelSize.w


float4 GetFromTextureInternal( uint2 coord )
{
	#if UNITY_UV_STARTS_AT_TOP
	return _GarbPass[uint2(coord.x,GRABSIZE-1-coord.y)];
	#else
	return _GarbPass[coord];
	#endif
}
#else
float4 GetFromTextureInternal( uint2 coord )
{
	#if UNITY_UV_STARTS_AT_TOP
	return _MainTex[uint2(coord.x,TEXSIZE-1-coord.y)];
	#else
	return _MainTex[coord];
	#endif
}				
#endif 

OverlyComplex GetFromTexture( uint2 coord )
{	
	OverlyComplex c = (OverlyComplex)0;
	coord = uint2(coord.x, coord.y);
	[unroll(PIXELTYPES)]
	for(uint x = 0; x < PIXELTYPES; x++) {
		uint2 c = uint2(x * PIXELSIZE,0);
		gpvals[x] = asfloat(half3ToUint(GetFromTextureInternal(coord+c)));
	}
	c.wpos = float3(gpvals[0],gpvals[1],gpvals[2]);
	c.rh = float4(gpvals[3],gpvals[4],gpvals[5],gpvals[6]);
	c.up = float(gpvals[7]);
	c.velocity = float3(gpvals[8],gpvals[9],gpvals[10]);

	return c;
}



#endif