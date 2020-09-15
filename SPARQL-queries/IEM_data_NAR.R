##Queries for data analysis on RDF data for IEM Pathways, NAR 2020 paper

## OMIM IDs on text labels

#Install rdf package; more info here: http://www.r-bloggers.com/sparql-with-r-in-less-than-5-minutes/
install.packages('SPARQL')

#Get library to perform SPARQL queries
library(SPARQL) # SPARQL querying package

##Perform query and save results
##Endpoint WPs
#endpoint <- "http://sparql.wikipathways.org/" ##OLD
endpointwp <- "http://sparql.wikipathways.org/sparql"


querywp <-
  "
SELECT count(distinct ?omim) as ?diseaseIDs
WHERE {
?pathway wp:ontologyTag cur:IEM ; 
         a wp:Pathway . 
?diseaseNode a gpml:Label;
             gpml:href ?omim .
}
"

qw <- SPARQL(endpointwp,querywp,curl_args=list(useragent=R.version.string))
wf <- qw$results

## Disease ontology IDs:
querydoid <-
"
SELECT count(DISTINCT ?DiseaseOnt) as ?DOIDs
WHERE {
  ?pathway wp:diseaseOntologyTag ?DiseaseOnt;
           wp:ontologyTag cur:IEM .
}
"

qdoid <- SPARQL(endpointwp,querydoid,curl_args=list(useragent=R.version.string))
wdoid <- qdoid$results
