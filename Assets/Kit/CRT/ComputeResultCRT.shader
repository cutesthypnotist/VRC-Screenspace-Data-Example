Shader "Unlit/Compute Result CRT"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "White" {}   
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }


		Cull Off
        Lighting Off		
		ZWrite Off
		ZTest Always
        CGINCLUDE

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
			#pragma target 5.0
			#define glsl_mod(x,y) (((x)-(y)*floor((x)/(y))))
            #include "UnityCG.cginc"
            #define USE_GRABPASS 0
            #include "../Common.cginc"

			#define kCustomTextureBatchSize 16


			struct appdata_customrendertexture
			{
				uint    vertexID    : SV_VertexID;
			};

			// User facing vertex to fragment shader structure
			struct v2f_customrendertexture
			{
				float4 vertex           : SV_POSITION;
				float3 localTexcoord    : TEXCOORD0;    // Texcoord local to the update zone (== globalTexcoord if no partial update zone is specified)
				float3 globalTexcoord   : TEXCOORD1;    // Texcoord relative to the complete custom texture
				uint primitiveID        : TEXCOORD2;    // Index of the update zone (correspond to the index in the updateZones of the Custom Texture)
			};

			// Internal
			float4      CustomRenderTextureCenters[kCustomTextureBatchSize];
			float4      CustomRenderTextureSizesAndRotations[kCustomTextureBatchSize];
			float       CustomRenderTexturePrimitiveIDs[kCustomTextureBatchSize];

			float4      CustomRenderTextureParameters;
			#define     CustomRenderTextureUpdateSpace  CustomRenderTextureParameters.x // Normalized(0)/PixelSpace(1)
			// User facing uniform variables
			float4      _CustomRenderTextureInfo; // x = width, y = height, z = depth, w = face/3DSlice

			// Helpers
			#define _CustomRenderTextureWidth   _CustomRenderTextureInfo.x
			#define _CustomRenderTextureHeight  _CustomRenderTextureInfo.y
			#define _CustomRenderTextureDepth   _CustomRenderTextureInfo.z

			float max3 (float3 x) 
			{
				return max(x.x, max(x.y, x.z));
			}
			// standard custom texture vertex shader that should always be used
			v2f_customrendertexture CustomRenderTextureVertexShader(appdata_customrendertexture IN)
			{
				v2f_customrendertexture OUT;

			#if UNITY_UV_STARTS_AT_TOP
				const float2 vertexPositions[6] =
				{
					{ -1.0f,  1.0f },
					{ -1.0f, -1.0f },
					{  1.0f, -1.0f },
					{  1.0f,  1.0f },
					{ -1.0f,  1.0f },
					{  1.0f, -1.0f }
				};

				const float2 texCoords[6] =
				{
					{ 0.0f, 0.0f },
					{ 0.0f, 1.0f },
					{ 1.0f, 1.0f },
					{ 1.0f, 0.0f },
					{ 0.0f, 0.0f },
					{ 1.0f, 1.0f }
				};
			#else
				const float2 vertexPositions[6] =
				{
					{  1.0f,  1.0f },
					{ -1.0f, -1.0f },
					{ -1.0f,  1.0f },
					{ -1.0f, -1.0f },
					{  1.0f,  1.0f },
					{  1.0f, -1.0f }
				};

				const float2 texCoords[6] =
				{
					{ 1.0f, 1.0f },
					{ 0.0f, 0.0f },
					{ 0.0f, 1.0f },
					{ 0.0f, 0.0f },
					{ 1.0f, 1.0f },
					{ 1.0f, 0.0f }
				};
			#endif

				uint primitiveID = IN.vertexID / 6;
				uint vertexID = IN.vertexID % 6;
				float3 updateZoneCenter = CustomRenderTextureCenters[primitiveID].xyz;
				float3 updateZoneSize = CustomRenderTextureSizesAndRotations[primitiveID].xyz;

			#if !UNITY_UV_STARTS_AT_TOP
				rotation = -rotation;
			#endif

				// Normalize rect if needed
				if (CustomRenderTextureUpdateSpace > 0.0) // Pixel space
				{
					// Normalize xy because we need it in clip space.
					updateZoneCenter.xy /= _CustomRenderTextureInfo.xy;
					updateZoneSize.xy /= _CustomRenderTextureInfo.xy;
				}
				else // normalized space
				{
					// Un-normalize depth because we need actual slice index for culling
					updateZoneCenter.z *= _CustomRenderTextureInfo.z;
					updateZoneSize.z *= _CustomRenderTextureInfo.z;
				}

				// Compute rotation

				// Compute quad vertex position
				float2 clipSpaceCenter = updateZoneCenter.xy * 2.0 - 1.0;
				float2 pos = vertexPositions[vertexID] * updateZoneSize.xy;
				pos.x += clipSpaceCenter.x;
			#if UNITY_UV_STARTS_AT_TOP
				pos.y += clipSpaceCenter.y;
			#else
				pos.y -= clipSpaceCenter.y;
			#endif
				OUT.vertex = float4(pos, 0.0, 1.0);
				OUT.primitiveID = asuint(CustomRenderTexturePrimitiveIDs[primitiveID]);
				OUT.localTexcoord = float3(texCoords[vertexID], 0);
				OUT.globalTexcoord = float3(pos.xy * 0.5 + 0.5, 0);
			#if UNITY_UV_STARTS_AT_TOP
				OUT.globalTexcoord.y = 1.0 - OUT.globalTexcoord.y;
			#endif
				return OUT;
			}

			texture2D< float4 > _SelfTexture2D;
			float4 _SelfTexture2D_TexelSize;
        ENDCG
        
        Pass
        {
			Name "Grab In"
            CGPROGRAM

            float4 frag (v2f_customrendertexture IN) : SV_Target
            {
                float4 col = 0.;
                uint width = uint(TEXSIZE / PIXELWIDTH);
                uint2 texCoord = IN.globalTexcoord * TEXSIZE;
                uint id = texCoord.x + texCoord.y * width;
                //uint2 volCoord = uint2(id % width * PIXELWIDTH, id / width * PIXELHEIGHT);
                //OverlyComplex c = GetFromTexture(volCoord);
                float val =  asfloat(half3ToUint(_MainTex[texCoord]));
                int tid = id % PIXELTYPES;
                if( tid == 0 ) { //wpos.x
                    col.rgb = uintToHalf3(asuint(val));
                } else if( tid == 1) { //wpos.y
                    val += sin(_Time.y) * 0.1;
                    col.rgb = uintToHalf3(asuint(val));
                } else if( tid == 2) { //wpos.z
                    col.rgb = uintToHalf3(asuint(val));
                } else if( tid == 3) { //rh.x
                    col.rgb = uintToHalf3(asuint(val));
                } else if( tid == 4) { //rh.y
                    col.rgb = uintToHalf3(asuint(val));
                } else if( tid == 5) { //rh.z
                   col.rgb = uintToHalf3(asuint(val));
                } else if( tid == 6) { //rh.w
                    col.rgb = uintToHalf3(asuint(val));
                } 
                else if( tid == 7) { //up
                    col.rgb = uintToHalf3(asuint(val));
                } 
                else { //no-op
                    col.rgb = 0.;
                }
                
                return col;
            }

            ENDCG
        }

    }
}
