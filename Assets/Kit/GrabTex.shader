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
            #define USE_GRABPASS 1
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                uint2 coords = i.uv * _GarbPass_TexelSize.zw / uint2(PIXELWIDTH, 1);
                OverlyComplex c = GetFromTexture(coords);
                c.wpos.y += sin(_Time.y) * 0.001;
                return float4(c.wpos,1);
            }
            ENDCG
        }
    }
}
