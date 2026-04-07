import httpx


class OllamaClient:
    """
    Async HTTP client for the Ollama API (native format).
    Used for direct benchmarking against Ollama, bypassing OpenWebUI.
    Useful for isolating inference latency from middleware overhead.
    """

    def __init__(self, base_url: str, model: str, timeout: int = 300):
        """
        Parameters:
            base_url : Base URL of the Ollama server (e.g. http://10.64.126.15:11434)
            model    : Model identifier to use in requests (e.g. qwen2.5:32b)
            timeout  : Request timeout in seconds (default 300)
        """
        self.base_url = base_url
        self.model    = model
        self.timeout  = timeout
        self.endpoint = f"{base_url}/api/generate"

    async def ask(self, client: httpx.AsyncClient, prompt: str, temperature: float = 0) -> str:
        """
        Sends a single generate request to Ollama and returns the response text.

        Parameters:
            client      : Shared httpx.AsyncClient instance
            prompt      : Prompt to send
            temperature : Sampling temperature (default 0 for deterministic output)

        Returns:
            Model response as a string
        """
        payload = {
            "model"   : self.model,
            "prompt"  : prompt,
            "stream"  : False,
            "options" : {"temperature": temperature}
        }

        r = await client.post(
            self.endpoint,
            json=payload,
            timeout=self.timeout
        )

        r.raise_for_status()
        data = r.json()

        if data is None:
            raise ValueError("Ollama returned empty response (None)")

        if "response" not in data:
            raise ValueError(f"Unexpected response format: {str(data)[:200]}")

        return data["response"]

    async def validate_model(self) -> None:
        """
        Validates that the configured model exists in Ollama and responds correctly
        before running the full benchmark.

        Raises:
            ValueError : If the model is not found or returns an unexpected response.
        """
        async with httpx.AsyncClient() as client:

            # Check model exists via /api/tags
            r = await client.get(f"{self.base_url}/api/tags", timeout=30)
            r.raise_for_status()
            tags = r.json()
            available = [m["name"] for m in tags.get("models", [])]

            if self.model not in available:
                raise ValueError(
                    f"Model '{self.model}' not found in Ollama. "
                    f"Available: {', '.join(available)}"
                )

            # Send a minimal test request
            print(f"[validate] Model '{self.model}' found — sending test request...")
            response = await self.ask(client, "hola")
            if not response:
                raise ValueError(f"Model '{self.model}' returned empty response.")
            print(f"[validate] Model '{self.model}' OK ✓")
