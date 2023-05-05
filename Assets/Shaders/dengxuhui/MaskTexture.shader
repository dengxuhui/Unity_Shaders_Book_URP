Shader "dengxuhui/MaskTexture"
{
    Properties
    {
        _Color ("Color Tint",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Bump Map", 2D) = "bump" {}
        _BumpScale("Bump Scale", Float) = 1.0
        //遮罩纹理
        _SpecularMask("Specular Mask", 2D) = "white" {}
        //遮罩纹理的影响系数
        _SpecularScale("Specular Scale", Float) = 1.0
        _SpecularColor("Specular Color", Color) = (1,1,1,1)
        _Glossiness("Glossiness", Range(0,1)) = 0.5
    }


    SubShader
    {

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _SpecularColor;
            float _Glossiness;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGETN;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex).xyz);
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex).xyz);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));
                //半兰伯特光照
                // fixed3 diffuse_halflambert = _LightColor0.rgb * albedo * saturate(
                //     dot(tangentNormal, tangentLightDir) * 0.5 + 0.5);
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(
                    saturate(dot(tangentNormal, halfDir)), _Glossiness * 256) * specularMask;

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }

    FallBack "Specular"
}