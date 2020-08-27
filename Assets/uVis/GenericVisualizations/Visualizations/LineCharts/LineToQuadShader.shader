﻿Shader "AugDisp/InfoVis/LineToQuadShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Size("Size", Range(0, 1)) = 0.5
		_Color("Main Color", Color) = (1,1,1,1)
	}

		SubShader
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Pass
			{
				Name "Onscreen geometry"
				Tags { "RenderType" = "Transparent" }
				//Zwrite On
				//ZTest LEqual
				//Blend[_MySrcMode][_MyDstMode]
				Cull Off
				//Lighting Off
				Offset -1, -1 // This line is added to default Unlit/Transparent shader
				//LOD 200

				CGPROGRAM
					#pragma target 5.0
					#pragma vertex VS_Main
					#pragma fragment FS_Main
					#pragma geometry GS_Main


			// **************************************************************
			// Data structures												*
			// **************************************************************

			struct VS_INPUT {
				float4 position : POSITION;
				float4 color: COLOR;
				float3 normal: NORMAL;
				float4 _MainTex : TEXCOORD0; // index, vertex size, filtered, prev size
			};

			struct GS_INPUT
			{
				float4	pos : SV_POSITION;
				float2  tex0 : TEXCOORD0;
				float4  color : COLOR;
				float3  normal : NORMAL;
			};

			struct FS_INPUT
			{
				float4	pos : POSITION;
				float2  tex0 : TEXCOORD0;
				float4  color : COLOR;
			};

			struct FS_OUTPUT
			{
				float4 color : COLOR;
				//float depth : SV_Depth;
			};

			// **************************************************************
			// Vars															*
			// **************************************************************

			float _Size;
			float4 _Color;
			sampler2D _MainTex;


			// **************************************************************
			// Shader Programs												*
			// **************************************************************

			// Vertex Shader ------------------------------------------------
			GS_INPUT VS_Main(VS_INPUT v)
			{
				GS_INPUT output;

				output.pos = v.position;
				output.tex0 = v._MainTex;
				output.color = v.color;
				output.normal = v.normal;

				return output;
			}

			// Geometry Shader -----------------------------------------------------
			[maxvertexcount(8)]
			void GS_Main(line GS_INPUT p[2], inout TriangleStream<FS_INPUT> triStream)
			{
				float3 l = (p[1].pos - p[0].pos);
				float4 d = float4(normalize(cross(l, p[0].normal)) * _Size * 0.5f, 1.0f);
				FS_INPUT pIn;

				pIn.color = p[0].color;
				pIn.pos = UnityObjectToClipPos(p[0].pos - d);
				pIn.tex0 = float2(1.0f, 0.0f);
				triStream.Append(pIn);

				pIn.pos = UnityObjectToClipPos(p[0].pos + d);
				pIn.tex0 = float2(0.0f, 0.0f);
				triStream.Append(pIn);

				pIn.color = p[1].color;
				pIn.pos = UnityObjectToClipPos(p[1].pos - d);
				pIn.tex0 = float2(1.0f, 1.0f);
				triStream.Append(pIn);

				pIn.pos = UnityObjectToClipPos(p[1].pos + d);
				pIn.tex0 = float2(0.0f, 1.0f);
				triStream.Append(pIn);
			}

			// Fragment Shader -----------------------------------------------
			FS_OUTPUT FS_Main(FS_INPUT input)
			{
				FS_OUTPUT o;
				o.color = tex2D(_MainTex, input.tex0.xy) * input.color * _Color;
				return o;
			}

			ENDCG
		} // end pass
		}
}