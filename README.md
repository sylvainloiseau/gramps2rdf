Converting gramps data into RDF

# Installation

```
# Download the latest rmlmapper jar: https://github.com/RMLio/rmlmapper-java/releases
wget https://github.com/RMLio/rmlmapper-java/releases/download/v7.0.0/rmlmapper-7.0.0-r374-all.jar

# clone this repository
git clone <>

# rename the config file and edit it
cp config.CHANGEME config
vim config # point to rmlmapper-7.0.0-r374-all.jar
```

# Usage

```
bash gramps3rdf.sh -i yourgrampsdocument.xml
```

# Vocabularies used for the representation of gramps data

The conversion of gramps data borrows the following classes and properties from the following vocabularies:

- *Record in context* (https://www.ica.org/resource/records-in-contexts-ontology/)
- *Friend of a friend ontology* (http://xmlns.com/foaf/spec/)
  - ```@prefix foaf: <http://xmlns.com/foaf/0.1/> .```
  - class: ```foaf:Person```
  - property: ```foaf:gender```
- *BIO: A vocabulary for biographical information* (https://vocab.org/bio/)
- *Person Name Vocabulary* (https://www.lodewijkpetram.nl/vocab/pnv/doc/)
- *Bibliographic Ontology* (https://dcmi.github.io/bibo/)
- *DCMI Metadata Terms* (https://www.dublincore.org/specifications/dublin-core/dcmi-terms/)
- *Record in context* (https://www.ica.org/standards/RiC/RiC-O_1-0-1.html)
- *GeoNames Ontology* (http://www.geonames.org/ontology/documentation.html)
- *SKOS Simple Knowledge Organization System Namespace Document* (http://www.w3.org/2004/02/skos/core#)
- *CiTO, the Citation Typing Ontology* (https://sparontologies.github.io/cito/current/cito.html)
- *WGS84 Geo Positioning* (https://www.w3.org/2003/01/geo/)

- *Location Ontology (ArCo network)* (http://dati.beniculturali.it/lode/extract?url=https://raw.githubusercontent.com/ICCD-MiBACT/ArCo/master/ArCo-release/ontologie/location/location.owl)
- *Time Ontology in OWL* (https://www.w3.org/TR/owl-time/)
  - or sem below, Simple Event Model Ontology (https://semanticweb.cs.vu.nl/2009/11/sem/)

For the Family, no convenient type has been found in the vocabularies above. 
A namespace <http://www.gramps-project.com/ns> has been used for the type
`Family` and the relation `fatherInFamily`, `motherInFamily` and `offspringInFamily`

## Prefixes and URI

```
@prefix schema: <http://xmlns.com/foaf/0.1/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix pnv: <https://w3id.org/pnv#> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix bibo: <http://purl.org/ontology/bibo/> .
@prefix bio: <http://purl.org/vocab/bio/0.1/> .
@prefix gn: <https://www.geonames.org/ontology#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix cito: <http://purl.org/spar/cito> .
@prefix wgs: <https://www.w3.org/2003/01/geo/> .
@prefix ric: <https://www.w3.org/2003/01/geo/> .
@prefix grp: <http://www.gramps-project.com/ns> .
```

## Correspondance between gramps xml vocabulary and RDF vocabulary

BN = blank node

TODO : citation et place ont encore beaucoup de lfd:

| Gramps XML                  | RDF                                 |
| --------------------------- | ----------------------------------- |
| tags                        | -[a]-> skos:conceptScheme,          |
|                             |    skos:prefLabel="tags"            |
| tag                         | -[a]-> skos:Concept,                |
|                             |   -[skos:inScheme]->tags            |
|                             |   -[skos:prefLabel]-> "./name"      |
| foreach distinct(person/attribute/@type)                          |
|                             |-[a]-> skos:conceptScheme,           |
|                             | skos:prefLabel="@type"              |
[   for each distinct(person/attribute/@value)|-[a]-> skos:concept, |
|                             |skos:inScheme="@type"                |
|                             |skos:prefLabel="@value"              |
| person                      | -[a]-> foaf:Person                  |
|                             |   IRI : .../Person/@id              |
| person/gender               | -[foaf:gender]->                    |
| person/name                 | -[pnv:hasName]-> ; see below Case 1 |
| person/object               | TODO                                |
| person/childof              | -[grp:offspringInFamily]->          |
| person/parentin             | -[grp:parentInFamily]->             |
| person/noteref              | -[skos:note]->                      |
| person/citationref          | -[dcterms:references]->             |
| person/tagref               | -[dcterms:references]->             |
| person/eventref             | <-[bio:agent]-                      |
| person/attribute            | -[a]->AttributeReference            |
|                             |   -[dcterms:references]-> to the    |
|                             |     sko:concept (see above attribute)|
| person/attribute/citationref|    -[dcterms:references]->          |
| family                      | -[a]-> grp:Family                   |
| family/father               | -[grp:motherInFamily]->             |
| family/mother               | -[grp:fatherInFamily]->             |
| family/childref             |  -[grp:offspringInFamily]->            |
| family/citationref          | dcterms:references                  |
| citation                    | -[a]-> cito:Citation                |
| citation/confidence         | roar ou prov?                       |
| citation/page               | bibo:pages                          |
| citation/sourceref          | -[dcterms:isReferencedBy]-> ? cf abo.|
| source                      | bibo:Document                       |
| source/stitle               | dcterms:title                        |
| source/objectref            | -[dcterms:references]               |
| object[file/mime="image/jpeg"]| -[a]-> bibo:Image                 |
| object/file/@src            |      -[bibo:locator]->              |
| object/file/@checksum       |      -[grp:checksum]->              |
| object/file/@description    |      -[bibo:shortDescription]->     |
| object[not(file/mime="image/jpeg")]| -[a]-> bibo:Document         |
| object/file/@src            |      -[bibo:locator]->              |
| object/file/@checksum       |      -[grp:checksum]->              |
| object/file/@description    |      -[bibo:shortDescription]->     |
| object/file/@mime           |      -[grp:mime]->                  |
| event                       | -[a]-> bio:Event                    |
| event/type                  |   -[dcterms:type]->                 | pas sur une ref. et utiliser skos:concept
| event/date                  |   -[bio:date]->                     |
| event/place                 |   -[bio:place]->                    |
| event/description           |   -[dcterms:description]->          | ? pas sur une ref biblio
| event/citationref           |   -[dcterms:references]->           |
| place/@id                   | -[a]->  gn:Feature                  |
| ?                           | -[rdf:about]-> https://sws.geonames.org/[id]
| place/@type                 | -[gn:featureClass] -> gn:PPL, etc.  |
| place/coord/@long           | -[wgs:long]->                       |
| place/coord/@lat            | -[wgs:lat]->                        |
| place/ptitle                | -[gn:name]->                        |
| place/pname/@value          | -[gn:alternateName]->               |
| place/pname/@lang           | ^lang                               |
| place/placeref              | -[gn:parentFeature]->               |
| place/objref                |                                     |
| place/noteref               | -[skos:note]->                      |
|
|placeobj/citationref         dcterm:references
|
| note                        | -[a]->bibo:Note 
### Case 1: rendering of person name

The ```pnv:hasName``` property link a ```foaf:Person``` to one or several ```pnv:PersonName```.

The following gramps XML fragment:

```
    <person handle="_cf24a93e8e11269f423" change="1590755154" id="I0035">
      <gender>M</gender>
      <name type="Birth Name">
        <first>Waro</first>
        <call>Eisak</call>
        <surname>Natiame</surname>
      </name>
      <name alt="1" type="Traditional name">
        <first>Eisak</first>
        <surname></surname>
      </name>
      <name alt="1" type="Traditional name">
        <first>Feiawe</first>
        <surname></surname>
        <citationref hlink="_e77c3f26ec35af9d75489634e52"/>
      </name>
```

is represented as:
<https://www.wikidata.org/prop/direct/P2562>

```
      <http://example.com/I0035> a  foaf:Person ;
         rdfs:label      "" ;
         skos:prefLabel: "" ;
         pnv:hasName [ a pnv:PersonName ;
            rdfs:label            "Waro Natiame" ;
            pnv:givenName         "Waro" ;
            pnv:surname            "Natiame" ;
            pnv:literalName       "Waro Natiame" ;
            pnv:nameSpecification "Birth Name" ] ,
          [ a pnv:PersonName ;
            rdfs:label            "Eisak" ;
            pnv:givenName         "Eisak" ;
            pnv:literalName       "Eisak";
            pnv:nameSpecification "Traditional Name" ] ,
          [ a pnv:PersonName ;
            rdfs:label            "Feiawe" ;
            pnv:givenName         "Feiawe" ;
            pnv:literalName       "Feiawe" ;
            pnv:nameSpecification "Traditional Name" ] .
```

## Exemple 2: biographic event

Biographic events :
- bio:Event and its subtype (birth, death, etc.)
    - bio:place
    - bio:date
      "The date should be formatted as specified in ISO8601. For example: 2003-03-15 corresponds to the 15th March 2003, and 2003-03-15T13:21-05:00 corresponds to 15th March 2003, 8:21 am, US Eastern Standard Time."
- foaf:Person; properties:
    - bio:father
    - bio:mother
    - bio:child
    - bio:event

from https://leonvanwissen.nl/vocab/roar/docs/

```
@prefix roar: <https://w3id.org/roar#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix pnv: <https://w3id.org/pnv#> .
@prefix bio: <http://purl.org/vocab/bio/0.1/> .
@prefix sem: <http://semanticweb.cs.vu.nl/2009/11/sem/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix wo2slachtoffer: <https://www.genealogieonline.nl/wo2slachtoffers/> .
@prefix prov: <http://www.w3.org/ns/prov#> .

<go:595_I000342> 
a roar:PersonReconstruction ;
rdfs:label "Willem Hermanus Brizee" ;
pnv:hasName [
    a pnv:PersonName ;
    pnv:givenName "Willem Hermanus" ;
    pnv:surname "Brizee" ;
    pnv:literalName "Willem Hermanus Brizee"
] ;
bio:birth [
    a bio:Birth ;
    bio:principal <go:595_I000342> ;
    bio:place <http://sws.geonames.org/2747373/> ;
    sem:hasTimeStamp "1914-06-14"^^xsd:date
] ;
bio:death [
    a bio:Death ;
    bio:principal <go:595_I000342> ;
    sem:hasTimeStamp "1945-05-03"^^xsd:date ;
    bio:place <https://data.niod.nl/WO2_Thesaurus/kampen/3697>
] ;
```

## Exemple 3: Citation

?
The ```Note``` entity represent gramps note.
  - Note - https://dcmi.github.io/bibo/#:Note
No. Other solution.
