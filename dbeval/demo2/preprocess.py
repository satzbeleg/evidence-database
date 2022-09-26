import glob
import json
import evidence_features as evf
import evidence_features.cql

conn = evf.cql.CqlConn(keyspace="evidence", port=9042, contact_points=['0.0.0.0'])
session = conn.get_session()

# mappings for scores
classmap = {6: .95, 5: .85, 4: .75, 1: .05}

for FILE in glob.glob("./dbeval/demo2/*.json"):
    # read JSON file
    dat = json.load(open(FILE, "r"))
    dat = [d for d in dat if d.get("sentence") is not None]
    sentences = [d.get("sentence", "") for d in dat]
    biblio = [d.get("meta_source", "") for d in dat]
    scores = [classmap.get(d.get("class"), .5) for d in dat]
    # encode and save sentences
    evf.cql.insert_sentences(
        session, sentences, biblio=biblio, scores=scores)

# close connection
conn.shutdown()
