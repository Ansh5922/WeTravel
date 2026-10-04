import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """
    Application configuration loaded from environment variables / .env file.
    Architecture layer: Core config (shared across all layers)
    """
    PROJECT_NAME: str = "WeTravel AI Engine"
    DATABASE_URL: str = os.getenv("DATABASE_URL", "")
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")

    # ── Shared JWT config (must match Node.js backend exactly) ────────────────
    JWT_SECRET: str = os.getenv("JWT_SECRET", "")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")

    class Config:
        env_file = ".env"
        extra = "ignore"


# Singleton instance — import this everywhere
settings = Settings()

