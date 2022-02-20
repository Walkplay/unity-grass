using System;
using Cinemachine;
using UnityEditor;
using UnityEngine;

public class DemoController : MonoBehaviour
{
    [SerializeField] private CinemachineDollyCart _cinemachineDollyCart;
    [SerializeField] private Transform[] _transforms;
    private GUILayoutOption[] _layoutOptions;

    private float frameCount = 0f;
    private float dt = 0.0f;
    private float fps = 0.0f;
    private float updateRate = 4.0f;  // 4 updates per sec.
 
    private void Update()
    {
        frameCount++;
        dt += Time.deltaTime;
        if (dt > 1.0f / updateRate)
        {
            fps = frameCount / dt ;
            frameCount = 0;
            dt -= 1.0f / updateRate;
        }
    }

    private void OnGUI()
    {
        GUIStyle style = new GUIStyle ();
        style.fontSize = (int) (Screen.height * 0.09f);
        _layoutOptions = new[]
        {
            GUILayout.Height(Screen.height * 0.09f),
            GUILayout.ExpandHeight(true)
        };
        GUILayout.BeginArea(new Rect(new Vector2(0, 0), new Vector2(Screen.width/4, Screen.height)));
        var speedValue = GUILayout.HorizontalSlider(_cinemachineDollyCart.m_Speed, -20, 20,style, style, _layoutOptions);
        
        GUILayout.BeginVertical();
        if (GUILayout.Button("Stop", style, _layoutOptions))
            speedValue = 0;
        
        _cinemachineDollyCart.m_Speed = speedValue;
        for (int i = 0; i < _transforms.Length; i++)
        {
            var item = _transforms[i];
            var itemActive = GUILayout.Toggle(item.gameObject.activeInHierarchy, item.name, style, _layoutOptions);
            item.gameObject.SetActive(itemActive);
        }
        GUILayout.EndVertical();    
        GUILayout.EndArea();
        GUI.Label(new Rect(new Vector2(Screen.width/2, 0), Vector2.one * 200), fps.ToString("000"), style);
    }
}
