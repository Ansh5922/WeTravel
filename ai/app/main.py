import time
from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from app.middleware.auth import get_current_user
from app.api.routes.embedding import router as embedding_router
from app.api.routes.consensus import router as consensus_router
from app.api.routes.itinerary import router as itinerary_router
from app.api.routes.ocr import router as ocr_router
from app.services.embedding_service import load_embedding_model

# Warm up AI models during application lifespan startup
@asynccontextmanager
async def lifespan(app: FastAPI):
    print("[Lifespan] Starting up WeTravel AI Engine... Warming up embedding models...")
    load_embedding_model()
    yield
    print("[Lifespan] Shutting down WeTravel AI Engine...")

app = FastAPI(
    title="WeTravel AI Engine",
    description="AI microservice for WeTravel. JWT tokens issued by Node.js are verified independently.",
    version="2.0.0",
    lifespan=lifespan,
)

# Enable CORS for web, mobile, and dashboard clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# HTTP request logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = (time.time() - start_time) * 1000
    print(f"[AI-HTTP] {request.method} {request.url.path} -> {response.status_code} ({process_time:.2f}ms)")
    return response


# Routers
app.include_router(embedding_router)
app.include_router(consensus_router)
app.include_router(itinerary_router)
app.include_router(ocr_router)

# Health check
@app.get("/health")
def health_check():
    return {"status": "online", "service": "WeTravel AI Engine", "version": "2.0.0"}

# Protected test route for token verification
@app.get("/api/ai/test-auth")
def test_auth(current_user: dict = Depends(get_current_user)):
    return {
        "status": "success",
        "message": "JWT verified by FastAPI independently",
        "authenticated_user_id": current_user["id"],
    }