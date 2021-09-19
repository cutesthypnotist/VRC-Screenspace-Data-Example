Shader "Unlit/Compute Result"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "White" {}   
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
            #define USE_GRABPASS 0
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

            float4 frag (v2f i) : SV_Target
            {
                float4 col = 0.;
                uint width = uint(TEXSIZE / PIXELWIDTH);
                
                uint2 texCoord = i.uv * TEXSIZE;
                uint id = texCoord.x + texCoord.y * width;
                //uint2 volCoord = uint2(id % width * PIXELWIDTH, id / width * PIXELHEIGHT);
                //OverlyComplex c = GetFromTexture(volCoord);
                #if USE_GRABPASS
                    float val =  asfloat(half3ToUint(GetFromTextureInternal(texCoord)));
                #else
                    float val =  asfloat(half3ToUint(_MainTex[texCoord]));
                #endif
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
