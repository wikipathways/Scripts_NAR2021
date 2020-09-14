The SPARQL queries stored in [NumPathways.rq](https://github.com/wikipathways/Scripts_NAR2021/blob/master/SPARQL-queries/NumPathways.rq), [NumGenes.rq](https://github.com/wikipathways/Scripts_NAR2021/blob/master/SPARQL-queries/NumGenes.rq), [NumMetabolites.rq](https://github.com/wikipathways/Scripts_NAR2021/blob/master/SPARQL-queries/NumMetabolites.rq), and [NumPublications.rq](https://github.com/wikipathways/Scripts_NAR2021/blob/master/SPARQL-queries/NumPublications.rq) can be used to extract the number of Human pathways, and the number of (unique) genes and proteins, metabolites and publications in Human pathways of WikiPathways, excluding Reactome pathways. These SPARQL queries can be entered in the [WikiPathways SNORQL UI](http://sparql.wikipathways.org) on the most recent data released. For using the SPARQL queries on older data releases (found on [data.wikipathways.org](http://data.wikipathways.org)), local SPARQL endpoints can be deployed and loaded with RDF data using instructions below to set up local SPARQL endpoints using Docker. 

## Setting up a local SPARQL endpoint

Every month there is a new data release by WikiPathways, all of which are stored in [data.wikipathways.org](http://data.wikipathways.org/). The protocol for getting RDF data in a local Virtuoso SPARQL endpoint will be described step by step.

The requirements for updating the WikiPathwys SPARQL endpoint with this protocol (tested in Linux):
- Ability to use [Docker](https://docs.docker.com/get-docker/) on your system
- Ability to download files with `wget` command
- Ability to enter localhost URLs

## Step 1 - Download the data and prepare for loading
Make a folder named to store all RDF files to load in a SPARQL endpoint.  Go to [data.wikipathways.org](http://data.wikipathways.org/) and note the `Filename` (left column) of the data release that you want to use SPARQL queries on.
Next, enter the command-line, enter the created folder and execute the following commands to download the RDF files, and replace "[release]" with the `Filename` you noted. For example, the data released on September 10, 2020 has `Filename`: 20200910. Note that the "[release]" is there 2 times in the first 4 commands.

```
wget http://data.wikipathways.org/[release]/rdf/wikipathways-[release]-rdf-gpml.zip
wget http://data.wikipathways.org/[release]/rdf/wikipathways-[release]-rdf-wp.zip
wget http://data.wikipathways.org/[release]/rdf/wikipathways-[release]-rdf-authors.zip
wget http://data.wikipathways.org/[release]/rdf/wikipathways-[release]-rdf-void.ttl
wget -O wpvocab.ttl https://www.w3.org/2012/pyRdfa/extract?uri=http://vocabularies.wikipathways.org/wp#
wget -O gpmlvocab.ttl https://www.w3.org/2012/pyRdfa/extract?uri=http://vocabularies.wikipathways.org/gpml#
wget https://raw.githubusercontent.com/marvinm2/WikiPathwaysLoader/master/data/PathwayOntology.ttl
wget https://raw.githubusercontent.com/marvinm2/WikiPathwaysLoader/master/data/DiseaseOntology.ttl
```

Now we want to make a single file of the RDF data, by using the following sequence of commands:
```
unzip \*.zip
mv *.ttl wp
find . -name *.ttl -exec cat > WikiPathways.ttl {} \;
```

## Step 2 - Run a Virtuoso Docker image
We use the base [openlink/virtuoso-opensource-7](https://hub.docker.com/r/openlink/virtuoso-opensource-7/) Docker image to locally deploy a SPARQL endpoint with WikiPathways RDF. Make sure to change the "[datafolder]" with the full path of the folder. Type `pwd` to print the path. Run the Docker image:
```
sudo docker run -d --env DBA_PASSWORD=dba -p 8890:8890 -p 1111:1111 --name WikiPathways --volume `pwd`:/database/data/  openlink/virtuoso-opensource-7
```

## Step 3 - Load the data in the SPARQL endpoint
Enter the created container, relocate the `WikiPathways.ttl`:
```
sudo docker exec -it WikiPathways bash
```
When entered, move the file:
```
mv data/WikiPathways.ttl .
exit
```
Enter port 1111 and execute SQL loader commands:
```
sudo docker exec -i WikiPathways isql 1111
```
If this is not the first time loading data, be sure to reset the data with:
```
RDF_GLOBAL_RESET();
DELETE FROM load_list WHERE ll_graph = 'http://rdf.wikipathways.org/';
```
Load all prefixes of WikiPathways:
```
log_enable(2);
DB.DBA.XML_SET_NS_DECL ('dc', 'http://purl.org/dc/elements/1.1/',2);
DB.DBA.XML_SET_NS_DECL ('cas', 'http://identifiers.org/cas/',2);
DB.DBA.XML_SET_NS_DECL ('wprdf', 'http://rdf.wikipathways.org/',2);
DB.DBA.XML_SET_NS_DECL ('prov', 'http://www.w3.org/ns/prov#',2);
DB.DBA.XML_SET_NS_DECL ('foaf', 'http://xmlns.com/foaf/0.1/',2);
DB.DBA.XML_SET_NS_DECL ('hmdb', 'http://identifiers.org/hmdb/',2);
DB.DBA.XML_SET_NS_DECL ('freq', 'http://purl.org/cld/freq/',2);
DB.DBA.XML_SET_NS_DECL ('pubmed', 'http://www.ncbi.nlm.nih.gov/pubmed/',2);
DB.DBA.XML_SET_NS_DECL ('wp', 'http://vocabularies.wikipathways.org/wp#',2);
DB.DBA.XML_SET_NS_DECL ('void', 'http://rdfs.org/ns/void#',2);
DB.DBA.XML_SET_NS_DECL ('biopax', 'http://www.biopax.org/release/biopax-level3.owl#',2);
DB.DBA.XML_SET_NS_DECL ('dcterms', 'http://purl.org/dc/terms/',2);
DB.DBA.XML_SET_NS_DECL ('rdfs', 'http://www.w3.org/2000/01/rdf-schema#',2);
DB.DBA.XML_SET_NS_DECL ('pav', 'http://purl.org/pav/',2);
DB.DBA.XML_SET_NS_DECL ('ncbigene', 'http://identifiers.org/ncbigene/',2);
DB.DBA.XML_SET_NS_DECL ('xsd', 'http://www.w3.org/2001/XMLSchema#',2);
DB.DBA.XML_SET_NS_DECL ('rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',2);
DB.DBA.XML_SET_NS_DECL ('gpml', 'http://vocabularies.wikipathways.org/gpml#',2);
DB.DBA.XML_SET_NS_DECL ('skos', 'http://www.w3.org/2004/02/skos/core#',2);
DB.DBA.XML_SET_NS_DECL ('owl', 'http://www.w3.org/2002/07/owl#',2);
DB.DBA.XML_SET_NS_DECL ('efo', 'http://www.ebi.ac.uk/efo/',2);
DB.DBA.XML_SET_NS_DECL ('xml', 'http://www.w3.org/XML/1998/namespace',2);
DB.DBA.XML_SET_NS_DECL ('wiki', 'http://sparql.wikipathways.org/',2);
DB.DBA.XML_SET_NS_DECL ('cur', 'http://vocabularies.wikipathways.org/wp#Curation:',2);
```
Define the permissions to use the SPARQL endpoint with:
```
log_enable(1);
grant select on "DB.DBA.SPARQL_SINV_2" to "SPARQL";
grant execute on "DB.DBA.SPARQL_SINV_IMP" to "SPARQL";
```
Set the `WikiPathways.ttl` file ready to load:
```
ld_dir('.', 'WikiPathways.ttl', 'http://rdf.wikipathways.org/');
```
Run the loader:
```
rdf_loader_run();
```
To check the status of the loaded data, the ll_status in the load_list should be 2. Do this using:
```
select * from DB.DBA.load_list;
```
Exit the container:
```
quit;
```

Now the Virtuoso SPARQL endpoint should be running with WikiPathways RDF, with the version you selected. Go to [localhost:8890/sparql/](http://localhost:8890/sparql/) to access the SPARQL endpoint and execute queries.
