shader "CYF/Complex3D"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
        _objPos ("Object Position", Vector) = (0,0,0,0)
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
            float4 _objPos;
            float4x4 mod,MVP;
            float4 vertPos[4],uvPos[4];

            v2f vert(appdata v)
            {
                v2f o;
                int arrIndex=int((v.uv.x*(1-v.uv.y))+2*(v.uv.x*v.uv.y)+3*((1-v.uv.x)*v.uv.y));//Branchless programming at its finest
                o.uv = uvPos[arrIndex].xy;
                o.vertex = mul(MVP,mul(mod,float4(vertPos[arrIndex].xyz,1))+_objPos);
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
