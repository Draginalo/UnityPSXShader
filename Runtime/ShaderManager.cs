using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PSX.ToolKit
{
    [ExecuteAlways]
    public class PSXShaderManager : MonoBehaviour
    {
        [Header("Texture Mapping")]
        [SerializeField][Range(0.0f, 1.0f)] private float _AffineFactor = 1.0f;

        [Header("Vertex Jitter")]
        [SerializeField] private int _VertexJitterSmoother = 40;
        [SerializeField][Range(0.0f, 1.0f)] private float _VertexJitterFalloffFactor = 0.5f;

        [Header("Lighting")]
        [SerializeField][Range(0.0f, 1.0f)] private float _LightCutoff = 0.5f;

        // Start is called before the first frame update
        void Start()
        {
            setShaderValues();
        }

        // Update is called once per frame
        void OnValidate()
        {
            setShaderValues();
        }

        private void setShaderValues()
        {
            Shader.SetGlobalFloat("_AffineFactor", _AffineFactor);
            Shader.SetGlobalInt("_VertexJitterSmoother", _VertexJitterSmoother);
            Shader.SetGlobalFloat("_VertexJitterFalloffFactor", _VertexJitterFalloffFactor);
            Shader.SetGlobalFloat("_LightCutoff", _LightCutoff);
        }
    }
}