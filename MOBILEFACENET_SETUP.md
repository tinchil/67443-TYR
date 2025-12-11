# MobileFaceNet Setup Guide

This guide will help you convert and integrate the MobileFaceNet model for face recognition in your iOS app.

## Overview

MobileFaceNet is a lightweight face recognition model that generates 128-dimensional embeddings for faces. We'll convert it from PyTorch/TensorFlow to CoreML format for use in iOS.

## Prerequisites

- Python 3.8+ with pip
- Xcode 14+
- coremltools Python package

## Step 1: Install Python Dependencies

```bash
pip install coremltools torch torchvision onnx onnx-coreml numpy
```

## Step 2: Download Pre-trained MobileFaceNet Model

You have several options:

### Option A: Use a Pre-converted Model (Easiest)
Some repositories provide pre-converted CoreML models. Search for "MobileFaceNet CoreML" on GitHub.

### Option B: Convert from PyTorch/TensorFlow (Recommended)

1. Clone the MobileFaceNet repository:
```bash
git clone https://github.com/foamliu/MobileFaceNet.git
cd MobileFaceNet
```

2. Download the pre-trained weights (usually a `.pth` or `.pb` file)

## Step 3: Convert Model to CoreML

Create a Python script `convert_to_coreml.py`:

```python
import torch
import coremltools as ct
import numpy as np

# Load the PyTorch model
# Adjust this based on your model architecture
class MobileFaceNet(torch.nn.Module):
    def __init__(self):
        super(MobileFaceNet, self).__init__()
        # Define your model architecture here
        # This should match the architecture from the repository
        pass

    def forward(self, x):
        # Forward pass
        pass

# Load pre-trained weights
model = MobileFaceNet()
model.load_state_dict(torch.load('mobilefacenet_model.pth'))
model.eval()

# Create example input
example_input = torch.rand(1, 3, 112, 112)  # MobileFaceNet typically uses 112x112 images

# Trace the model
traced_model = torch.jit.trace(model, example_input)

# Convert to CoreML
mlmodel = ct.convert(
    traced_model,
    inputs=[ct.TensorType(name="input", shape=(1, 3, 112, 112))],
    outputs=[ct.TensorType(name="embedding")],
    minimum_deployment_target=ct.target.iOS15
)

# Set metadata
mlmodel.short_description = "MobileFaceNet for face recognition"
mlmodel.author = "Your Name"
mlmodel.license = "MIT"
mlmodel.version = "1.0"

# Set input/output descriptions
mlmodel.input_description["input"] = "Input face image (112x112, RGB)"
mlmodel.output_description["embedding"] = "128-dimensional face embedding"

# Save the model
mlmodel.save("MobileFaceNet.mlmodel")
print("✅ Model converted successfully!")
```

3. Run the conversion:
```bash
python convert_to_coreml.py
```

## Step 4: Alternative - Use ONNX as Intermediate Format

If direct PyTorch→CoreML conversion doesn't work:

```python
import torch
import onnx
from onnx_coreml import convert

# Export to ONNX first
model = MobileFaceNet()
model.eval()
dummy_input = torch.rand(1, 3, 112, 112)

torch.onnx.export(
    model,
    dummy_input,
    "mobilefacenet.onnx",
    export_params=True,
    opset_version=12,
    input_names=['input'],
    output_names=['embedding']
)

# Convert ONNX to CoreML
ml_model = convert(
    model='mobilefacenet.onnx',
    minimum_ios_deployment_target='15'
)

ml_model.save('MobileFaceNet.mlmodel')
```

## Step 5: Add Model to Xcode Project

1. Drag `MobileFaceNet.mlmodel` into your Xcode project
2. Make sure "Target Membership" is checked for your app target
3. Xcode will automatically generate a Swift class for the model

## Step 6: Update FaceEmbeddingService.swift

Once the model is added, update the lazy var in `FaceEmbeddingService.swift`:

```swift
private lazy var model: VNCoreMLModel? = {
    do {
        let config = MLModelConfiguration()

        // Use the auto-generated model class
        let mobileFaceNet = try MobileFaceNet(configuration: config)
        return try VNCoreMLModel(for: mobileFaceNet.model)
    } catch {
        print("❌ Failed to load MobileFaceNet model: \(error)")
        return nil
    }
}()
```

## Step 7: Test the Implementation

Run your app and check the console logs:
- ✅ "Generated face embedding with dimension: 128" - Success!
- ⚠️ "No faces detected in image" - Normal for photos without faces
- ❌ "Failed to load MobileFaceNet model" - Check model file and import

## Troubleshooting

### Model Won't Convert
- Try using a different opset version (10, 11, or 12)
- Check if the model architecture is fully supported by CoreML
- Consider using coremltools 6.0+ for better support

### Model Too Large
- MobileFaceNet should be ~1-4MB
- If larger, check if you've included unnecessary layers
- Consider quantization: `mlmodel = ct.models.neural_network.quantization_utils.quantize_weights(mlmodel, nbits=8)`

### Wrong Output Shape
- Verify the model outputs a 128-dimensional vector
- Check the model architecture matches the original paper
- Print model outputs during conversion to debug

### Runtime Errors
- Ensure input images are 112x112 RGB
- Check that face cropping is working correctly
- Verify the model file is included in the app bundle

## Alternative: Use Pre-trained iOS Models

If conversion is too complex, consider these alternatives:

1. **Apple's Vision Framework** - Built-in face detection and recognition (no custom model needed)
2. **Face.com SDK** - Commercial solution with pre-built iOS support
3. **Firebase ML Kit** - Google's face detection and recognition

## Model Performance

- **Speed**: ~5-20ms per face on modern iPhones
- **Accuracy**: 98-99% on LFW benchmark
- **Size**: ~2-4MB (quantized)
- **Memory**: ~10-20MB during inference

## Next Steps

1. Tune the similarity threshold in `FaceClusterService.swift` (line 24)
2. Add face cluster UI to display grouped photos
3. Optimize performance for large photo libraries
4. Add background processing for face detection

## Resources

- [MobileFaceNet Paper](https://arxiv.org/abs/1804.07573)
- [CoreMLTools Documentation](https://coremltools.readme.io/)
- [Apple Vision Framework](https://developer.apple.com/documentation/vision)
- [PyTorch to CoreML Guide](https://coremltools.readme.io/docs/pytorch-conversion)

## License

Make sure to comply with the MobileFaceNet model license when using it in your app.
