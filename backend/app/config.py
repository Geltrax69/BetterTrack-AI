"""Typed settings loaded from environment / .env (see .env.example)."""
from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "BetterTrack AI"
    environment: str = "development"
    host: str = "0.0.0.0"
    port: int = 8000
    cors_origins: str = "*"

    # AI
    ai_provider: str = "gemini"  # gemini | anthropic
    gemini_api_key: str = ""
    gemini_model: str = "gemini-flash-latest"
    anthropic_api_key: str = ""
    ai_model: str = "claude-fable-5"

    # OCR
    ocr_provider: str = "tesseract"
    ocr_api_key: str = ""

    # DB
    database_url: str = "sqlite:///./bettertrack.db"

    # Obsidian
    obsidian_host: str = "127.0.0.1"
    obsidian_port: int = 3001
    obsidian_api_key: str = ""
    obsidian_vault_path: str = ""

    # Firebase / Google (from google-services.json)
    firebase_project_id: str = ""
    firebase_api_key: str = ""
    google_oauth_web_client_id: str = ""

    # Zapier Catch Hook for outbound notifications (optional)
    zapier_hook_url: str = ""

    secret_key: str = ""

    @property
    def cors_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def ai_ready(self) -> bool:
        if self.ai_provider == "gemini":
            return bool(self.gemini_api_key)
        return bool(self.anthropic_api_key)


@lru_cache
def get_settings() -> Settings:
    return Settings()
