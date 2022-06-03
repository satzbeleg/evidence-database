
data = (
    ('Moyses hat seinem Feind dem Pharad in dem Wasser deß rothen Meers versencket aber Magdalena in disem Wasser vil besser.', 'Fahrrad', [[28, 34]]),
    ('Es ist die Ebene von Beisittun, vor dem Ausgange jenes Felsenweges, der durch die Liebe des unglücklichen Fahrat zur schönen Schirin im Morgenlande so berühmt ist.','Fahrrad', [[106, 112]]),
    ('Letzterer besteht aus einem von 2 Fahrrädern und einem Vorderkarren getragenen Gestelle, unter welchem, von gekuppelten Hebeln getragen, ein für den Tiefgang stellbarer Rahmen mit Scharen angebracht ist.', 'Fahrrad', [[34, 43]]),
    ('Derselbe besteht aus einem durch zwei große Fahrräder im Schwerpunkte unterstützten, schmiedeeisernen Rahmen, an dessen beiden in einem stumpfen Winkel zu einander stehenden Seitentheilen in einer Reihe 4--8 stählerne Pflugkörper befestigt sind.', 'Fahrrad', [[44, 53]]),
    ('Die Fahrräder des Grubbers werden durch den Führer gesteuert, der bei dem Kehren des Geräthes nur seinen Sitz zu wechseln hat.', 'Fahrrad', [[4, 13]]),
    ('Der Cultivator wird dadurch etwas nach rückwärts geschoben und das neue Fahrrad und mit diesem die Schare durch Aufstellen auf den mit einer Scharspitze versehenen Schuh gehoben.', 'Fahrrad', [[72, 79]]),
    ('Wichtig für den Radfahrer ist ferner die Signalglocke, welche in Anbetracht der fast lautlosen Bewegung des Fahrrades unentbehrlich ist, um Collisionen zu vermeiden.', 'Fahrrad', [[108, 117]]),
    ('Die Bremsvorrichtung bildet einen wichtigen Bestandtheil des Fahrrades.', 'Fahrrad', [[61, 70]]),
    ('Solche hohe Personen werfen in der einen Stunde einen Wunsch hin, um ihn in der nächsten zu vergessen.', 'hinwerfen', [[61,64], [21,27]]),
    ('Das warf auch Bonaparte im Gespräch hin.', 'hinwerfen', [[36,39], [4,8]]),
    ('Denn so lange dies Verhältniß bestanden, war unser Freund zwischen Lust und Gram, zwischen Trotz und Reue, zwischen Begier und Abscheu hin und her geworfen zu keiner eigentlichen Ruhe gelangt.', 'hinwerfen', [[135,138], [147,155]]),
    ('Ja, so beim Kaffee, so unter der Hand, gelegentlich hingeworfen, erfährt ein Fürst die Wahrheit -- von guten Freunden.', 'hinwerfen', [[52, 63]]),
    ('Ueberall hin warf es seine Schatten.', 'hinwerfen', [[9, 17]]),
    ('Nun lebten sie frech in kurzen Lüsten, und über den Tag hin warfen sie kaum noch Ziele.', 'hinwerfen', [[56, 66]])
)


query_start = (
    "INSERT INTO evidence.examples ("
    "example_id, sentence_text, headword, spans, "
    "features1, features2, "
    "sentence_id, license, initial_score) VALUES")

import uuid
import random

fp = open("999-toy-data1.cql", "w")
fp.write("")
fp.close()

fp = open("999-toy-data1.cql", "a")

for sent, headword, spans in data:
    example_id = str(uuid.uuid4())
    features1 = [random.randint(-128, 127) for _ in range(128)]  # 1024 bit
    features2 = [random.randint(0, 127) for _ in range(96)]  # count data
    sentence_id = str(uuid.uuid4())  # e.g. folia_id
    license = "No License"
    initial_score = float(random.random())
    query = (
        f"{query_start} ({example_id}, '{sent}', '{headword}', {spans}, "
        f"{features1}, {features2}, "
        f"'{sentence_id}', '{license}', {initial_score});\n")
    fp.write(query)

fp.close()
