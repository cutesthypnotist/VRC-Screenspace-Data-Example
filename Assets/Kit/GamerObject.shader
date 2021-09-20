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
			ENDCG
			Pass {
				CGPROGRAM
					
					#pragma require geometry
					#pragma vertex vert
					#pragma fragment frag
					#pragma geometry geom
					#define USE_GRABPASS 1

					#include "UnityCG.cginc"
					#include "Common.cginc" 
					

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
						uint width = uint2(TEXSIZE / PIXELWIDTH, 0.);

						for (int i = 0; i < 3; i++ ) {
							uint id = pid * 3 + i;
							
							o.uv = input[i].uv;
							o.worldPos = input[i].worldPos;
							o.rh = input[i].rh;	
							o.color = input[i].vertex;
							o.up = input[i].up;
							
							float4 sscale = float4( 2. / _ScreenParams.xy, 1,1);
							float4 soffset = float4( -_ScreenParams.xy/2,0,0);
							soffset += float4(  id % width * PIXELWIDTH, id / width * PIXELHEIGHT, 0, 0 );
							
							o.vertex = ( float4(PIXELWIDTH,PIXELHEIGHT,1,1) + soffset ) * sscale;
							o.uv = float2(PIXELTYPES,0);
							triStream.Append(o);

							o.vertex = ( float4(0,PIXELHEIGHT,1,1) + soffset ) * sscale;
							o.uv = float2(0,0);
							triStream.Append(o);

							o.vertex = ( float4(PIXELWIDTH,0,1,1) + soffset ) * sscale;
							o.uv = float2(PIXELTYPES,0);
							triStream.Append(o);

							o.vertex = ( float4(0,0,1,1) + soffset ) * sscale;
							o.uv = float2(0,0);
							triStream.Append(o);
							triStream.RestartStrip();
						}
						
					}



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

			GrabPass {"_GarbPass"}
			
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma geometry geom
				#define USE_GRABPASS 0
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

				uint _Width;

				v2g vert (vi v)
				{
					v2g o;
					o.vertex = v.vertex;
					o.uv = v.uv;
					return o;
				}
#if 1
				[maxvertexcount(3)]
				void geom(triangle v2g input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> triStream)
				{
					g2f o;
					int i = 0;
					uint width = uint(TEXSIZE / PIXELWIDTH);
					for( i = 0; i < 3; i++ )
					{
						
						uint id = pid * 3 + i;
						uint2 coord = uint2(id % width * PIXELWIDTH, id / width * PIXELHEIGHT);
						#if USE_GRABPASS
						#endif
						OverlyComplex c = GetFromTexture(coord);
						float3 pos = c.wpos;
						o.vertex = mul(UNITY_MATRIX_VP, float4(pos,1));
						o.color = pos;
						o.uv = input[i].uv;
						triStream.Append(o);
					}
				}
#endif
				float4 frag (g2f i) : SV_Target
				{
					
					return float4(i.color, 1.0);
				}
				ENDCG
			}			
		}
}