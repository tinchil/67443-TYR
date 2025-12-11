#!/usr/bin/env python3
"""
Script to convert MobileFaceNet from PyTorch to CoreML
Requires: torch, coremltools, numpy
"""

import torch
import torch.nn as nn
import coremltools as ct
import numpy as np

# ============================================
# MobileFaceNet Architecture Definition
# ============================================

class Flatten(nn.Module):
    def forward(self, x):
        return x.view(x.size(0), -1)

class ConvBlock(nn.Module):
    def __init__(self, in_c, out_c, kernel=(1, 1), stride=(1, 1), padding=(0, 0), groups=1):
        super(ConvBlock, self).__init__()
        self.conv = nn.Conv2d(in_c, out_c, kernel_size=kernel, groups=groups, stride=stride, padding=padding, bias=False)
        self.bn = nn.BatchNorm2d(out_c)
        self.prelu = nn.PReLU(out_c)

    def forward(self, x):
        x = self.conv(x)
        x = self.bn(x)
        x = self.prelu(x)
        return x

class LinearBlock(nn.Module):
    def __init__(self, in_c, out_c, kernel=(1, 1), stride=(1, 1), padding=(0, 0), groups=1):
        super(LinearBlock, self).__init__()
        self.conv = nn.Conv2d(in_c, out_c, kernel_size=kernel, groups=groups, stride=stride, padding=padding, bias=False)
        self.bn = nn.BatchNorm2d(out_c)

    def forward(self, x):
        x = self.conv(x)
        x = self.bn(x)
        return x

class DepthWise(nn.Module):
    def __init__(self, in_c, out_c, residual=False, kernel=(3, 3), stride=(2, 2), padding=(1, 1), groups=1):
        super(DepthWise, self).__init__()
        self.residual = residual
        self.conv1 = ConvBlock(in_c, groups, kernel=(1, 1), padding=(0, 0), stride=(1, 1))
        self.conv2 = ConvBlock(groups, groups, kernel=kernel, padding=padding, stride=stride, groups=groups)
        self.conv3 = LinearBlock(groups, out_c, kernel=(1, 1), padding=(0, 0), stride=(1, 1))

    def forward(self, x):
        out = self.conv1(x)
        out = self.conv2(out)
        out = self.conv3(out)
        if self.residual:
            out += x
        return out

class Residual(nn.Module):
    def __init__(self, c, num_block, groups, kernel=(3, 3), stride=(1, 1), padding=(1, 1)):
        super(Residual, self).__init__()
        modules = []
        for _ in range(num_block):
            modules.append(DepthWise(c, c, True, kernel, stride, padding, groups))
        self.model = nn.Sequential(*modules)

    def forward(self, x):
        return self.model(x)

class MobileFaceNet(nn.Module):
    def __init__(self, embedding_size=128):
        super(MobileFaceNet, self).__init__()
        self.conv1 = ConvBlock(3, 64, kernel=(3, 3), stride=(2, 2), padding=(1, 1))
        self.conv2 = ConvBlock(64, 64, kernel=(3, 3), stride=(1, 1), padding=(1, 1), groups=64)
        self.conv3 = DepthWise(64, 64, kernel=(3, 3), stride=(2, 2), padding=(1, 1), groups=128)
        self.conv4 = Residual(64, num_block=4, groups=128, kernel=(3, 3), stride=(1, 1), padding=(1, 1))
        self.conv5 = DepthWise(64, 128, kernel=(3, 3), stride=(2, 2), padding=(1, 1), groups=256)
        self.conv6 = Residual(128, num_block=6, groups=256, kernel=(3, 3), stride=(1, 1), padding=(1, 1))
        self.conv7 = DepthWise(128, 128, kernel=(3, 3), stride=(2, 2), padding=(1, 1), groups=512)
        self.conv8 = Residual(128, num_block=2, groups=256, kernel=(3, 3), stride=(1, 1), padding=(1, 1))
        self.conv9 = ConvBlock(128, 512, kernel=(1, 1), stride=(1, 1), padding=(0, 0))
        self.conv10 = LinearBlock(512, 512, kernel=(7, 7), stride=(1, 1), padding=(0, 0), groups=512)
        self.flatten = Flatten()
        self.linear = nn.Linear(512, embedding_size, bias=False)
        self.bn = nn.BatchNorm1d(embedding_size)

    def forward(self, x):
        out = self.conv1(x)
        out = self.conv2(out)
        out = self.conv3(out)
        out = self.conv4(out)
        out = self.conv5(out)
        out = self.conv6(out)
        out = self.conv7(out)
        out = self.conv8(out)
        out = self.conv9(out)
        out = self.conv10(out)
        out = self.flatten(out)
        out = self.linear(out)
        out = self.bn(out)
        return out

# ============================================
# Conversion Script
# ============================================

def convert_to_coreml():
    print("🚀 Starting MobileFaceNet conversion to CoreML...")

    # 1. Create model
    model = MobileFaceNet(embedding_size=128)
    model.eval()

    # 2. Load pre-trained weights
    # Download from: https://github.com/foamliu/MobileFaceNets/releases/download/v1.0/mobilefacenet.pt
    try:
        checkpoint = torch.load('mobilefacenet.pt', map_location='cpu')
        model.load_state_dict(checkpoint)
        print("✅ Loaded pre-trained weights")
    except FileNotFoundError:
        print("⚠️  WARNING: mobilefacenet.pt not found!")
        print("   Download from: https://github.com/foamliu/MobileFaceNets/releases/download/v1.0/mobilefacenet.pt")
        print("   Continuing with random weights for testing...")

    # 3. Create example input (112x112 RGB image)
    example_input = torch.rand(1, 3, 112, 112)

    # 4. Test forward pass
    with torch.no_grad():
        output = model(example_input)
        print(f"✅ Model output shape: {output.shape}")
        assert output.shape == (1, 128), "Output should be (1, 128)"

    # 5. Trace the model
    print("📦 Tracing model...")
    traced_model = torch.jit.trace(model, example_input)

    # 6. Convert to CoreML
    print("🔄 Converting to CoreML...")
    mlmodel = ct.convert(
        traced_model,
        inputs=[ct.ImageType(
            name="input",
            shape=(1, 3, 112, 112),
            scale=1/255.0,  # Normalize to [0, 1]
            bias=[0, 0, 0],
            color_layout=ct.colorlayout.RGB
        )],
        outputs=[ct.TensorType(name="embedding")],
        minimum_deployment_target=ct.target.iOS15,
        compute_precision=ct.precision.FLOAT16  # Use FP16 for smaller size
    )

    # 7. Set metadata
    mlmodel.author = "MobileFaceNet - Converted"
    mlmodel.license = "Apache 2.0"
    mlmodel.short_description = "Face recognition model generating 128-dimensional embeddings"
    mlmodel.version = "1.0"

    mlmodel.input_description["input"] = "Face image (112x112, RGB, normalized to [0,1])"
    mlmodel.output_description["embedding"] = "128-dimensional L2-normalized face embedding"

    # 8. Save the model
    output_path = "MobileFaceNet.mlmodel"
    mlmodel.save(output_path)

    print(f"✅ Model saved to {output_path}")
    print(f"📊 Model size: {os.path.getsize(output_path) / 1024 / 1024:.2f} MB")
    print("\n🎉 Conversion complete! Add this file to your Xcode project.")

if __name__ == "__main__":
    import os
    convert_to_coreml()
