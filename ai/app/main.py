import time
from fastapi import FastAPI, Depends, Request
from app.middleware.auth import get_current_user
from app.api.routes.embedding import router as embedding_router
from app.api.routes.consensus import router as consensus_router
from app.api.routes.itinerary import router as itinerary_router
from app.api.routes.ocr      import router as ocr_router

"""
WeTravel AI Engine — FastAPI entry point.
Architecture: Client → Routes → Middleware → Controllers → Services → Repositories → DB
"""

app = FastAPI(
    title="WeTravel AI Engine",
    description="AI microservice for WeTravel. JWT tokens issued by Node.js are verified independently.",
    version="2.0.0",
)


# ── Live HTTP Request Logger Middleware ───────────────────────────────────────
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = (time.time() - start_time) * 1000
    print(f"🤖 [AI-HTTP] {request.method} {request.url.path} → {response.status_code} ({process_time:.2f}ms)")
    return response


# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(embedding_router)
app.include_router(consensus_router)
app.include_router(itinerary_router)
app.include_router(ocr_router)



# ── Health Check ──────────────────────────────────────────────────────────────
@app.get("/health")
def health_check():
    return {"status": "online", "service": "WeTravel AI Engine", "version": "2.0.0"}


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