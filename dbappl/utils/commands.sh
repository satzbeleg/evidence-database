
# login into docker container
docker exec -it zdl_evidence_db bash
# open psql console
psql -U evidence evidence
# run script
psql -U evidence evidence -f sync-example_items.sql

# Rebuild indices
docker exec -it zdl_evidence_db psql -U evidence -d evidence -t -A -F"," -c \
    "CALL evidence.rebuild_indices();" &
docker exec -it zdl_evidence_db psql -U evidence -d evidence -t -A -F"," -c \
    "CALL zdlstore.rebuild_indices();" &
docker exec -it zdl_evidence_db psql -U evidence -d evidence -t -A -F"," -c \
    "CALL auth.rebuild_indices();" &
