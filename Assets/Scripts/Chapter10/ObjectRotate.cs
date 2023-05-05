using System;
using UnityEngine;

namespace Chapter10
{
    public class ObjectRotate : MonoBehaviour
    {
        public bool rotate;

        private void Update()
        {
            if (rotate)
            {
                transform.Rotate(Vector3.forward, 20 * Time.deltaTime);
            }
        }
    }
}