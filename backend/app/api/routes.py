"""All HTTP routes. In-memory sample data stands in for a DB until one is wired.
Schemas mirror app/lib/models so the Flutter client can switch from mock to live
with minimal change."""
from __future__ import annotations

import uuid
from datetime import datetime

from fastapi import APIRouter, File, HTTPException, UploadFile

from ..config import get_settings
from ..models.schemas import (
    ActivityItem,
    AiChatRequest,
    AiChatResponse,
    AuthResponse,
    Budget,
    Expense,
    ExpenseCreate,
    GoogleAuthRequest,
    Group,
    GroupCreate,
    GroupJoin,
    LoginRequest,
    OcrResult,
    SignupRequest,
    Summary,
)
from ..services import ai_service, auth_service, obsidian_sync, ocr_service

router = APIRouter()

# Unambiguous alphabet (no 0/O/1/I) for human-friendly join codes.
_CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"


def _new_code(n: int = 6) -> str:
    import secrets

    return "".join(secrets.choice(_CODE_ALPHABET) for _ in range(n))


# ── Sample in-memory stores ──
_GROUPS: list[Group] = [
    Group(id="g1", name="Goa Trip", member_count=5, outstanding=6200,
          last_activity="Dinner at Olive · 2h ago", code="GOA123"),
    Group(id="g2", name="Flat 402", member_count=3, outstanding=-1800,
          last_activity="Electricity bill · 1d ago", code="FLAT42"),
    Group(id="g3", name="Office Lunch", member_count=8, outstanding=0,
          last_activity="All settled up · 3d ago", code="LUNCH8"),
]
_EXPENSES: list[Expense] = [
    Expense(id="e1", name="Dinner at Olive", category="food", amount=2400,
            payer="Sam", date=datetime(2026, 6, 13), group_id="g1"),
    Expense(id="e2", name="Cab to airport", category="travel", amount=850,
            payer="You", date=datetime(2026, 6, 12), group_id="g1"),
]
_BUDGETS: list[Budget] = [
    Budget(name="Food", spent=8200, limit=10000),
    Budget(name="Travel", spent=14500, limit=12000),
    Budget(name="Entertainment", spent=2100, limit=5000),
    Budget(name="Shopping", spent=3400, limit=6000),
]
_ACTIVITY: list[ActivityItem] = [
    ActivityItem(type="expense", title="Dinner at Olive",
                 subtitle="Sam paid ₹2,400 · Goa Trip", time="2h"),
    ActivityItem(type="settlement", title="Settlement completed",
                 subtitle="Riya settled ₹1,200 with you", time="5h"),
    ActivityItem(type="budget_alert", title="Travel budget exceeded",
                 subtitle="₹14,500 of ₹12,000 used", time="1d"),
]


@router.get("/health")
def health() -> dict:
    s = get_settings()
    return {
        "status": "ok",
        "app": s.app_name,
        "ai_configured": s.ai_ready,
        "ocr_provider": s.ocr_provider,
        "obsidian_key_set": bool(s.obsidian_api_key),
    }


# ── Auth ──
@router.post("/auth/signup", response_model=AuthResponse)
def signup(payload: SignupRequest) -> AuthResponse:
    return auth_service.signup(payload.name, payload.email, payload.password)


@router.post("/auth/login", response_model=AuthResponse)
def login(payload: LoginRequest) -> AuthResponse:
    return auth_service.login(payload.email, payload.password)


@router.post("/auth/google", response_model=AuthResponse)
def google_auth(payload: GoogleAuthRequest) -> AuthResponse:
    return auth_service.google(payload.email, payload.name)


# ── Dashboard summary ──
@router.get("/summary", response_model=Summary)
def summary() -> Summary:
    owed = sum(g.outstanding for g in _GROUPS if g.outstanding > 0)
    owing = sum(-g.outstanding for g in _GROUPS if g.outstanding < 0)
    return Summary(owed=owed, owing=owing, net=owed - owing)


@router.get("/activity", response_model=list[ActivityItem])
def activity() -> list[ActivityItem]:
    return _ACTIVITY


