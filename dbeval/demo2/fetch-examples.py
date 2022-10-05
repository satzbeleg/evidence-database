import evidence_features as evf
import evidence_features.cql

# lookup all headwords in the db
headwords = evf.cql.get_headwords(session)

# specify headword
# - ADJ: blau, hell, regimefeindlich, schnell, technisch, witzig
# - NOUN: Gradient, Insel, Internet, Regen, Käse, Wüste
# - VERB: digitalisieren, fließen, pflegen, schmelzen, turnen, ziehen
headword = "blau"

# download partition for variations
(
    sentences2, biblio, scores, 
    feats_semantic, hashes_grammar, hashes_duplicate, hashes_biblio
) = evf.cql.download_similarity_features(session, headword=headword)
# np.mean(feats_duplicate[0] == feats_duplicate[1])

# download partition for scoring, e.g. convert to float
sentences3, feats = evf.cql.download_scoring_features(
    session, headword=headword)
