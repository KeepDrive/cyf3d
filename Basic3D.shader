shader "CYF/Basic3D"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
        _objPos ("Object Position", Vector) = (0,0,0,0)
        _uvPos ("UV Position", Vector) = (0.5,0.5,0,0)
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
            float4 _objPos,_uvPos;
            float4x4 mod,MVP,uvMod;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = (mul(uvMod,float4(v.uv-float2(0.5,0.5),0,0))+_uvPos).xy;
                o.vertex = mul(MVP,mul(mod,float4(v.vertex.x,v.vertex.y,0,1))+_objPos);
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
