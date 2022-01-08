shader "CYF/Model3D"
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
			#pragma require geometry
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			struct appdata
			{
				float4 vertex   : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4x4 mod,MVP;

			v2f vert(appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.vertex = v.vertex;
				return o;
			}
			/*
			Documentation on geometry shaders is scarce, so
			Credits to przemyslawzaworski, whose work i used as a reference
			https://github.com/przemyslawzaworski/Unity3D-CG-programming/blob/master/GeometryShaders/Cube.shader
			*/
			float model[297],gluv[198];
			/*
			The actual max possible vertex count(to my knowledge) is 168(56 faces), but my choice to do 99 vertices here is not arbitrary
			GLSL seems to dislike it if the amount of floats in arrays exceeds 503 in total, so this is the best we can do without sacrificing uv data
			At least not until someone finds some clever way of getting around this
			*/
			[maxvertexcount(99)]
			void geom(triangle v2f patch[3], inout TriangleStream<v2f> tristream, uint pid : SV_PRIMITIVEID)
			{
				v2f o;
				if (pid == 0)
				{
					[unroll(33)]
					for (int i=0; i<33; i++)
					{
						[unroll(3)]
						for (int j=0; j<3; j++){
							o.vertex = mul(MVP,mul(mod,float4(model[i*9+j*3],model[i*9+j*3+1],model[i*9+j*3+2],1.0)));
							o.uv = float2(gluv[i*6+j*2],gluv[i*6+j*2+1]);
							tristream.Append(o);
						}
						tristream.RestartStrip();
					}
				}
			}
			fixed4 frag(v2f i) : SV_Target
            {
				fixed4 color = tex2D(_MainTex, i.uv);
                clip(color.a - 0.001);
                color.rgb *= color.a;
                return color;
            }
		ENDCG
		}
	}
}
