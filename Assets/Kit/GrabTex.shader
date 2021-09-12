Shader "Unlit/GrabTex"
{
    Properties
    {
		[IntRange] _Width ("Texture Size (POT)", Range(0, 13)) = 7		
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Common.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
			Texture2D< float4 > _LiquidGrabPass;
			float4 _LiquidGrabPass_TexelSize;            
			float4 GetFromGrabPassInternal( uint2 coord )
			{
				#if UNITY_UV_STARTS_AT_TOP
                return _LiquidGrabPass[uint2(coord.x,_LiquidGrabPass_TexelSize.w-1-coord.y)];
				#else
                return _LiquidGrabPass[coord];
				#endif
			}

			struct OverlyComplex {
				float3 wpos;
				float4 rh;
				float up;
			};
            uint _Width;

			static float gpvals[BLOCKTYPES+1];

			OverlyComplex GetFromGrabPass( uint2 coord )
			{	
				OverlyComplex c = (OverlyComplex)0;
				coord = uint2(coord.x * BLOCKWIDTH, coord.y);
				[unroll(BLOCKTYPES)]
				for(uint x = 0; x < BLOCKTYPES; x++) {
					uint2 c = uint2(x * BLOCKSIZE,0);
					gpvals[x] = asfloat(half3ToUint(GetFromGrabPassInternal(coord+c)));
				}
				c.wpos = float3(gpvals[0],gpvals[1],gpvals[2]);
				c.rh = float4(gpvals[3],gpvals[4],gpvals[5],gpvals[6]);
				c.up = float(gpvals[7]);

				return c;
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                uint2 coords = i.uv * _LiquidGrabPass_TexelSize.zw / uint2(BLOCKWIDTH, 1);
                OverlyComplex c = GetFromGrabPass(coords);
                return float4(c.wpos,1);
            }
            ENDCG
        }
    }
}
