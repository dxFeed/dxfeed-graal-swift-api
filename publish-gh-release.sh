#!/usr/bin/env bash
#
# Publish a GitHub release and upload an arbitrary set of asset files.
# Designed to run both locally and from TeamCity.
#
# Usage:
#   ./publish-release.sh --name <release> [options] <file> [<file> ...]
#
# Required:
#   --name <str>          release name, also used as tag_name (e.g. 1.1.7)
#   <file> ...            asset files; DXFeedFramework.zip MUST be among them
#
# Credentials (later flags override earlier ones; $GH_TOKEN is the fallback):
#   -user <login:token>   JFrog/curl style pair, same shape as -user %env.JFROG_USER%:%env.JFROG_PASSWORD%
#                         only the token part is used for auth; the login part is
#                         verified against the authenticated account and must match
#   --token <str>         raw token; NOT recommended: visible in `ps` to any process on the agent
#   --token-file <path>   file containing the token on a single line
#
# Options:
#   --repo <owner/repo>   default: dxFeed/dxfeed-graal-swift-api
#   --required <name>     asset treated as critical (default: DXFeedFramework.zip)
#   --notes <str>         release description body
#   --draft               do not publish, leave the release as a draft
#   --prerelease          mark the release as a pre-release
#   --strict              fail if ANY asset fails to upload, not just the critical one
#   --teamcity            emit TeamCity service messages (checksums as build parameters)
#   --dry-run             checks and checksums only, no changes on GitHub
#
# Exit codes:
#   0  critical asset uploaded (and release published unless --draft)
#   1  failure: no access, critical asset not uploaded, or release not published
#   2  bad arguments
#
# NOTE ON TAGS: this script never creates or pushes git tags itself. However, a
# published (non-draft) release cannot exist on GitHub without a tag: if no tag
# with this name exists yet, GitHub creates one at the HEAD of the default branch
# when the draft flag is cleared. If the tag must point at a specific commit,
# create and push it BEFORE running this script, or run with --draft.
#
set -uo pipefail

API="https://api.github.com"
UPLOADS="https://uploads.github.com"
API_VERSION="2022-11-28"

REPO_SLUG="dxFeed/dxfeed-graal-swift-api"
RELEASE_NAME=""
NOTES=""
REQUIRED_ASSET="DXFeedFramework.zip"
TOKEN="${GH_TOKEN:-}"
EXPECTED_LOGIN=""
DRAFT=0
PRERELEASE=0
STRICT=0
TEAMCITY=0
DRY_RUN=0
FILES=()

die()  { echo "✗ $*" >&2; exit 1; }
usage(){ echo "✗ $*" >&2; echo "  hint: $0 --name 1.1.7 -user <login:token> DXFeedFramework.zip [documentation.zip tools.zip]" >&2; exit 2; }
ok()   { echo "✓ $*"; }
warn() { echo "! $*" >&2; }

tc() { (( TEAMCITY )) && echo "$*" || true; }
# TeamCity service messages require escaping of | ' [ ]
tc_escape() { printf '%s' "$1" | sed "s/|/||/g; s/'/|'/g; s/\[/|\[/g; s/\]/|\]/g"; }

