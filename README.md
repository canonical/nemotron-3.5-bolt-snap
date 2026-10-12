# Nemotron 3.5 Bolt inference snap
[![nemotron-3-5-bolt](https://snapcraft.io/nemotron-3-5-bolt/badge.svg)](https://snapcraft.io/nemotron-3-5-bolt)

Nemotron 3.5 Bolt 74B A9B is a large language model from NVIDIA built with a hybrid Mixture-of-Experts (MoE) architecture, compressed from Nemotron 3.5 Super.
The routed and shared experts, which make up most of the model weights, are quantized to IQ2_XXS (2.06 bits), the Mamba layers are kept in NVFP4 and the LM head is in Q8_0.

Use this snap to quickly install an optimized environment for local inference with Nemotron 3.5 Bolt.

The snap includes the following hardware-optimized inference engines:

* nvidia-gpu: CUDA-enabled GPU acceleration

An NVIDIA GPU is required.

#### Install
```
sudo snap install nemotron-3-5-bolt
```

#### Run
```
nemotron-3-5-bolt
```

> [!TIP]
> Some accelerators require extra [drivers](https://documentation.ubuntu.com/inference-snaps/how-to/setup/drivers/) to be usable with this snap.

## Resources

📚 **[Documentation](https://documentation.ubuntu.com/inference-snaps/)**, learn how to use inference snaps

💬 **[Discussions](https://github.com/canonical/inference-snaps/discussions)**, ask questions and share ideas

🐛 **[Issues](https://github.com/canonical/inference-snaps/issues)**, report bugs and request features

## Build and install from source

Clone the repo:
```shell
git clone https://github.com/canonical/nemotron-3.5-bolt-snap
cd nemotron-3.5-bolt-snap
```

Initialize the development environment:
```shell
make init
```

Build and install snap:
```shell
make build
make install
```
