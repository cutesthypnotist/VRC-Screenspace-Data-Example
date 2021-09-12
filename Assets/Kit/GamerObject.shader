Shader "GamerLiquid/GamerLiquidShader"
{
	Properties{
		_MainTex("Main Tex", 2D) = "white" {}
		_HeightFactor("HeightFactor", Float) = 1
		[IntRange] _Width ("Texture Size (POT)", Range(0, 13)) = 7		
	}
		
		SubShader{
			Tags {"RenderType"="Transparent" "Queue"="Transparent" "DisableBatching"="True" "IgnoreProjector" = "True" }
			// GrabPass {"_Before"}
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
						float4 rh : TEXCOORD0;
						float up : TEXCOORD1;						
						float3 worldPos : TEXCOORD2;	
						float4 color: TEXCOORD3;
						float2 uv : TEXCOORD4;
					};
					
					// Texture2D< float4 > _Before;
					// float4 _Before_TexelSize;

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

					[maxvertexcount(12)]
					void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream, uint triID : SV_PrimitiveId)
					{
						float width = 1 << _Width;
						float2 quadSize = float2(2.0 / width, 0);

						for (uint i = 0; i < 3; i++)
						{
							uint id = triID * 3 + i;
							uint2 coord = uint2(id % width * BLOCKWIDTH, id / width);
							float3 pos = float3(((coord.xy / float2(width* BLOCKWIDTH,width)) - 0.5) * 2.0, 1);
							g2f o;
							o.worldPos = input[i].worldPos;
							o.color = input[i].vertex;
							o.rh = input[i].rh;	
							o.up = input[i].up;
							o.vertex = float4(pos + quadSize.xxy, 1);
							o.uv = float2(BLOCKWIDTH,0);
							triStream.Append(o);
							o.vertex = float4(pos + quadSize.yxy, 1);
							o.uv = float2(0,0);
							triStream.Append(o);
							o.vertex = float4(pos + quadSize.xyy, 1);
							o.uv = float2(BLOCKWIDTH,0);
							triStream.Append(o);
							o.vertex = float4(pos + quadSize.yyy, 1);
							o.uv = float2(0,0);
							triStream.Append(o);
							triStream.RestartStrip();
						}
					}


					float4 frag (g2f i) : SV_Target {
						float4 col = float4(0,0,0,1);
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
						// else if( id == 7) {
						// 	col.rgb = uintToHalf3(asuint(i.up));
						// } 
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
					float width = 1 << _Width;
					float2 quadSize = float2(2.0 / width, 0);                
					for( i = 0; i < 3; i++ )
					{            
						uint id = pid * 3 + i;
						uint2 coord = uint2(id  % width, id / width );
						#if UNITY_UV_STARTS_AT_TOP
						coord = uint2(coord.x,_MainTex_TexelSize.w-1-coord.y);
						#else
						#endif
						float3 pos = _MainTex[coord];
						o.vertex = UnityObjectToClipPos(input[i].vertex);
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