# ---------- arguments ----------
while (( $# )); do
  case "$1" in
    --name)       [[ ${2:-} ]] || usage "--name requires a value"; RELEASE_NAME="$2"; shift 2 ;;
    --repo)       [[ ${2:-} ]] || usage "--repo requires a value"; REPO_SLUG="$2"; shift 2 ;;
    -user|--user) [[ ${2:-} ]] || usage "-user requires <login:token>"
                  # split on the FIRST colon only: a token may contain colons
                  [[ "$2" == *:* ]] || usage "-user expects <login:token>, got a value without a colon"
                  EXPECTED_LOGIN="${2%%:*}"
                  TOKEN="${2#*:}"
                  [[ -n "$TOKEN" ]] || usage "-user: empty token part"
                  shift 2 ;;
    --token)      [[ ${2:-} ]] || usage "--token requires a value"; TOKEN="$2"; shift 2 ;;
    --token-file) [[ ${2:-} ]] || usage "--token-file requires a value"
                  [[ -r "$2" ]] || usage "token file is not readable: $2"
                  TOKEN="$(tr -d '[:space:]' < "$2")"; shift 2 ;;
    --required)   [[ ${2:-} ]] || usage "--required requires a value"; REQUIRED_ASSET="$2"; shift 2 ;;
    --notes)      [[ ${2:-} ]] || usage "--notes requires a value"; NOTES="$2"; shift 2 ;;
    --draft)      DRAFT=1; shift ;;
    --prerelease) PRERELEASE=1; shift ;;
    --strict)     STRICT=1; shift ;;
    --teamcity)   TEAMCITY=1; shift ;;
    --dry-run)    DRY_RUN=1; shift ;;
    -h|--help)    sed -n '2,50p' "$0"; exit 0 ;;
    -*)           usage "unknown flag: $1" ;;
    *)            FILES+=("$1"); shift ;;
  esac
done

[[ -n "$RELEASE_NAME" ]] || usage "--name is not set"
(( ${#FILES[@]} )) || usage "no asset files given"
[[ -n "$TOKEN" ]] || usage "no credentials: use -user, --token, --token-file or GH_TOKEN"
command -v python3 >/dev/null || die "python3 is required (JSON parsing)"
command -v curl    >/dev/null || die "curl is required"

OWNER="${REPO_SLUG%%/*}"
REPO="${REPO_SLUG##*/}"
[[ -n "$OWNER" && -n "$REPO" && "$OWNER" != "$REPO_SLUG" ]] || usage "--repo must look like owner/repo"

# ---------- helpers ----------
api() { # api <method> <url> [body]
  local method="$1" url="$2" body="${3:-}"
  local args=(-sS -X "$method"
    -H "Authorization: Bearer $TOKEN"
    -H "Accept: application/vnd.github+json"
    -H "X-GitHub-Api-Version: $API_VERSION")
  [[ -n "$body" ]] && args+=(-d "$body")
  curl "${args[@]}" "$url"
}

# Read a top-level string/number field from a JSON object on stdin.
jget() { python3 -c "import sys,json
try: d=json.load(sys.stdin)
except Exception: d={}
print(d.get('$1','') if isinstance(d,dict) else '')"; }

# macOS ships shasum, most Linux images ship sha256sum
sha256_of() {
  if command -v shasum >/dev/null; then shasum -a 256 "$1" | awk '{print $1}'
  elif command -v sha256sum >/dev/null; then sha256sum "$1" | awk '{print $1}'
  else die "neither shasum nor sha256sum is available"; fi
}

# portable across macOS and Linux, unlike stat(1)
size_of() { wc -c < "$1" | tr -d ' '; }

content_type_of() {
  case "${1##*.}" in
    zip) echo "application/zip" ;;
    json) echo "application/json" ;;
    txt|md) echo "text/plain" ;;
    *) echo "application/octet-stream" ;;
  esac
}

# ---------- validate assets ----------
declare -a NAMES=()
FOUND_REQUIRED=0
MAX_ASSET=$((2 * 1024 * 1024 * 1024))   # GitHub rejects release assets over 2 GB

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || die "file not found: $f"
  name="$(basename "$f")"
  for existing in "${NAMES[@]:-}"; do
    [[ "$existing" == "$name" ]] && die "two files map to the same asset name: $name"
  done
  sz=$(size_of "$f")
  (( sz > 0 )) || die "file is empty: $f"
  (( sz < MAX_ASSET )) || die "asset is larger than 2 GB, GitHub will reject it: $f"
  NAMES+=("$name")
  [[ "$name" == "$REQUIRED_ASSET" ]] && FOUND_REQUIRED=1
  printf '  %-28s %6s MB  sha256=%s\n' "$name" "$(( sz / 1024 / 1024 ))" "$(sha256_of "$f")"
