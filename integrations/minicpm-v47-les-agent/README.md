# MiniCPM-V 4.7 35B-A3B LES — reproducible Mac / OpenAI Agent integration

This directory stores the **tested LES integration as a patch series**, without replacing the existing `ggml-org/llama.cpp` fork on `master`.

The tested engine is **`tc-mb/llama.cpp-omni`**, branch `ios-omni`, pinned to **`96bbf61710d44421ea54e63f5194f9b17c20d877`**. This codebase differs from the conventional `llama.cpp` master. Do **not** apply these patches directly to this repository's `master`: its server-context and expert-streaming APIs are not interchangeable.

## Recreate the exact tested code

On macOS (with `git`, `cmake`, Python 3 and Metal build dependencies):

```bash
bash integrations/minicpm-v47-les-agent/bootstrap.sh ~/src/llama.cpp-omni-les
cd ~/src/llama.cpp-omni-les
python3 -m unittest discover -s tools/les-openai-bridge -p 'test_*.py'
```

The script checks out the pinned omni commit, applies the three Git `format-patch` files in order with `git am`, and verifies the full source tree hash. **Expected tree:** `cfeba69a1d1ed55aa1e1988235bf3315bffabf33`. It refuses an existing output directory. The `Git` history inside the generated project records the original three patches and authorship.

## What is included

- `0001` — loopback-only Python OpenAI-compatible Tool Calling bridge and tests.
- `0002` — optional C++ resident LES HTTP target (`llama-les-native-server`), compatible with the pinned `ios-omni` server APIs; Mac Metal + SWA KV-cache performance report.
- `0003` — preflight Bootstrap Coding Agent, reproducible `SessionRegistry` fixture, 6-unit-test demonstration and parameter comparison.

On an **Apple M4 Mac mini, 16GB RAM**, 14/14 integration unit tests passed on the reconstructed source. Full native agent repair (real tool calls, patch, tests, final answer) passed 6/6 tests in **273.6s** using host read/test preflight, compared with **362.4s** for the native baseline. These are **single-run observations**, not statistically validated speedups. The temporary prompt-only bridge was slower than a native resident server. Keep the verified experimental settings: **expert bank 128; ubatch 16; context 4096; `--swa-full --cache-prompt`; LES prefetch disabled**.

## Attribution and safety

This is a patch bundle for a distinct upstream with its existing license and attribution retained. Do not distribute the model weights or any personal SSD data with this repo. The generated host-side agent executes Python test fixtures; its AST allowlist is **not an OS sandbox**. Keep the HTTP service on loopback and do not expose without authentication/sandboxing. The patch-series rebuild is deterministic to the expected Git tree; large-model performance requires the original external model weights and a compatible Mac to reproduce.

## Why not an in-place change to `master`?

This repository follows stock `llama.cpp`; the experiment was built and tested on the separate `tc-mb/llama.cpp-omni` codebase with its custom SSD-expert layer implementation. Transplanting its `tools/server/CMakeLists.txt` unmodified into stock master is not a valid integration. The patch bundle keeps both trees safe, preserves exact reproducibility and can later be ported intentionally.
