#!/usr/bin/env bash
# cast-lenses.sh — Proof Duel lens SKU caster (normative)
# Version: 1 — 2026-09-14
# Compatible with bash 3.2+ (macOS /bin/bash).
set -euo pipefail

usage() {
  echo "usage: cast-lenses.sh --catalog PATH --n N [--seed HEX8] [--deck full|core] [--exclude id,id] [--slots 1|2] [--axis-mode no-optimand|full] [--secondary-mode stakeholder|full] [--primary-unique 0|1]" >&2
  exit 2
}

CATALOG=""
N=""
SEED=""
DECK="full"
EXCLUDE=""
SLOTS=2
AXIS_MODE="no-optimand"
SECONDARY_MODE="stakeholder"
PRIMARY_UNIQUE=1
SHARED_DIAGNOSIS="on"

while [ $# -gt 0 ]; do
  case "$1" in
    --catalog) CATALOG="${2:?}"; shift 2 ;;
    --n) N="${2:?}"; shift 2 ;;
    --seed) SEED="${2:?}"; shift 2 ;;
    --deck) DECK="${2:?}"; shift 2 ;;
    --exclude) EXCLUDE="${2:?}"; shift 2 ;;
    --slots|--lens-slots) SLOTS="${2:?}"; shift 2 ;;
    --axis-mode|--primary-axis-mode) AXIS_MODE="${2:?}"; shift 2 ;;
    --secondary-mode) SECONDARY_MODE="${2:?}"; shift 2 ;;
    --primary-unique) PRIMARY_UNIQUE="${2:?}"; shift 2 ;;
    --shared-diagnosis) SHARED_DIAGNOSIS="${2:?}"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1" >&2; usage ;;
  esac
done

[ -n "$CATALOG" ] && [ -f "$CATALOG" ] || { echo "missing --catalog" >&2; exit 2; }
case "$N" in 1|2|3|4|5) ;; *) echo "N must be 1..5" >&2; exit 2 ;; esac
case "$SLOTS" in 1|2) ;; *) echo "slots must be 1 or 2" >&2; exit 2 ;; esac
case "$DECK" in full|core) ;; *) echo "deck must be full|core" >&2; exit 2 ;; esac
case "$AXIS_MODE" in no-optimand|full) ;; *) echo "bad axis-mode" >&2; exit 2 ;; esac
case "$SECONDARY_MODE" in stakeholder|full) ;; *) echo "bad secondary-mode" >&2; exit 2 ;; esac
[ "$SHARED_DIAGNOSIS" = "on" ] || { echo "shared_diagnosis=off rejected" >&2; exit 2; }

if [ -z "$SEED" ]; then
  SEED=$(openssl rand -hex 4)
fi
echo "$SEED" | grep -Eq '^[0-9a-f]{8}$' || { echo "SEED must be 8 lowercase hex chars" >&2; exit 2; }
SEED4=$(echo "$SEED" | cut -c1-4)

hmac_hex() {
  printf '%s' "$1" | openssl dgst -sha256 -hmac "$SEED" 2>/dev/null | awk '{print $NF}'
}

u32_be_mod() {
  hex="$1"
  mod="$2"
  bytes=$(echo "$hex" | cut -c1-8)
  # force base16
  num=$(printf '%d' "0x$bytes")
  echo $((num % mod))
}

parse_axis_ids() {
  axis="$1"
  awk -v axis="$axis" '
    index($0, "## Axis " axis " ") == 1 {grab=1; next}
    grab && /^## / {exit}
    grab && /^\| `/ {print}
  ' "$CATALOG" | sed -n 's/^\| `\([a-z0-9-]*\)` .*/\1/p'
}

CORE_IDS=$(awk '
  /^## Core deck/ {grab=1; next}
  grab && /^## / {exit}
  grab {print}
' "$CATALOG" | tr '`' '\n' | grep -E '^[a-z0-9-]+$' | sort -u)

CATALOG_VERSION=$(sed -n 's/^`catalog_version: \([0-9]*\)`$/\1/p' "$CATALOG" | head -1)
[ -n "$CATALOG_VERSION" ] || { echo "catalog_version missing" >&2; exit 2; }

axis2=$(parse_axis_ids 2)
axis3=$(parse_axis_ids 3)
axis4=$(parse_axis_ids 4)
axis5=$(parse_axis_ids 5)
axis6=$(parse_axis_ids 6)

in_core() {
  echo "$CORE_IDS" | grep -qx "$1"
}

is_excluded() {
  echo "$EXCLUDE" | tr ',' '\n' | sed '/^$/d' | grep -qx "$1"
}

PRIMARY_LEGAL=""
SECONDARY_LEGAL=""

add_primary() {
  id="$1"
  [ -z "$id" ] && return
  [ "$DECK" = "core" ] && ! in_core "$id" && return
  is_excluded "$id" && return
  case " $PRIMARY_LEGAL " in
    *" $id "*) ;;
    *) PRIMARY_LEGAL="$PRIMARY_LEGAL $id" ;;
  esac
}
add_secondary() {
  id="$1"
  [ -z "$id" ] && return
  [ "$DECK" = "core" ] && ! in_core "$id" && return
  is_excluded "$id" && return
  case " $SECONDARY_LEGAL " in
    *" $id "*) ;;
    *) SECONDARY_LEGAL="$SECONDARY_LEGAL $id" ;;
  esac
}

