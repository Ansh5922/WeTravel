from fastapi import FastAPI, Depends
from app.api.deps import get_current_user
from app.api.routes.embedding import router as embedding_router

"""
WeTravel AI Engine — FastAPI entry point.
Architecture: Client → Routes → (Depends middleware) → Services → Repositories → DB
"""

app = FastAPI(
    title="WeTravel AI Engine",
    description="AI microservice for WeTravel. JWT tokens issued by Node.js are verified independently.",
    version="1.0.0",
)

# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(embedding_router)


# ── Health Check ──────────────────────────────────────────────────────────────
@app.get("/health")
def health_check():
    return {"status": "online", "service": "WeTravel AI Engine"}


# ── Protected Test Route ──────────────────────────────────────────────────────
@app.get("/api/ai/test-auth")
def test_auth(current_user: dict = Depends(get_current_user)):
    """
    Protected endpoint. Requires a valid JWT in Authorization: Bearer <token> header.
    The token must have been issued by the Node.js backend (POST /api/auth/login).
    FastAPI verifies the shared JWT_SECRET locally — no inter-server call needed.
    """
    return {
        "status": "success",
        "message": "JWT verified by FastAPI independently ✅",
        "authenticated_user_id": current_user["id"],
    }