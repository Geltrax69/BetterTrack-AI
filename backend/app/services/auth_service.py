"""Minimal email/password auth with an in-memory user store.

Demo-grade (salted SHA-256, opaque tokens) — enough for the app to have a real
sign-up / sign-in flow. Swap the store for a DB and tokens for JWTs in prod.
"""
from __future__ import annotations

import hashlib
import secrets

from fastapi import HTTPException

from ..models.schemas import AuthResponse

# email -> {"name", "salt", "hash"}; token -> email
_USERS: dict[str, dict] = {}
_TOKENS: dict[str, str] = {}


def _hash(password: str, salt: str) -> str:
    return hashlib.sha256((salt + password).encode()).hexdigest()


def _issue(email: str, name: str) -> AuthResponse:
    token = secrets.token_urlsafe(24)
    _TOKENS[token] = email
    return AuthResponse(token=token, name=name, email=email)


def signup(name: str, email: str, password: str) -> AuthResponse:
    email = email.strip().lower()
    if email in _USERS:
        raise HTTPException(status_code=409, detail="That email already has an account.")
    salt = secrets.token_hex(8)
    _USERS[email] = {"name": name.strip(), "salt": salt, "hash": _hash(password, salt)}
    return _issue(email, name.strip())


def login(email: str, password: str) -> AuthResponse:
    email = email.strip().lower()
    user = _USERS.get(email)
    if not user or user["hash"] != _hash(password, user["salt"]):
        raise HTTPException(status_code=401, detail="Wrong email or password.")
    return _issue(email, user["name"])


def google(email: str, name: str) -> AuthResponse:
    """Demo Google sign-in: trusts the provided identity and creates/links a
    user. Real OAuth would verify a Google ID token against the web client id."""
    email = email.strip().lower()
    if email not in _USERS:
        _USERS[email] = {"name": name or email.split("@")[0], "salt": "", "hash": ""}
    return _issue(email, _USERS[email]["name"])
