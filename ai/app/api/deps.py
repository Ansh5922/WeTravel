from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError
from app.core.security import verify_token

"""
FastAPI Dependency Injection for authentication.
Architecture layer: API deps (wired into route handlers via Depends())

Responsibility:
  - Extract Bearer token from Authorization header (handled by HTTPBearer)
  - Call verify_token from core/security.py
  - Return the authenticated user identity dict to the route handler
  - Raise HTTP 401 if anything is wrong

Usage in any route:
    @router.get("/protected-endpoint")
    def my_route(current_user: dict = Depends(get_current_user)):
        user_id = current_user["id"]
"""

# HTTPBearer automatically reads the Authorization: Bearer <token> header
bearer_scheme = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> dict:
    """
    FastAPI dependency that validates the JWT and returns the user identity.

    Returns:
        dict with 'id' (user_id as string) and 'sub' (same value, JWT standard)
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials. Please log in again.",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = verify_token(credentials.credentials)
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    # Return minimal identity — routes/services fetch full profile as needed
    return {"id": user_id, "sub": user_id}
