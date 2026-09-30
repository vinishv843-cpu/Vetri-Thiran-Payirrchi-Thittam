# ComicCraft — AI Comic Story Creator

ComicCraft is a FastAPI + Jinja2 web application that turns a user's story prompt into a five-panel comic. It follows the supplied project documentation's pipeline:

1. Gemini generates a structured five-panel outline.
2. Gemini expands the outline into narration, captions, and dialogue.
3. Hugging Face Inference Providers generate one illustration per panel using a configurable Stable Diffusion model.
4. The layout builder combines text and images.
5. FPDF2 exports the complete comic to PDF.

The original documentation used the legacy `google-generativeai` package and older Gemini 1.5 model names. This implementation uses Google's current `google-genai` SDK and current model configuration while keeping the documented architecture.

## Project structure

```text
ComicCraft/
├── app/
│   ├── main.py
│   ├── routes.py
│   ├── config.py
│   ├── schemas.py
│   ├── services/
│   │   ├── demo.py
│   │   ├── exporters.py
│   │   ├── gemini_flash.py
│   │   ├── gemini_pro.py
│   │   ├── image_generator.py
│   │   ├── layout_builder.py
│   │   └── pipeline.py
│   ├── templates/
│   │   ├── base.html
│   │   ├── index.html
│   │   ├── comic_preview.html
│   │   ├── export_success.html
│   │   └── error.html
│   └── static/
│       ├── css/style.css
│       ├── js/app.js
│       ├── panels/
│       └── exports/
├── tests/test_core.py
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md
```

## 1. Install Python

Use Python 3.11 or newer. Verify:

```powershell
python --version
```

## 2. Open the project in VS Code

Extract the ZIP, then open the `ComicCraft` folder in VS Code.

## 3. Create a virtual environment

Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

If PowerShell blocks activation, use Command Prompt:

```bat
.venv\Scripts\activate.bat
```

## 4. Install dependencies

```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

## 5. Configure API keys

Copy `.env.example` to `.env`:

```powershell
Copy-Item .env.example .env
```

Open `.env` and set:

```env
GEMINI_API_KEY=your_gemini_api_key_here
HF_TOKEN=your_huggingface_token_here
DEMO_MODE=false
GEMINI_AUTO_DEMO_FALLBACK=true
```

Do not commit `.env` to Git. It is ignored by `.gitignore`.

### Image provider

The default image configuration is:

```env
IMAGE_PROVIDER=hf
IMAGE_MODEL=stabilityai/stable-diffusion-3-medium-diffusers
```

The image generator uses Hugging Face's `InferenceClient(provider="auto")`. You can change `IMAGE_MODEL` to another compatible text-to-image model available to your Hugging Face Inference Providers account.

## 6. First test without API calls

For a safe end-to-end UI test, set:

```env
DEMO_MODE=true
```

Then run:

```powershell
uvicorn app.main:app --reload
```

Open:

- http://127.0.0.1:8000
- http://127.0.0.1:8000/docs
- http://127.0.0.1:8000/health

Demo mode creates five local placeholder images and a real PDF, so you can verify routing, templates, layout, static files, and PDF export before using paid/cloud AI inference.

## 7. Run with live AI

Set:

```env
DEMO_MODE=false
GEMINI_API_KEY=...
HF_TOKEN=...
```

Restart Uvicorn. A full generation makes multiple model calls and can take time depending on provider availability. If Gemini returns repeated temporary 503/429 capacity errors, `GEMINI_AUTO_DEMO_FALLBACK=true` lets the application finish with local demo story data and local placeholder artwork instead of failing the entire request.

## 8. API testing

### POST `/generate-comic/json`

Example JSON:

```json
{
  "story_prompt": "A brave fox explores an enchanted forest and discovers a glowing map.",
  "character_name": "Fenn",
  "setting": "enchanted forest",
  "tone": "dramatic",
  "art_style": "comic book"
}
```

### POST `/test-image`

Send a form field named `prompt` to test image generation without generating a full comic.

## 9. Tests

With the virtual environment active:

```powershell
pytest -q
```

## 10. Common errors

### `GEMINI_API_KEY is not configured`

Set `GEMINI_API_KEY` in `.env`, then restart Uvicorn.

### `HF_TOKEN is not configured`

Set `HF_TOKEN` in `.env`, or temporarily use `DEMO_MODE=true`.

### Image provider/model error

The configured Hugging Face model must support text-to-image through an available Inference Provider for your account. Try another current compatible model by changing `IMAGE_MODEL`.

### PowerShell says Python is not found

Install Python and reopen VS Code/PowerShell so the PATH change is picked up. Then verify with `python --version`.

### Port 8000 is already in use

Run:

```powershell
uvicorn app.main:app --reload --port 8001
```

Then open http://127.0.0.1:8001.

## Implementation notes

- The project intentionally does not store API keys in source code.
- The app uses Pydantic structured output for predictable five-panel outline/story objects.
- Image files are generated into `app/static/panels`.
- PDFs are generated into `app/static/exports`.
- The app keeps the documented `/`, `/generate`, `/generate-comic/json`, `/test-image`, and `/export-success` routes.
- The current Google GenAI SDK is used instead of the legacy `google-generativeai` package.
