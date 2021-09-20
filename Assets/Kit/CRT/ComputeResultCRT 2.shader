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
            #define USE_GRABPASS 1
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
			Name "Result Out"
            CGPROGRAM

            float4 frag (v2f_customrendertexture IN) : SV_Target
            {
                float4 col = 0.;
				float2 uvs = IN.globalTexcoord;
                #if USE_GRABPASS
					#if UNITY_UV_STARTS_AT_TOP
					uvs.y = 1.0-uvs.y;
					#endif
				#endif
                uint2 coord = uvs * _MainTex_TexelSize.zw;
				col =  _MainTex[coord];

                return col;
            }

            ENDCG
        }

    }
}
