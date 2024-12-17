Shader "PSX/PSXShaderURP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float affineW : float;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AffineFactor;
            int _VertexJitterSmoother;
            float _VertexJitterFalloffFactor;

            float invLerp(float from, float to, float value)
            {
	            return (value - from) / (to - from);
            }

            float3 ShadePSXVertexLightsFull(float4 viewpos, float3 viewN, bool spotLight = true)
{
	            float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

	            for (int i = 0; i < GetAdditionalLightsCount(); i++)
	            {
		            float3 toLight = GetAdditionalLight(i, viewpos).direction;
		            float3 lightDist = GetAdditionalLight(i, viewpos).distanceAttenuation;

		            // don't produce NaNs if some vertex position overlaps with the light
		            lightDist = max(lightDist, 0.000001);

		            float lightRange = 1.0 / (1.0 + lightDist);
		            float3 atten = invLerp(lightRange * 0, lightRange, lightDist);
		            if (spotLight)
		            {
		                
		            }

		            float diff = max(0, dot(viewN, toLight));
		            lightColor += GetAdditionalLight(i, viewpos).color.rgb * saturate(atten) * diff;
	            }
	            return lightColor;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //Vertex Jitter
                float fallOff = max(1.0, o.vertex.w * _VertexJitterFalloffFactor);
	            o.vertex.xy = floor(o.vertex.xy / fallOff * _VertexJitterSmoother) / _VertexJitterSmoother * fallOff;

                //Start UV Affline Mapping
                float w = lerp(1.0 , max(o.vertex.w, 0.1), _AffineFactor); //Scales affine affect
                o.uv *= w;
                o.affineW = w;

                //Lighting
                float3 viewNormal = normalize(mul(UNITY_MATRIX_M, v.normal));
                o.color.rbg = ShadePSXVertexLightsFull(mul(UNITY_MATRIX_M, v.vertex), viewNormal);
                o.color.a = 1.0;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 newUV = i.uv;
                newUV /= i.affineW;

                // sample the texture
                float4 col = tex2D(_MainTex, newUV);
                col *= i.color;

                // apply fog
                return col;
            }
            ENDHLSL
        }
    }
}
