using System;
using UnityEngine;
using Random = UnityEngine.Random;

public class TerrainPrefabPopulation : MonoBehaviour
{
    [SerializeField] private Transform _terrain;
    [SerializeField] private float _offset;
    [SerializeField, Range(1,10)] private int _step = 1;
    
    [SerializeField] private Transform _content;
    [SerializeField] private GameObject _prefab;


    public void OnValidate()
    {
        if (_content == null)
            _content = transform;
    }

    [ContextMenu("Populate")]
    private void Populate()
    {
        var size = _terrain.localScale * 10;
        var pivot = _terrain.position;
        pivot.x += size.x / 2; 
        pivot.z += size.z / 2;
        // size *= 10;
        
        for (var x = 0; x < size.x; x += _step)
        {
            for (var z = 0; z < size.z; z += _step)
            {
                var offset = Random.insideUnitCircle * _offset;
                var position = new Vector3(x + offset.x, 0, z + offset.y) - pivot;
                Instantiate(_prefab, position,Quaternion.Euler(Vector3.up * Random.Range(0,360f)), _content);
            }
        }
    }
    
    [ContextMenu("Clear")]
    private void Clear()
    {
        foreach (var item in _content.GetComponentsInChildren<LODGroup>())
        {
            DestroyImmediate(item.gameObject);
        }
    }
}
