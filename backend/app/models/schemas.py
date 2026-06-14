"""Pydantic request/response schemas. Mirror the Flutter models in app/lib."""
from datetime import datetime

from pydantic import BaseModel, Field


class Group(BaseModel):
    id: str
    name: str
    member_count: int
    currency: str = "₹"
    outstanding: float = 0.0
    last_activity: str = ""
    code: str = ""  # short shareable join code


class GroupCreate(BaseModel):
    name: str = Field(min_length=1)
    members: list[str] = []
    currency: str = "₹"


class GroupJoin(BaseModel):
    code: str = Field(min_length=1)
    member_name: str = "You"


class Expense(BaseModel):
    id: str
    name: str
    category: str
    amount: float
    payer: str
    date: datetime
    settled: bool = False
    group_id: str | None = None


class ExpenseCreate(BaseModel):
    name: str
    category: str
    amount: float = Field(gt=0)
    payer: str
    group_id: str | None = None


class Budget(BaseModel):
    name: str
    spent: float
    limit: float
    group_id: str | None = None


class SignupRequest(BaseModel):
    name: str = Field(min_length=1)
    email: str = Field(min_length=3)
    password: str = Field(min_length=6)


class LoginRequest(BaseModel):
    email: str
    password: str


class GoogleAuthRequest(BaseModel):
    email: str
    name: str = ""


class AuthResponse(BaseModel):
    token: str
    name: str
    email: str


class Summary(BaseModel):
    owed: float
    owing: float
    net: float


class ActivityItem(BaseModel):
    type: str  # expense | settlement | budget_alert
    title: str
    subtitle: str
    time: str


class AiChatRequest(BaseModel):
    message: str
    group_id: str | None = None


class AiChatResponse(BaseModel):
    reply: str
    draft_expense: ExpenseCreate | None = None
    used_ai: bool = False


class OcrResult(BaseModel):
    merchant: str | None = None
    total: float | None = None
    category: str | None = None
    items: list[str] = []
    raw_text: str = ""
    used_ocr: bool = False
