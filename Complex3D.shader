shader "CYF/Complex3D"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }

        Cull Off
        Lighting Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4x4 mod,MVP;
            float vertPos[12],uvPos[8];

            v2f vert(appdata v)
            {
                v2f o;
                int arrIndex=int((v.uv.x*(1-v.uv.y))+2*(v.uv.x*v.uv.y)+3*((1-v.uv.x)*v.uv.y));//Branchless programming at its finest
                o.uv = float2(uvPos[arrIndex*2],uvPos[arrIndex*2+1]);
                o.vertex = mul(MVP,mul(mod,float4(vertPos[arrIndex*3],vertPos[arrIndex*3+1],vertPos[arrIndex*3+2],1)));
                o.color = v.color;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv) * i.color;
                clip(color.a - 0.001);
                color.rgb *= color.a;
                return color;
            }
        ENDCG
        }
    }
}
