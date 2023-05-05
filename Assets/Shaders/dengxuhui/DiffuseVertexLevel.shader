// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "dengxuhui/DiffuseVertexLevel"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex:POSITION;
                //通过使用NORMAL语义告诉Unity要把模型顶点的法线信息存储到normal变量中
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                //这里不是必须使用COLOR语义，有些地方会使用TEXCOORD0语义
                fixed3 color : COLOR;
            };

            v2f vert(a2v v)
            {
                v2f o;
                //逐顶点光照模型
                //模型坐标到投影坐标
                o.pos = UnityObjectToClipPos(v.vertex);
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //世界空间下的法向量
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                //漫反射光照
                fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * max(0, dot(worldNormal, worldLight));

                o.color = ambient + diffuse;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }

    }

    FallBack "Diffuse"
}