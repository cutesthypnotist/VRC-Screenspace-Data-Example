Shader "GamerLiquid/GamerLiquidShader"
{
	Properties{
		_MainTex("Main Tex", 2D) = "white" {}
		_HeightFactor("HeightFactor", Float) = 1
		[IntRange] _Width ("Texture Size (POT)", Range(0, 13)) = 7		
	}
		
		SubShader{
			Tags {"RenderType"="Transparent" "Queue"="Transparent" "DisableBatching"="True" "IgnoreProjector" = "True" }
			CGINCLUDE
				#pragma target 5.0
				#include "Common.cginc" 
			ENDCG
			Pass {
				CGPROGRAM
					
					#pragma require geometry
					#pragma vertex vert
					#pragma fragment frag
					#pragma geometry geom

					#include "UnityCG.cginc"
					

					struct vi {
						float4 vertex : POSITION;
						float2 uv : TEXCOORD0;
						float2 uv1 : TEXCOORD1;
						float2 uv2 : TEXCOORD2;
						float4 color : COLOR;
						float4 tangent : TANGENT;						
					};
					struct v2g
					{
						float2 uv : TEXCOORD0;
						float4 vertex : SV_POSITION;
						float3 color : TEXCOORD1;
						float3 worldPos : TEXCOORD2;	
						float4 rh : TEXCOORD3;
						float up : TEXCOORD4;						
					};

					struct g2f
					{
						float4 vertex : SV_POSITION;
						float3 color : TEXCOORD1;
						float3 worldPos : TEXCOORD2;	
						float4 rh : TEXCOORD3;
						float2 uv : TEXCOORD0;
						float up : TEXCOORD4;						
					};
					
					Texture2D< float4 > _LiquidGrabPass;
					float4 _LiquidGrabPass_TexelSize;					
					float _HeightFactor;
					uint _Width;

					v2g vert (vi v)
					{
						v2g o;
						o.vertex = v.vertex;
						o.uv = v.uv;
						o.color = 0.;
						o.rh = mul(unity_ObjectToWorld, float4(v.vertex.xyz,0));
						//wtf
						//float upLerpFactor = clamp(0, 1, 1 - abs(_HeightFactor - o.modelPosRH.y));
						o.up = clamp(1 - abs(_HeightFactor - o.rh.y),0,1);
						if(o.rh.y > _HeightFactor) {
							v.vertex.xyz = mul(unity_WorldToObject, float4(o.rh.x, _HeightFactor , o.rh.z, o.rh.w)).xyz;
						}

						o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;	
						return o;
					}
					
					//based upon cnlohr cloth method
					[maxvertexcount(12)] 
					void geom(triangle v2g input[3], uint pid: SV_PrimitiveID, inout TriangleStream<g2f> triStream) {
						g2f o = (g2f)0;
						int i = 0;

						for (int i = 0; i < 3; i++ ) {
							uint id = pid * 3 + i;
							
							o.uv = input[i].uv;
							o.worldPos = input[i].worldPos;
							o.rh = input[i].rh;	
							o.color = input[i].vertex;
							o.up = input[i].up;
							
							uint2 screen = uint2(TEXSIZE / BLOCKWIDTH, 0.);
							float4 sscale = float4( 2. / _ScreenParams.xy, 1,1);
							float4 soffset = float4( -_ScreenParams.xy/2,0,0);
							
							// uint2 coords = uint2(input[i].vertex.xy);
							// id = screen.x * coords.y + coords.x;
							// uint2 coords = uint2(x,y);

							//uint id = TEXSIZE / BLOCKWIDTH 
							
							soffset += float4(  id % screen.x * BLOCKWIDTH, id / screen.x * BLOCKHEIGHT, 0, 0 );
							
							o.vertex = ( float4(BLOCKWIDTH,BLOCKHEIGHT,1,1) + soffset ) * sscale;
							o.uv = float2(PIXELTYPES,0);
							triStream.Append(o);

							o.vertex = ( float4(0,BLOCKHEIGHT,1,1) + soffset ) * sscale;
							o.uv = float2(0,0);
							triStream.Append(o);

							o.vertex = ( float4(BLOCKWIDTH,0,1,1) + soffset ) * sscale;
							o.uv = float2(PIXELTYPES,0);
							triStream.Append(o);


							o.vertex = ( float4(0,0,1,1) + soffset ) * sscale;
							o.uv = float2(0,0);
							triStream.Append(o);
							triStream.RestartStrip();
						}
						
					}
					// From Lyuma, note it has debug hacks active.
					// float2 pixelToUV(float2 pixelCoordinate, float2 offset) {
					// 	float2 correctedTexelSize = _LiquidGrabPass_TexelSize.zw;
					// 	if (correctedTexelSize.x / _ScreenParams.x > 1.9) {
					// 		correctedTexelSize.x *= 0.5;
					// 	}
					// 	return (floor(pixelCoordinate) + offset) / correctedTexelSize;
					// }

					// [maxvertexcount(PIXELTYPES)]
					// void appendPixelToStream(inout PointStream<g2f> ptstream, float2 pixelCoordinate, float4 color) {
					// 	g2f o = (g2f)0;
					// 	o.color = color * 0.1;
					// #if UNITY_UV_STARTS_AT_TOP
					// 	float2 uvflip = float2(1., -1.);
					// #else
					// 	float2 uvflip = float2(1., 1.);
					// #endif
					// 	o.vertex = float4(uvflip*(pixelToUV(pixelCoordinate, float2(.49,.49)) * 2. - float2(1.,1.)), 0., 1.);
					// 	ptstream.Append(o);
					// }

					// //https://gist.github.com/pema99/8b385ae6cef2736f4dea2fd6d4ead01c
					// [maxvertexcount(21)] // PIXELTYPES *3
					// void geom(triangle v2g input[3], inout PointStream<g2f> ptstream, uint triID : SV_PrimitiveId)
					// {
					// 	float width = 1 << _Width;
					// 	float2 quadSize = float2(2.0 * BLOCKWIDTH / width, 0);

					// 	for (uint i = 0; i < 3; i++)
					// 	{
					// 		uint id = triID * 3 + i;

					// 		uint2 coord = uint2(id % width * BLOCKWIDTH, id / width);
					// 		float3 pos = float3(((coord.xy / float2(width* BLOCKWIDTH,width)) - 0.5) * 2.0, 1);
					// 		g2f o;
					// 		o.worldPos = input[i].worldPos;
					// 		o.color = input[i].vertex;
					// 		o.rh = input[i].rh;	
					// 		o.up = input[i].up;
					// 		o.vertex = float4(pos + quadSize.xxy, 1);
					// 		o.uv = float2(BLOCKWIDTH,0);
					// 		triStream.Append(o);
					// 		o.vertex = float4(pos + quadSize.yxy, 1);
					// 		o.uv = float2(0,0);
					// 		triStream.Append(o);
					// 		o.vertex = float4(pos + quadSize.xyy, 1);
					// 		o.uv = float2(BLOCKWIDTH,0);
					// 		triStream.Append(o);
					// 		o.vertex = float4(pos + quadSize.yyy, 1);
					// 		o.uv = float2(0,0);
					// 		triStream.Append(o);
					// 		triStream.RestartStrip();
					// 	}
					// }


					float4 frag (g2f i) : SV_Target {
						float4 col = float4(i.color,1);
						int id = floor(i.uv.x);
						if( id == 0 ) {
							col.rgb = uintToHalf3(asuint(i.worldPos.x));
						} else if( id == 1) {
							col.rgb = uintToHalf3(asuint(i.worldPos.y));
						} else if( id == 2) {
							col.rgb = uintToHalf3(asuint(i.worldPos.z));
						} else if( id == 3) {
							col.rgb = uintToHalf3(asuint(i.rh.x));
						} else if( id == 4) {
							col.rgb = uintToHalf3(asuint(i.rh.y));
						} else if( id == 5) {
							col.rgb = uintToHalf3(asuint(i.rh.z));
						} else if( id == 6) {
							col.rgb = uintToHalf3(asuint(i.rh.w));
						} 
						else if( id == 7) {
							col.rgb = uintToHalf3(asuint(i.up));
						} 
						else {
							col.rgb = 0.;
						}
						return col;

					}

				ENDCG

			}
			GrabPass {"_LiquidGrabPass"}

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma geometry geom

				#include "UnityCG.cginc"
				#include "Common.cginc"

				struct vi {
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					uint vid : SV_VertexID;
				};
				struct v2g
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};
				struct g2f {
					float4 vertex : SV_POSITION;
					float2 uv : TEXCOORD0;
					float3 color : TEXCOORD1;	
				};
				struct v2f
				{
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
					float4 vertex : SV_POSITION;
				};		

				Texture2D<float4> _MainTex;
				float4 _MainTex_TexelSize;
				uint _Width;


				//Texture2D< float4 > _LiquidGrabPass;
				//float4 _LiquidGrabPass_TexelSize;            
				float4 GetFromTextureInternal( uint2 coord )
				{
					#if UNITY_UV_STARTS_AT_TOP
					return _MainTex[uint2(coord.x,_MainTex_TexelSize.w-1-coord.y)];
					#else
					return _MainTex[coord];
					#endif
				}

				struct OverlyComplex {
					float3 wpos;
					float4 rh;
					float up;
				};

				static float gpvals[PIXELTYPES+1];

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

					return c;
				}
				v2g vert (vi v)
				{
					v2g o;
					o.vertex = v.vertex;
					o.uv = v.uv;
					return o;
				}
		


				[maxvertexcount(3)]
				void geom(triangle v2g input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> triStream)
				{
					g2f o;
					int i = 0;
					uint width = uint(TEXSIZE / BLOCKWIDTH);
					for( i = 0; i < 3; i++ )
					{
						
						uint id = pid * 3 + i;
						uint2 coord = uint2(id % width * BLOCKWIDTH, id / width * BLOCKHEIGHT);
						OverlyComplex c = GetFromTexture(coord);
						float3 pos = c.wpos;
						o.vertex = mul(UNITY_MATRIX_VP, float4(pos,1));
						o.color = pos;
						o.uv = input[i].uv;
						triStream.Append(o);
					}
				}

				float4 frag (g2f i) : SV_Target
				{
					
					return float4(i.color, 1.0);
				}
				ENDCG
			}			
		}
}