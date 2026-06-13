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

    secret_key: str = ""

    @property
    def cors_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def ai_ready(self) -> bool:
        return bool(self.anthropic_api_key)


@lru_cache
def get_settings() -> Settings:
    return Settings()
