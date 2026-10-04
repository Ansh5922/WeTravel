"""
DEPRECATED: Auth middleware has moved to app/middleware/auth.py
This file re-exports for backward compatibility only.
"""
from app.middleware.auth import get_current_user  # noqa: F401
