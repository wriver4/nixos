{ ... }:

{
  imports = [
    ./text_editors.nix
    ./browsers.nix
    ./media.nix
    ./communication.nix
    ./security.nix
    ./development.nix
    ./networking.nix
    ./system_tools.nix
  ];

  # Commented AI packages from original gui.nix
  # AI
  # lmstudio
  # vllm
  # llama-cpp
  # openai-whisper
  # whisperx
  # stable-diffusion-webui
  # ollama
  # ollama-cuda
  # gollama

  # Commented support packages from original gui.nix
  # support
  # rustdesk
}
