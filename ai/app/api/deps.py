# Re-export get_current_user from app/middleware/auth for backward compatibility
from app.middleware.auth import get_current_user  # noqa: F401
