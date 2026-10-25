# Service d'authentification fictif (données en mémoire, aucun vrai secret)
import socket
import uuid

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="auth")

container_name = socket.gethostname()

# Utilisateurs de démonstration
users = {"alice": "demo", "bob": "demo"}


class LoginRequest(BaseModel):
    username: str
    password: str


@app.get("/health")
def health():
    return {"status": "ok", "container": container_name}


@app.get("/auth/users")
def list_users():
    return {"users": list(users.keys())}


@app.post("/auth/login")
def login(request: LoginRequest):
    if users.get(request.username) != request.password:
        raise HTTPException(status_code=401, detail="Identifiants invalides")
    # Jeton fictif, uniquement pour la démonstration
    return {"token": str(uuid.uuid4()), "user": request.username}
