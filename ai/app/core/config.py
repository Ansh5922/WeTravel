import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "WeTravel AI Engine"
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://neondb_owner:npg_PBI6khdoq1JR@ep-dark-grass-b35c57br-pooler.c-4.ap-southeast-1.aws.neon.tech/neondb?sslmode=require"
    )
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
