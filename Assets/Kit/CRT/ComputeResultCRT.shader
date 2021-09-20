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
			Name "Grab In"
            CGPROGRAM

            float4 frag (v2f_customrendertexture IN) : SV_Target
            {
                float4 col = 0.;
                uint width = uint(TEXSIZE / PIXELWIDTH);
                uint2 texCoord = IN.globalTexcoord * TEXSIZE;
                uint id = texCoord.x + texCoord.y * width;
                uint2 volCoord = uint2(id % width * PIXELWIDTH, id / width * PIXELHEIGHT);
                #if USE_GRABPASS
                    float val =  asfloat(half3ToUint(GetFromTextureInternal(texCoord)));
                #else
                    float val =  asfloat(half3ToUint(_MainTex[texCoord]));
                #endif
                int tid = id % PIXELTYPES;
				uint xBase = texCoord.x-tid;
				OverlyComplex c = GetFromTexture(uint2(xBase, texCoord.y));
				
				float lastwx = asfloat(half3ToUint(_SelfTexture2D[uint2(xBase, texCoord.y)]));
				float lastwy = asfloat(half3ToUint(_SelfTexture2D[uint2(xBase+1, texCoord.y)]));
				float lastwz = asfloat(half3ToUint(_SelfTexture2D[uint2(xBase+2, texCoord.y)]));
				
				float lastvx = asfloat(half3ToUint(_SelfTexture2D[uint2(xBase+8, texCoord.y)]));
				float lastvy = asfloat(half3ToUint(_SelfTexture2D[uint2(xBase+9, texCoord.y)]));
				float lastvz = asfloat(half3ToUint(_SelfTexture2D[uint2(xBase+10, texCoord.y)]));				
				
				float3 velocity = float3(lastvx,lastvy,lastvz);
				float3 lastframewpos = float3(lastwx,lastwy,lastwz);
				//c.velocity.y += (0.5 + 0.5 * sin(_Time.y)) * 0.05;

				float dist = distance(lastframewpos, c.wpos);
				float3 deltaMovement = c.wpos - lastframewpos;
				float3 normalizedDelta = 0;
				if (length(deltaMovement) > 0.000001) {
					normalizedDelta = normalize(deltaMovement);
				}				
				float3 addVelocity = float3(deltaMovement.x, deltaMovement.y, deltaMovement.z) * 0.15f;
				float xz = normalizedDelta.x * normalize(c.rh).x + normalizedDelta.z * normalize(c.rh).z;
				float3 verticalMoveAdd = float3(0, xz*21.0, 0) * -0.15f;
				velocity = (velocity) * pow(0.001f,sqrt(unity_DeltaTime.x)) + addVelocity  + verticalMoveAdd;				
				if (length(velocity) > 0.01f || dist > 0.01f) {
					float dt = clamp( unity_DeltaTime.x, 0.005, 0.02 ) * 2.0;
					c.wpos = float3(c.wpos.x, lerp(c.wpos.y, (lastframewpos + 1. * velocity * dt).y, c.up) , c.wpos.z);
				}
                if( tid == 0 ) { //wpos.x
                    col.rgb = uintToHalf3(asuint(c.wpos.x));
                } else if( tid == 1) { //wpos.y
                    col.rgb = uintToHalf3(asuint(c.wpos.y));
                } else if( tid == 2) { //wpos.z
                    col.rgb = uintToHalf3(asuint(c.wpos.z));
                } else if( tid == 3) { //rh.x
                    col.rgb = uintToHalf3(asuint(c.rh.x));
                } else if( tid == 4) { //rh.y
                    col.rgb = uintToHalf3(asuint(c.rh.y));
                } else if( tid == 5) { //rh.z
                   col.rgb = uintToHalf3(asuint(c.rh.z));
                } else if( tid == 6) { //rh.w
                    col.rgb = uintToHalf3(asuint(c.rh.w));
                } 
                else if( tid == 7) { //up
                    col.rgb = uintToHalf3(asuint(c.up));
                }
                else if( tid == 8) { //velx
                    col.rgb = uintToHalf3(asuint(c.velocity.x));
                } 
                else if( tid == 9) { //vely
                    col.rgb = uintToHalf3(asuint(c.velocity.y));
                } 
                else if( tid == 10) { //velz
                    col.rgb = uintToHalf3(asuint(c.velocity.z));
                } 												 
                else { //no-op
                    col.rgb = 0.;
                }
                
                return col;
            }

            ENDCG
        }

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
                uint2 coord = uvs * _SelfTexture2D_TexelSize.zw;
				col =  _SelfTexture2D[coord];

                return col;
            }

            ENDCG
        }

    }
}
