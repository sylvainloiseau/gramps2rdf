#!/bin/bash
usage="$(basename "$0") [-h] [-f] [-b base] [-i filename] -- convert a gramps XML document into RDF

where:
    -h  show this help text
    -i  input document
    -f  force (erase existing output document)
    -b  base uri for resources (default: http://mycorpus.com/)"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MAPPING="$SCRIPT_DIR/rml/gramps2rdf.ttl"
# IRI base and source path written in the mapping, replaced at run time
MAPPING_BASE="http://mycorpus.com/"
MAPPING_SOURCE="sample/gramps.xml"

CONFIG="$SCRIPT_DIR/config"
if test -f "$CONFIG"; then
    echo "Using $CONFIG config file."
else
    echo "file $CONFIG does not exist" >&2
    echo "Please read $SCRIPT_DIR/config.CHANGEME" >&2
    exit 1
fi

source "$CONFIG"

BASE=${BASE:-$MAPPING_BASE}

while getopts ':hfb:i:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    i) GRAMPS_XML=$OPTARG
       ;;
    b) BASE=$OPTARG
       ;;
    f) FORCE="True"
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done

if [ -z "$RML_JAR" ] || ! test -f "$RML_JAR"; then
    echo "RML_JAR ('$RML_JAR') is not a file: check $CONFIG" >&2
    exit 1
fi
if [ -z "$GRAMPS_XML" ] || ! test -f "$GRAMPS_XML"; then
    echo "input document ('$GRAMPS_XML') is not a file: use -i or set GRAMPS_XML in $CONFIG" >&2
    echo "$usage" >&2
    exit 1
fi
GRAMPS_XML="$(cd "$(dirname "$GRAMPS_XML")" && pwd)/$(basename "$GRAMPS_XML")"

FILE=${GRAMPS_XML##*/}
OUT="$SCRIPT_DIR/out/${FILE%%.*}.ttl"
if test -f "$OUT"; then
    echo "$OUT already exist..."
    if [ -z "$FORCE" ]; then
      echo "    ...use -f to erase"
      exit 1
    else
      echo "    ... -f option provided: will be erased"
    fi
fi
mkdir -p "$SCRIPT_DIR/out"

# point the mapping to the input document and the base IRI
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
TMP_MAPPING="$TMP_DIR/gramps2rdf.ttl"
mapping=$(<"$MAPPING")
mapping=${mapping//\"$MAPPING_SOURCE\"/\"$GRAMPS_XML\"}
mapping=${mapping//$MAPPING_BASE/$BASE}
printf '%s\n' "$mapping" > "$TMP_MAPPING"

echo "$OUT"
java -jar "$RML_JAR" -m "$TMP_MAPPING" -s turtle -o "$OUT"
