using UnityEngine;

public class DiamondSpinner : MonoBehaviour 
{
    [SerializeField]
    [Range(0, 100)]
    private float _rotationSpeed = 1;
    private Transform _transform;

    private void Start()
    {
        _transform = transform;
    }

    void Update ()
    {
        _transform.Rotate(new Vector3(Time.deltaTime, Time.deltaTime, Time.deltaTime) * _rotationSpeed);
	}
}
