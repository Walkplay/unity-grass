Shader "Custom/Grass_GPUI"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _K("Shadow Intensity", float) = 1.0
        _P("Shadow Falloff",  float) = 1.0
    }
    SubShader
    {
        Tags{"RenderType" = "Transparent" "RenderPipeline" = "UniversalRenderPipeline" "IgnoreProjector" = "True" }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "UniversalForward" "PassFlags" = "OnlyDirectional"}
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // -------------------------------------
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            //#pragma multi_compile _ _SHADOWS_SOFT
            //#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            // -------------------------------------
            // Unity defined keywords
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            //#pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            //--------------------------------------
            // GPU Instancing
            //#pragma multi_compile_instancing
            
            #include "UnityCG.cginc"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"


            struct appdata
            {
                fixed4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                fixed4 position : SV_POSITION;
                fixed3 normal : NORMAL;
                fixed4 color: COLOR;
            };


            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            CBUFFER_START(UnityPerMaterial)
            uniform float4 _Color;
            float _Cutoff;
            float _K;
            float _P;
            CBUFFER_END

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            //UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            //UNITY_INSTANCING_BUFFER_END(Props)
        
            v2f vert (appdata v)
            {
                //v2f o;
                //o.vertex = UnityObjectToClipPos(v.vertex);
                //const fixed4 light = normalize(_WorldSpaceLightPos0);
                //const fixed4 norm = normalize( mul(v.normal, unity_WorldToObject) );

                // float4 ambientColor = { 0.5f, 0.5f, 0.5f, 1.0f};
                //o.color =  saturate(dot(light, norm));
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                //return o;
                v2f output;

				output.position = UnityObjectToClipPos(v.vertex);
				output.normal = UnityObjectToWorldNormal(v.normal);

				output.uv = v.uv;

//				TRANSFER_SHADOW(output); // shadows
                UNITY_TRANSFER_FOG(output,output.vertex);

				return output;
            }

            fixed4 frag (v2f input) : SV_Target
            {
				// _WorldSpaceLightPos0 provided by Unity
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// get dot product between surface normal and light direction
				float lightDot = dot(input.normal, lightDir);
                // do some math to make lighting falloff smooth
                lightDot = exp(-pow(_K*(1 - lightDot), _P));

                // lerp lighting between light & dark value
                //float3 light = lerp(_DarkColor, _BrightColor, lightDot);

				// sample texture for color
				float4 albedo = tex2D(_MainTex, input.uv.xy);
                clip( albedo.a - _Cutoff );

                // shadow value
                //float attenuation = LIGHT_ATTENUATION(input); 

                // composite all lighting together
                //float3 lighting = light;
                
                // multiply albedo and lighting
				float3 rgb = albedo.rgb * lightDot * _Color;
				UNITY_APPLY_FOG(input.fogCoord, albedo);
				//rgb += ShadeSH9(half4(input.normal,1));
				return float4(rgb, 1.0);
			}
            //{
            //    fixed4 col = tex2D(_MainTex, i.uv);
            //    col *= i.color + unity_AmbientSky + _Color;
            //    // apply fog
            //    clip( col.a - _AlphaCutoff );
//
            //    UNITY_APPLY_FOG(i.fogCoord, col);
            //    return col;
            //}
            
            

            ENDCG
        }
        Pass
    	{
            Tags 
			{
				"LightMode" = "ShadowCaster"
			}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
    	}
    }
}