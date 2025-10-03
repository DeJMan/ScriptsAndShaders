Shader "Unlit/TransparentTextureWithShadows"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _ShadowIntensity("Shadow Intensity", Range(0,1)) = 1
    }

        SubShader
        {
            Tags { "RenderType" = "TransparentCutout" "Queue" = "AlphaTest" }
            LOD 100
            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha

            Pass
            {
                Tags { "LightMode" = "ForwardBase" }

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase
                #pragma target 3.0``    

                #include "UnityCG.cginc"
                #include "AutoLight.cginc"

                sampler2D _MainTex;
                float4 _MainTex_ST;
                fixed4 _Color;
                float _ShadowIntensity;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv     : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv  : TEXCOORD0;
                    SHADOW_COORDS(1)
                };

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    TRANSFER_SHADOW(o);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                    // Multiply shadow by intensity (0 = no shadow, 1 = normal)
                    fixed shadow = SHADOW_ATTENUATION(i);
                    shadow = lerp(1.0, shadow, _ShadowIntensity);

                    col.rgb *= shadow;
                    return col;
                }
                ENDCG
            }
        }

        FallBack "Transparent/Cutout/VertexLit"
}
