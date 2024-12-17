using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PixelizeFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class CustomPassSettings
    {
        public RenderPassEvent mRenderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        public int mScreenHeight = 144;
    }

    [SerializeField] private CustomPassSettings mPassSettings;
    private PixelizePass mPixelizePass;

    /// <inheritdoc/>
    public override void Create()
    {
        mPixelizePass = new PixelizePass(mPassSettings);
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(mPixelizePass);
    }
}


