from jose import jwt
from app.core.config import settings


def verify_token(token: str) -> dict:
    # Decode and verify a JWT signed by Node.js backend using shared secret
    return jwt.decode(
        token,
        settings.JWT_SECRET,
        algorithms=[settings.JWT_ALGORITHM],
    )
