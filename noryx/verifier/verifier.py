import base64
import json
from datetime import datetime, timezone
from pathlib import Path

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import serialization


ROOT = Path(__file__).resolve().parent.parent
PUBLIC_KEY_FILE = ROOT / "keys" / "public.pem"


def _decode(data):
    padding = "=" * (-len(data) % 4)
    return base64.urlsafe_b64decode(data + padding)


def _canonical(data):
    return json.dumps(
        data,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
    ).encode("utf-8")


def verify(token, expected_project=None):
    try:
        parts = token.strip().split(".")

        if len(parts) != 3 or parts[0] != "NLM1":
            return False, "Invalid Noryx license format.", None

        payload = json.loads(
            _decode(parts[1]).decode("utf-8")
        )

        signature = _decode(parts[2])

        public_key = serialization.load_pem_public_key(
            PUBLIC_KEY_FILE.read_bytes()
        )

        try:
            public_key.verify(
                signature,
                _canonical(payload),
            )
        except InvalidSignature:
            return False, "Invalid license signature.", None

        required = [
            "schema_version",
            "license_id",
            "owner",
            "project",
            "customer",
            "plan",
            "issued_at",
            "expires_at",
            "machine_limit",
            "features",
        ]

        for field in required:
            if field not in payload:
                return False, f"Missing field: {field}.", None

        if payload["schema_version"] != 1:
            return False, "Unsupported license schema.", None

        if payload["owner"] != "CONSOLE":
            return False, "Invalid license owner.", None

        if type(payload["machine_limit"]) is not int or payload["machine_limit"] <= 0:
            return False, "Invalid machine limit.", None
        if not isinstance(payload["features"], list) or not all(isinstance(v, str) and v.strip() for v in payload["features"]):
            return False, "Invalid features.", None
        for field in ("license_id", "project", "customer", "plan"):
            if not isinstance(payload[field], str) or not payload[field].strip():
                return False, f"Invalid {field}.", None
        issued = datetime.fromisoformat(payload["issued_at"])
        expires = datetime.fromisoformat(payload["expires_at"])
        if issued.tzinfo is None or expires.tzinfo is None or expires <= issued:
            return False, "Invalid license timestamps.", None

        if expected_project is not None:
            if payload["project"] != expected_project:
                return False, "License project mismatch.", None

        expires = datetime.fromisoformat(
            payload["expires_at"]
        )

        if expires.tzinfo is None:
            return False, "Invalid license timezone.", None

        if expires <= datetime.now(timezone.utc):
            return False, "License expired.", None

        return True, "License is valid.", payload

    except Exception as exc:
        return False, f"License verification failed: {exc}", None
