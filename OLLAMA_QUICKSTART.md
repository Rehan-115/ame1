## Ollama Offline Chatbot - Quick Start

### What Just Happened?

Your AeroAssist app now has **offline AI chatbot** capabilities using Ollama! Here's what was added:

### Files Created/Updated

1. **`lib/services/ollama_service.dart`** (NEW)
   - Handles all communication with Ollama local LLM
   - Checks Ollama availability on startup
   - Generates responses with context-aware prompts
   - Supports both standard and streaming responses

2. **`lib/services/chat_service.dart`** (UPDATED)
   - Now integrated with OllamaService
   - Tries Ollama first for AI responses
   - Falls back to keyword search if Ollama unavailable
   - Auto-detects and switches between both modes

3. **`lib/ui/screens/chat_screen.dart`** (UPDATED)
   - Shows Ollama connection status in AppBar
   - Green dot = AI Powered (Ollama Connected)
   - Gray dot = Keyword Search (Ollama Offline)
   - Real-time status updates

4. **`OLLAMA_SETUP.md`** (NEW)
   - Complete installation guide
   - Model recommendations
   - Troubleshooting tips
   - Performance optimization

### Getting Started (3 Steps)

#### Step 1: Download Ollama
- Visit https://ollama.ai/download
- Download for your OS (Windows/Mac/Linux)
- Install and launch

#### Step 2: Get a Model
Open Terminal and run ONE of these:

**Option A: Fast & Lightweight (Recommended)**
```bash
ollama pull orca-mini
```

**Option B: Better Quality**
```bash
ollama pull mistral
```

**Option C: Most Detailed (Slower)**
```bash
ollama pull llama2
```

#### Step 3: Chat!
1. Make sure Ollama is running
2. Open AeroAssist app
3. Look for **green dot** in the chat screen (AI Powered!)
4. Start asking questions

### Features

✅ **Offline AI** - No internet required  
✅ **Private** - All data stays on your device  
✅ **Passenger Mode** - Easy, simple language  
✅ **Technician Mode** - Technical details and specs  
✅ **Fallback Mode** - Works even without Ollama  
✅ **Instant Switching** - Toggle modes while chatting  

### How It Works

**WITH Ollama (Connected):**
```
Your Question → Ollama AI → Intelligent Response
(Takes 5-30 seconds depending on model size)
```

**WITHOUT Ollama (Disconnected):**
```
Your Question → Keyword Search → Relevant Information
(Instant, but less contextual)
```

### Example Questions to Try

**Technician Mode:**
- "What's the torque spec for the landing gear?"
- "Explain the emergency hydraulic system check procedure"
- "What are the pressure readings for the fuel system?"

**Passenger Mode:**
- "How do I start a pre-flight inspection?"
- "What should I check before takeoff?"
- "Can you explain landing gear maintenance in simple terms?"

### Status Indicator Guide

| Indicator | Status | Meaning |
|-----------|--------|---------|
| 🟢 Green Dot | Connected | Ollama is running, AI-powered responses |
| ⚫ Gray Dot | Offline | Ollama not found, using keyword search |
| ⏳ While Typing | Processing | AI is generating response |

### Performance Stats

| Model | Size | Speed | Quality |
|-------|------|-------|---------|
| orca-mini | 1.7 GB | 2-5 sec | Good |
| mistral | 5 GB | 5-15 sec | Excellent |
| llama2 | 3.8 GB | 8-20 sec | Very Good |

### Troubleshooting

**"Gray dot - Ollama offline"?**
- Is Ollama running? (Check system tray)
- Is it on localhost:11434?
- Try restarting Ollama

**Slow responses?**
- Use smaller model (orca-mini)
- Close other apps
- Check available RAM (need 8GB+)

**Response quality is poor?**
- Use larger model (mistral, llama2)
- Ask more specific questions
- Provide context in your queries

### Advanced Tips

1. **Switch Models Easily**
   - Download multiple models
   - Currently uses first available
   - Future: Add UI to select model

2. **Run Custom Models**
   - Create your own model: `ollama create`
   - Fine-tune for aircraft maintenance
   - Load into AeroAssist

3. **Optimize for Server**
   - Change port in `ollama_service.dart`
   - Run Ollama on remote server
   - Keep app connected over network

### Environment Variables (Optional)

```bash
# Change default model
OLLAMA_MODEL=mistral

# Change port from 11434
OLLAMA_HOST=0.0.0.0:8000

# Increase timeout for slow machines
OLLAMA_TIMEOUT=120
```

### Architecture

```
┌─────────────────────────────┐
│   AeroAssist Chat Screen    │
└──────────────┬──────────────┘
               │
               ▼
        ┌──────────────┐
        │ Chat Service │
        └──────┬───────┘
               │
         ┌─────▼─────────┐
         │               │
    ┌────▼────┐    ┌─────▼──────┐
    │ Ollama  │    │  Keyword   │
    │Service  │    │  Search    │
    └────┬────┘    └─────┬──────┘
         │               │
    ┌────▼──────────────▼──┐
    │ AI Response / Answer │
    └──────────────────────┘
```

### Next Steps

1. **Setup**: Follow OLLAMA_SETUP.md
2. **Test**: Try simple questions first
3. **Explore**: Test both Passenger & Technician modes
4. **Optimize**: Monitor response quality and speed
5. **Integrate**: Add custom maintenance procedures to prompts

### Support Resources

- Ollama GitHub: https://github.com/jart/ollama
- Model Library: https://ollama.ai/library
- AeroAssist Docs: See README.md

---

**Your offline AI assistant is ready! 🚀**
