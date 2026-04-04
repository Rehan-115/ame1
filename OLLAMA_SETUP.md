## Ollama Integration Setup Guide

This guide will help you set up Ollama for offline AI chatbot capabilities in AeroAssist.

### What is Ollama?

Ollama is a free, open-source tool that lets you run large language models (LLMs) locally on your computer without needing internet or cloud services. Your questions and answers stay completely private and local to your device.

### System Requirements

- **RAM**: At least 8 GB (16 GB recommended for faster responses)
- **Disk Space**: 5-10 GB per model
- **OS**: Windows, macOS, or Linux

### Installation Steps

#### 1. Download and Install Ollama

**Windows:**
1. Visit https://ollama.ai/download
2. Click "Download for Windows"
3. Run the installer and follow the setup wizard
4. Ollama will be installed as a system service

**macOS:**
1. Visit https://ollama.ai/download
2. Click "Download for macOS"
3. Open the .dmg file and drag Ollama to Applications
4. Launch Ollama from Applications

**Linux:**
```bash
curl https://ollama.ai/install.sh | sh
```

#### 2. Verify Installation

After installation, Ollama should automatically start. Verify it's running:

- **Windows/macOS**: Look for an Ollama icon in your system tray/menu bar
- **Linux**: Run `ollama list` to check status

#### 3. Download a Model

Open Terminal/Command Prompt and download a model:

**For Passenger Mode (Easy language):**
```bash
ollama pull mistral
```

**For Technician Mode (Technical terms):**
```bash
ollama pull llama2
```

**Fast & Lightweight Option:**
```bash
ollama pull orca-mini
```

Download time: 5-15 minutes depending on internet speed and model size

#### 4. Verify Model is Running

```bash
ollama list
```

You should see your downloaded model in the list with size info.

#### 5. Test Ollama Locally (Optional)

```bash
ollama run llama2
```

Type a question and press Enter. Type `exit` to quit.

### Using Ollama with AeroAssist

1. **Make sure Ollama is running** (before launching the app)
   - On Windows/macOS: Check the system tray
   - On Linux: Ollama runs as a service

2. **Launch AeroAssist** - it will automatically detect Ollama
   - ✓ Green indicator shows Ollama is connected
   - ⚠️ Gray indicator shows offline mode (keyword search)

3. **Chat Features**:
   - **Passenger Mode**: Simple, easy-to-understand responses
   - **Technician Mode**: Detailed technical explanations
   - **Offline**: Works even without Ollama (with keyword search fallback)

### Available Models

| Model | Size | Speed | Quality | Best For |
|-------|------|-------|---------|----------|
| orca-mini | 1.7 GB | Very Fast | Good | Quick answers |
| mistral | 5 GB | Fast | Excellent | Balanced |
| llama2 | 3.8 GB | Medium | Very Good | Technical content |
| neural-chat | 4.1 GB | Medium | Good | Conversations |
| dolphin-mixtral | 26 GB | Slow | Excellent | Complex queries |

### Troubleshooting

**Ollama not detected?**
- Ensure Ollama is running (check system tray/service)
- Verify it's listening on `http://localhost:11434`
- Restart the app

**Responses are slow?**
- Try a smaller model (orca-mini)
- Increase system RAM or close other apps
- Check internet (affects initial model download)

**Model won't download?**
- Ensure internet connection is stable
- Check available disk space (at least 10 GB free)
- Try again or use a smaller model

**Port 11434 already in use?**
- Another application is using this port
- Close Ollama and any other services on port 11434
- Restart Ollama

### Performance Tips

1. **Faster Responses**:
   - Use smaller models (orca-mini, mistral)
   - Close unnecessary apps to free up RAM
   - Use SSD rather than HDD

2. **Better Answers**:
   - Use larger models (llama2, neural-chat)
   - Ask clear, specific questions
   - Provide context in your questions

3. **Memory Management**:
   - Ollama models are loaded into RAM
   - Close unused models: `ollama stop <model-name>`
   - List running models: `ollama list`

### Advanced Configuration

**Change model in-app** (future feature):
- Settings → Ollama → Select Model

**Use different port**:
```bash
OLLAMA_HOST=0.0.0.0:8000 ollama serve
```
Then update `ollama_service.dart` to use your port.

### Privacy & Security

✓ All processing happens locally on your device  
✓ No data sent to cloud or external servers  
✓ No internet required after model download  
✓ Works offline for all chat functions  

### Getting Help

- Ollama Documentation: https://github.com/jart/ollama
- Model Library: https://ollama.ai/library
- GitHub Issues: https://github.com/jart/ollama/issues

---

**Happy offline chatting! 🚀**
