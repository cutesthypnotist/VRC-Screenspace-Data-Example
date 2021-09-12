// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _OutputTex ("Texture", 2D) = "white" {}
		[IntRange] _Width ("Texture Size (POT)", Range(0, 13)) = 7		
    }
    SubShader
    {
		Tags{ "RenderType" = "Opaque" "Queue"="Geometry"   "DisableBatching"="True" "IgnoreProjector" = "True"  }
		Cull Off


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

            Texture2D<float4> _OutputTex;
            float4 _OutputTex_TexelSize;
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
                    float3 pos = _OutputTex[coord];
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
