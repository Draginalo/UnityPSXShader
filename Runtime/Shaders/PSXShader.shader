Shader "Custom/PSXShader"
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
            Tags { "LightMode" = "Vertex" }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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
                UNITY_FOG_COORDS(1)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AffineFactor;
            int _VertexJitterSmoother;
            float _VertexJitterFalloffFactor;
            float _LightCutoff;

            float invLerp(float from, float to, float value)
            {
	            return (value - from) / (to - from);
            }

            float3 PSXLighting(float4 viewpos, float3 viewN)
            {
                //Gets Unity ambient color
	            fixed3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

	            for (int i = 0; i < unity_LightPosition.Length; i++)
	            {
                    //Calculates direction vector and light distence from light to point
		            fixed3 toLight = unity_LightPosition[i].xyz - viewpos.xyz;
		            fixed lightDist = length(toLight);
		            toLight = normalize(toLight);

		            // Don't produce NaNs if some vertex position overlaps with the light
		            lightDist = max(lightDist, 0.000001);

                    //Gets light range since unity_LightAtten[i].w is range*range
		            float lightRange = sqrt(unity_LightAtten[i].w);

                    //Calculates light intensity/falloff (attenuation) from light distence and cutoff value
		            fixed atten = 1 - invLerp(lightRange * _LightCutoff, lightRange, lightDist);

                    //For spotlights
		            float rho = max(0, dot(toLight, unity_SpotDirection[i].xyz)); //Calculates angle between light vec and spot direction (Non spot lights return (0, 0, 1, 0))
			        float spotAtt = (rho - unity_LightAtten[i].x) * unity_LightAtten[i].y; //Calculates light intensity (new attenuation) from angle and old light attenuation 
			        atten *= saturate(spotAtt); //Clamps light attenuation

                    //Calculates diffuse lighting 
		            float diff = max(0, dot(viewN, toLight));

                    //Adds color to final light color
		            lightColor += unity_LightColor[i].rgb * saturate(atten) * diff;
	            }
	            return lightColor;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, v.vertex)));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //Vertex Jitter
                float fallOff = max(1.0, o.vertex.w * _VertexJitterFalloffFactor);
	            o.vertex.xy = floor(o.vertex.xy / fallOff * _VertexJitterSmoother) / _VertexJitterSmoother * fallOff;

                //Start UV Affline Mapping
                float w = lerp(1.0 , max(o.vertex.w, 0.1), _AffineFactor); //Scales affine affect
                o.uv *= w;
                o.affineW = w;

                //Lighting
                fixed3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_MV, v.normal));
	            o.color.rgb = PSXLighting(mul(UNITY_MATRIX_MV, v.vertex), viewNormal);
                o.color.a = 1.0;

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 newUV = i.uv;
                newUV /= i.affineW;

                // sample the texture
                float4 col = tex2D(_MainTex, newUV);
                col *= i.color;

                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDCG
        }
    }
}
