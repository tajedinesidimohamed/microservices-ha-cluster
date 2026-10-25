# Service de commandes fictif (données en mémoire, perdues au redémarrage)
import socket

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="orders")

container_name = socket.gethostname()

orders = {
    1: {"id": 1, "item": "clavier", "quantity": 1},
    2: {"id": 2, "item": "souris", "quantity": 2},
}


class OrderCreate(BaseModel):
    item: str
    quantity: int


@app.get("/health")
def health():
    return {"status": "ok", "container": container_name}


@app.get("/orders")
def list_orders():
    return {"orders": list(orders.values())}


@app.get("/orders/{order_id}")
def get_order(order_id: int):
    if order_id not in orders:
        raise HTTPException(status_code=404, detail="Commande introuvable")
    return orders[order_id]


@app.post("/orders", status_code=201)
def create_order(order: OrderCreate):
    order_id = max(orders, default=0) + 1
    orders[order_id] = {"id": order_id, **order.model_dump()}
    return orders[order_id]