for id in $axis2 $axis4; do add_primary "$id"; done
if [ "$AXIS_MODE" = "full" ]; then
  for id in $axis3; do add_primary "$id"; done
fi
for id in $axis5; do add_secondary "$id"; done
if [ "$SECONDARY_MODE" = "full" ]; then
  for id in $axis6; do add_secondary "$id"; done
fi

PRIMARY_LEGAL=$(echo "$PRIMARY_LEGAL" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ')
SECONDARY_LEGAL=$(echo "$SECONDARY_LEGAL" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ')
PRIMARY_LEGAL=$(echo "$PRIMARY_LEGAL" | sed 's/[[:space:]]*$//')
SECONDARY_LEGAL=$(echo "$SECONDARY_LEGAL" | sed 's/[[:space:]]*$//')

plen=$(echo "$PRIMARY_LEGAL" | wc -w | tr -d ' ')
slen=$(echo "$SECONDARY_LEGAL" | wc -w | tr -d ' ')

[ "$plen" -gt 0 ] || { echo "PrimaryLegal empty — stop and ask" >&2; exit 3; }
if [ "$SLOTS" = "2" ] && [ "$slen" -eq 0 ]; then
  echo "SecondaryLegal empty with slots=2 — stop and ask" >&2
  exit 3
fi
if [ "$PRIMARY_UNIQUE" = "1" ] && [ "$plen" -lt "$N" ]; then
  echo "diversity: unique-impossible (|PrimaryLegal|=$plen < N=$N)" >&2
fi

banned_secondaries() {
  primary="$1"
  case "$primary" in
    adversary) echo "sec-reviewer threat-model" ;;
    security-abuse) [ "$AXIS_MODE" = "full" ] && echo "sec-reviewer threat-model" ;;
    ops-oncall) [ "$AXIS_MODE" = "full" ] && echo "oncall-sre" ;;
    ux-symptom) [ "$AXIS_MODE" = "full" ] && echo "end-user" ;;
    maintainability) [ "$AXIS_MODE" = "full" ] && echo "future-maintainer" ;;
  esac
}

PRIMARY_ORDER=$(
  for id in $PRIMARY_LEGAL; do
    echo "$(hmac_hex "primary|$id") $id"
  done | sort -k1,1 -k2,2 | awk '{print $2}'
)

COUNTER_secondary=0
COUNTER_primary_tail=0

draw_from_list() {
  pool_name="$1"
  shift
  # remaining args = words in pool — pass as single string in $2 for bash3
  pool="$1"
  set -- $pool
  len=$#
  [ "$len" -gt 0 ] || return 1
  if [ "$pool_name" = "secondary" ]; then
    i=$COUNTER_secondary
    COUNTER_secondary=$((i + 1))
  else
    i=$COUNTER_primary_tail
    COUNTER_primary_tail=$((i + 1))
  fi
  digest=$(hmac_hex "${pool_name}|${i}")
  idx=$(u32_be_mod "$digest" "$len")
  # 0-based idx → positional
  n=0
  for w in $pool; do
    if [ "$n" -eq "$idx" ]; then
      echo "$w"
      return 0
    fi
    n=$((n + 1))
  done
}

echo "SEED=$SEED"
echo "catalog_version=$CATALOG_VERSION"
echo "deck=$DECK"
echo "axis_mode=$AXIS_MODE"
echo "secondary_mode=$SECONDARY_MODE"
echo "slots=$SLOTS"
echo "exclude=${EXCLUDE:-none}"
echo "PrimaryLegal=$(echo "$PRIMARY_LEGAL" | tr ' ' ',')"
echo "SecondaryLegal=$(echo "$SECONDARY_LEGAL" | tr ' ' ',')"

PAIRS="A B C D E"
p=0
for label in $PAIRS; do
  [ "$p" -lt "$N" ] || break

  primary=""
  secondary=""

  if [ "$PRIMARY_UNIQUE" = "1" ]; then
    # take p-th from PRIMARY_ORDER
    n=0
    for id in $PRIMARY_ORDER; do
      if [ "$n" -eq "$p" ]; then
        primary="$id"
        break
      fi
      n=$((n + 1))
    done
  fi
  if [ -z "$primary" ]; then
    primary=$(draw_from_list primary_tail "$PRIMARY_LEGAL")
    if [ "$PRIMARY_UNIQUE" = "1" ]; then
      echo "diversity: primary-collision on $label" >&2
    fi
  fi

  if [ "$SLOTS" = "2" ]; then
    bans=$(banned_secondaries "$primary")
    cand=""
    for s in $SECONDARY_LEGAL; do
      skip=0
      for b in $bans; do
        [ "$s" = "$b" ] && skip=1 && break
      done
      [ "$skip" -eq 0 ] && cand="$cand $s"
    done
    cand=$(echo "$cand" | sed 's/^ *//')
    if [ -z "$cand" ]; then
      echo "degrade: slots-1-synonym-exhausted on $label" >&2
    else
      secondary=$(draw_from_list secondary "$cand")
    fi
  fi

  if [ -n "$secondary" ]; then
    echo "$label  pd-${SEED4}-${primary}+${secondary}"
  else
    echo "$label  pd-${SEED4}-${primary}"
  fi
  p=$((p + 1))
done
