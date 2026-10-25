# API principale : indique quel conteneur a répondu (preuve du load balancing)
import socket
from datetime import datetime, timezone

from fastapi import FastAPI

app = FastAPI(title="api")

# Le hostname du conteneur est défini dans docker-compose (api1, api2, api3)
container_name = socket.gethostname()


@app.get("/")
def read_root():
    return {
        "container": container_name,
        "time": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/health")
def health():
    return {"status": "ok", "container": container_name}
