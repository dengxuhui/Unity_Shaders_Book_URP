Shader "dengxuhui/AlphaTest"
{
    Properties
    {
        _MainTex("Texture",2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        //透明度舍弃条件
        _Cutoff("Cutoff",Range(0,1)) = 0.5
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "Queue"="AlphaTest"
                "IgnoreProjector"="True"
                "RenderType"="TransparentCutout"
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;

            struct a2f
            {
                float4 vertex : POSITION;
                float3 normal : NOMRMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                clip(texColor.a - _Cutoff);
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0 * albedo * saturate(dot(worldNormal, worldLightDir));
                return fixed4(ambient + diffuse, 1.0);
            }
            ENDCG
        }

    }

    FallBack "Transparent/Cutout/VertexLit"

}