# ── Groups ──
@router.get("/groups", response_model=list[Group])
def list_groups() -> list[Group]:
    return _GROUPS


def _unique_code() -> str:
    existing = {g.code for g in _GROUPS}
    code = _new_code()
    while code in existing:
        code = _new_code()
    return code


@router.post("/groups", response_model=Group)
def create_group(payload: GroupCreate) -> Group:
    members = [m.strip() for m in payload.members if m.strip()]
    group = Group(
        id=f"g{uuid.uuid4().hex[:6]}",
        name=payload.name.strip(),
        member_count=max(1, len(members)),
        currency=payload.currency or "₹",
        outstanding=0.0,
        last_activity="Group created · just now",
        code=_unique_code(),
    )
    _GROUPS.insert(0, group)
    _ACTIVITY.insert(
        0,
        ActivityItem(
            type="settlement",
            title=f"{group.name} created",
            subtitle=f"{group.member_count} member(s)",
            time="now",
        ),
    )
    obsidian_sync.write_note(
        f"Group created — {group.name}",
        f"- Members: {', '.join(members) or '—'}\n- Currency: {group.currency}\n"
        f"- Code: {group.code}",
        tags=["bettertrack", "group"],
    )
    return group


@router.get("/groups/{code}", response_model=Group)
def get_group_by_code(code: str) -> Group:
    code = code.strip().upper()
    for g in _GROUPS:
        if g.code == code:
            return g
    raise HTTPException(status_code=404, detail="No group found for that code.")


@router.post("/groups/join", response_model=Group)
def join_group(payload: GroupJoin) -> Group:
    code = payload.code.strip().upper()
    for g in _GROUPS:
        if g.code == code:
            g.member_count += 1
            g.last_activity = f"{payload.member_name} joined · just now"
            _ACTIVITY.insert(
                0,
                ActivityItem(
                    type="settlement",
                    title=f"{payload.member_name} joined {g.name}",
                    subtitle=f"Now {g.member_count} members",
                    time="now",
                ),
            )
            obsidian_sync.write_note(
                f"Member joined — {g.name}",
                f"- {payload.member_name} joined via code {code}",
                tags=["bettertrack", "group"],
            )
            return g
    raise HTTPException(
        status_code=404, detail="That group code doesn't exist. Check and try again."
    )


# ── Expenses ──
@router.get("/expenses", response_model=list[Expense])
def list_expenses(group_id: str | None = None) -> list[Expense]:
    if group_id:
        return [e for e in _EXPENSES if e.group_id == group_id]
    return _EXPENSES


@router.post("/expenses", response_model=Expense)
def create_expense(payload: ExpenseCreate) -> Expense:
    expense = Expense(
        id=f"e{uuid.uuid4().hex[:6]}",
        name=payload.name,
        category=payload.category,
        amount=payload.amount,
        payer=payload.payer,
        date=datetime.now(),
        group_id=payload.group_id,
    )
    _EXPENSES.append(expense)
    _ACTIVITY.insert(
        0,
        ActivityItem(
            type="expense",
            title=expense.name,
            subtitle=f"{expense.payer} paid ₹{expense.amount:,.0f} · {expense.category}",
            time="now",
        ),
    )
    obsidian_sync.write_note(
        f"Expense added — {expense.name}",
        f"- Amount: ₹{expense.amount}\n- Payer: {expense.payer}\n"
        f"- Category: {expense.category}\n- Group: {expense.group_id}",
        tags=["bettertrack", "expense"],
    )
    return expense


# ── Budgets ──
@router.get("/budgets", response_model=list[Budget])
def list_budgets() -> list[Budget]:
    return _BUDGETS


# ── AI assistant ──
@router.post("/ai/chat", response_model=AiChatResponse)
async def ai_chat(req: AiChatRequest) -> AiChatResponse:
    return await ai_service.chat(req)


# ── OCR ──
@router.post("/ocr/scan", response_model=OcrResult)
async def ocr_scan(file: UploadFile = File(...)) -> OcrResult:
    data = await file.read()
    return await ocr_service.scan(data)
