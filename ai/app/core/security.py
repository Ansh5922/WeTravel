from jose import JWTError, jwt
from app.core.config import settings

"""
Security utilities for the AI backend.
Architecture layer: Core security (called by API dependency layer)

Responsibility:
  - Decode and verify JWTs using the shared JWT_SECRET
  - The secret is IDENTICAL to the one used by Node.js to sign tokens
  - No database calls here — pure cryptographic verification
"""


def verify_token(token: str) -> dict:
    """
    Decode and verify a JWT signed by the Node.js backend.

    Args:
        token: Raw JWT string (without 'Bearer ' prefix)

    Returns:
        The decoded payload dict (contains 'sub' = user_id)

    Raises:
        JWTError: If the token is invalid, expired, or tampered with
    """
    payload = jwt.decode(
        token,
        settings.JWT_SECRET,
        algorithms=[settings.JWT_ALGORITHM],
    )
    return payload
