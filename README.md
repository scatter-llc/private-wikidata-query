[![License](https://img.shields.io/github/license/scatter-llc/private-wikidata-query.svg)](https://www.apache.org/licenses/LICENSE-2.0)

This is a minimal, Docker Compose-based setup of the Wikidata Query Service, including the Blazegraph database and the Wikidata Query Service frontend.

## Example
<img src="https://github.com/user-attachments/assets/145bd445-662d-4499-8f51-23cfef85f7cb" width="871" alt="Example Screenshot">

## Setup

### Using a pre-built data.jnl
1. `git clone https://github.com/scatter-llc/private-wikidata-query wdqs`

2. `cd wdqs`

3. `mkdir -p data`

4. `cd data`

5. Download a compressed data file from <https://datasets.orbopengraph.com/orb> or [another source](https://addshore.com/2023/08/wikidata-query-service-blazegraph-jnl-file-on-cloudflare-r2-and-internet-archive/).

6. `gzip -d [downloaded file]`

7. `mv [decompressed downloaded file] data.jnl`

8. `docker compose up -d`

### Using a TTL dump

1. `git clone https://github.com/scatter-llc/private-wikidata-query wdqs`

2. `cd wdqs`

3. `mkdir -p sources`

4. `cd sources`

5. Download a Wikidata TTL dump: `wget https://datasets.orbopengraph.com/wikimedia/other/wikibase/wikidatawiki/latest-all.ttl.gz` (you can also use [your preferred mirror](https://meta.wikimedia.org/wiki/Mirroring_Wikimedia_project_XML_dumps))

6. `cd ..`

7. `docker compose up -d`

These next steps will each take several days; you may want to run them in something like `tmux`:

8. Pre-process the data using the "munge" script: `docker exec wdqs-wdqs-1 /wdqs/munge.sh -c 25000 -f /sources/latest-all.ttl.gz -d /sources`

9. Load processed data into Blazegraph: `docker exec wdqs-wdqs-1 /wdqs/loadData.sh -n wdq -d /sources`

### After setup
Access your new query service at <http://localhost:8099>.

You can access the SPARQL endpoint directly: <http://localhost:8099/proxy/wdqs/bigdata/namespace/wdq/sparql>.

## Run the updater

To keep your data up to date, run the update script, preferably using something like `tmux` to persist the process:

`docker exec wdqs-wdqs-1 /wdqs/runUpdate.sh`