done

(( FOUND_REQUIRED )) || die "required asset is missing from the argument list: $REQUIRED_ASSET"
ok "assets to upload: ${#FILES[@]} (required $REQUIRED_ASSET present)"

# ---------- verify access ----------
# For a PUBLIC repo, GET /repos returns 200 even for a token with no rights at all,
# so check permissions.push instead of the HTTP status code.
LOGIN=$(api GET "$API/user" | jget login)
[[ -n "$LOGIN" ]] || die "token does not authenticate — invalid, revoked or truncated"
ok "authenticated as $LOGIN"

if [[ -n "$EXPECTED_LOGIN" && "$EXPECTED_LOGIN" != "$LOGIN" ]]; then
  die "-user login mismatch: passed '$EXPECTED_LOGIN', token belongs to '$LOGIN'"
fi

PUSH=$(api GET "$API/repos/$OWNER/$REPO" \
  | python3 -c 'import sys,json
try: d=json.load(sys.stdin)
except Exception: d={}
print(d.get("permissions",{}).get("push"))')
if [[ "$PUSH" != "True" ]]; then
  cat >&2 <<EOF
✗ no write access to $OWNER/$REPO (permissions.push = $PUSH)

  Most common causes:
   1. fine-grained PAT whose Resource owner is a personal account — it does not apply
      to an organization repository (needs Resource owner = $OWNER plus org approval);
   2. classic PAT without the 'repo' scope;
   3. account $LOGIN has no push rights on the repository;
   4. deploy key — deploy keys have no access to the REST API at all.
EOF
  exit 1
fi
ok "write access to $OWNER/$REPO confirmed"

if (( DRY_RUN )); then
  echo
  ok "dry-run: nothing was changed on GitHub"
  for n in "${NAMES[@]}"; do
    echo "  https://github.com/$OWNER/$REPO/releases/download/$RELEASE_NAME/$n"
  done
  exit 0
fi

# ---------- create or reuse the release ----------
# NOTE: GET /releases/tags/<tag> does NOT return drafts, so scan the list instead.
RELEASE_ID=$(api GET "$API/repos/$OWNER/$REPO/releases?per_page=100" \
  | python3 -c "import sys,json
try: d=json.load(sys.stdin)
except Exception: d=[]
d = d if isinstance(d,list) else []
print(next((str(r['id']) for r in d if r.get('tag_name')=='$RELEASE_NAME'), ''))")

if [[ -n "$RELEASE_ID" ]]; then
  ok "release '$RELEASE_NAME' already exists (id=$RELEASE_ID), reusing it"
else
  BODY=$(python3 - "$RELEASE_NAME" "$NOTES" "$PRERELEASE" <<'PY'
import json, sys
name, notes, pre = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
print(json.dumps({
    "tag_name": name,
    "name": name,
    "body": notes or f"{name}",
    "draft": True,           # published only after all assets are uploaded
    "prerelease": pre,
}))
PY
)
  RESP=$(api POST "$API/repos/$OWNER/$REPO/releases" "$BODY")
  RELEASE_ID=$(printf '%s' "$RESP" | jget id)
  [[ -n "$RELEASE_ID" ]] || die "failed to create the release: $RESP"
  ok "draft release '$RELEASE_NAME' created (id=$RELEASE_ID)"
fi

# ---------- upload assets ----------
# GitHub does not overwrite an asset with an existing name, it must be deleted first.
delete_existing_asset() {
  local name="$1" old
  old=$(api GET "$API/repos/$OWNER/$REPO/releases/$RELEASE_ID/assets?per_page=100" \
    | python3 -c "import sys,json
try: d=json.load(sys.stdin)
except Exception: d=[]
d = d if isinstance(d,list) else []
print(next((str(a['id']) for a in d if a.get('name')=='$name'), ''))")
  if [[ -n "$old" ]]; then
    api DELETE "$API/repos/$OWNER/$REPO/releases/assets/$old" >/dev/null
    warn "asset $name was already present — deleted before re-upload (id=$old)"
  fi
}

upload_asset() { # upload_asset <path> ; returns 0 on success
  local path="$1" name ctype resp state
  name="$(basename "$path")"
  ctype="$(content_type_of "$name")"

  local attempt
  for attempt in 1 2 3; do
    delete_existing_asset "$name"
    echo "→ uploading $name (attempt $attempt/3) ..."
    resp=$(curl -sS -X POST \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: $ctype" \
      -H "X-GitHub-Api-Version: $API_VERSION" \
      --max-time 1800 \
      --data-binary @"$path" \
      "$UPLOADS/repos/$OWNER/$REPO/releases/$RELEASE_ID/assets?name=$name" 2>&1)
    state=$(printf '%s' "$resp" | jget state)
    if [[ "$state" == "uploaded" ]]; then
      ok "$name uploaded"
      return 0
    fi
    warn "upload of $name failed: $(printf '%s' "$resp" | head -c 400)"
    (( attempt < 3 )) && sleep $(( attempt * 5 ))
  done
  return 1
}

REQUIRED_OK=0
FAILED=()
for f in "${FILES[@]}"; do
  name="$(basename "$f")"
  if upload_asset "$f"; then
    [[ "$name" == "$REQUIRED_ASSET" ]] && REQUIRED_OK=1
    tc "##teamcity[setParameter name='dxfeed.sha256.$(tc_escape "$name")' value='$(sha256_of "$f")']"
  else
    FAILED+=("$name")
  fi
done

# The critical asset gates everything: without it the release stays a draft and the
# build step fails, so downstream TeamCity steps do not run.
if (( ! REQUIRED_OK )); then
  tc "##teamcity[buildProblem description='$(tc_escape "required asset $REQUIRED_ASSET was not uploaded")']"
  die "required asset $REQUIRED_ASSET was not uploaded — release left as a draft, publishing cancelled"
fi

if (( ${#FAILED[@]} )); then
  warn "failed to upload: ${FAILED[*]}"
  if (( STRICT )); then
    tc "##teamcity[buildProblem description='$(tc_escape "assets failed to upload: ${FAILED[*]}")']"
    die "--strict: some assets failed to upload, release left as a draft"
  fi
  tc "##teamcity[message text='$(tc_escape "optional assets failed to upload: ${FAILED[*]}")' status='WARNING']"
fi

# ---------- publish ----------
if (( DRAFT )); then
  ok "release left as a draft (--draft), no tag created"
  echo "  publish with: curl -sS -X PATCH -H \"Authorization: Bearer \$GH_TOKEN\" $API/repos/$OWNER/$REPO/releases/$RELEASE_ID -d '{\"draft\":false}'"
else
  RESP=$(api PATCH "$API/repos/$OWNER/$REPO/releases/$RELEASE_ID" '{"draft":false}')
  IS_DRAFT=$(printf '%s' "$RESP" | jget draft)
  [[ "$IS_DRAFT" == "False" ]] || die "failed to publish the release: $(printf '%s' "$RESP" | head -c 400)"
  ok "release published"
  echo "  https://github.com/$OWNER/$REPO/releases/tag/$RELEASE_NAME"
fi

tc "##teamcity[setParameter name='dxfeed.release.id' value='$RELEASE_ID']"
tc "##teamcity[buildStatus text='release $RELEASE_NAME: ${#FILES[@]} assets, ${#FAILED[@]} failed']"

echo
echo "--- asset URLs ---"
for n in "${NAMES[@]}"; do
  echo "https://github.com/$OWNER/$REPO/releases/download/$RELEASE_NAME/$n"
done
