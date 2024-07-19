usage="$(basename "$0") [-h] [-i filename] -- convert a gramps XML document into RDF

where:
    -h  show this help text
    -i  input document
    -b  base uri for resources"


CONFIG="$(pwd)/config"
if test -f "$CONFIG"; then
    #echo "Using $CONFIG config file."
else
    echo "file $CONFIG does not exist"
    echo "Please read $(pwd)/config.CHANGEME"
    exit
fi

source config

while getopts ':hbi:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    i) GRAMPS_XML=$OPTARG
       ;;
    i) BASE=$OPTARG
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

FILE=${GRAMPS_XML##*/}
OUT=out/${FILE%%.*}.ttl
if test -f "$OUT"; then
    echo "$OUT already exist."
    exit 1
fi

echo $OUT
java -jar $RML_JAR -m rml/gramps2rdf.ttl -m "<http://mapping.ex.com/myLogicalSource> <http://semweb.mmlab.be/ns/rml#source> \"$GRAMPS_XML\" ." -s "turtle" -o $OUT 
