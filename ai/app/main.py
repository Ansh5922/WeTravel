from fastapi import FastAPI

app = FastAPI(title="WeTravel AI Engine")

@app.get("/")
def read_root():
    return {"status": "online", "service": "WeTravel AI Engine"}