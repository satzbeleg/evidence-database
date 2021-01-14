
-- 
-- evidence.sentences_cache
-- 
INSERT INTO evidence.sentences_cache(sentence_id, sentence_text) VALUES
 (uuid_generate_v4(), 'Impeachment ist derzeit ein Begriff mit besonderer Schlagkraft.')
,(uuid_generate_v4(), 'Nach den jüngsten Ausschreitungen am und im Washingtoner Kapitol droht dem noch amtierenden amerikanischen Präsidenten Donald Trump – erstmals in der Geschichte der USA – ein zweites Amtsenthebungsverfahren.')
,(uuid_generate_v4(), 'Sollten alle drei Prozessschritte (Untersuchung und Anklage, Verfahrenseinleitung durch Wahl im Repräsentantenhaus, Anhörung und Verurteilung im Senat) erfolgreich sein, wird er sofort seines Amtes enthoben und könnte (auch nach Ende seiner Regierungszeit) einige oder alle seine Privilegien (Pension bis zum Lebensende, Reisebudget etc.) verlieren.')
,(uuid_generate_v4(), 'Auf Bundesebene braucht es für eine Anklage (Impeachment) eine einfache Mehrheit im Repräsentantenhaus und danach für eine Verurteilung (Amtsenthebung) eine Zweidrittelmehrheit im Senat.')
,(uuid_generate_v4(), 'Diese Gefahr ist für ihn schwieriger zu kalkulieren als das Risiko eines Impeachments durch das Repräsentantenhaus, auf das er durch politische und legalistische Schachzüge nach wie vor Einfluß nehmen kann.')
,(uuid_generate_v4(), 'Impeachment ist das formelle Amtsenthebungsverfahren gegen den Präsidenten durch den Kongreß.')
,(uuid_generate_v4(), 'Der Rechtsausschuß des Kongresses leitet das Impeachment ein.')
,(uuid_generate_v4(), 'Nach Artikel 14 der US-Verfassung kann gegen den Präsidenten das sog. Impeachment (dt. Amtsenthebungs-Verfahren) eingeleitet werden, wenn ein schweres Verbrechen oder ein kriminelles Fehlverhalten (z. B. Meineid) vorliegt.')
,(uuid_generate_v4(), 'Die erste parlamentarische Abstimmung über das Impeachment wird von der Tagesordnung der Dumasitzung am kommenden Donnerstag gestrichen.')
,(uuid_generate_v4(), 'Aber er ließ keinen Zweifel daran, dass Rücktritt oder gar das Impeachment eine zu schwere Buße wären.')
,(uuid_generate_v4(), 'Nixons politische Stellung und die Frage, ob ein Impeachment (Absetzungsverfahren im Kongreß) eingeleitet werden soll, werden unterschiedlich bewertet.')
,(uuid_generate_v4(), 'Statt dessen sollen Zeugen vor dem Ausschuß erklären, daß die Lewinsky-Affäre weit weniger schwer wiege als der Machtmißbrauch, der Präsident Nixon 1974 noch vor der Einleitung des Impeachments zum Rücktritt zwang.')
,(uuid_generate_v4(), 'Freilich erlangte Ford diese überwältigende Zustimmung nicht zuletztdeshalb, weil die meisten Demokraten davon ausgingen, er werde 1976 der denkbar schwächste republikanische Kandidat für das Amt des Präsidenten sein; der Rücktritt oder das Impeachment Richard Nixons waren damals noch nicht sicher voraussagbar.')
,(uuid_generate_v4(), 'Es ist anzunehmen, daß Nixon im Falle eines „Impeachments“ freiwillig abdankte.')
,(uuid_generate_v4(), 'Nixon, so sagt Jenner, „sollte für die Handlungen seiner Mitarbeiter verantwortlich gemacht werden, selbst wenn er nicht wußte, daß einer von ihnen etwas tat, was zu einem Impeachment führen könnte, wenn der Präsident selbst es täte.“')
,(uuid_generate_v4(), 'Ob der zunächst geheim gebliebene Befund der grand jury über Nixons Rolle in der Affäre dem Repräsentantenhaus den entscheidenden Anstoß oder gar die Handhabe zum impeachment geben wird, läßt sich mit Sicherheit nicht voraussagen.')
,(uuid_generate_v4(), 'Der Oberste Gerichtshof entschied am Mittwoch voriger Woche einstimmig, Nixon müsse die 64 Tonbänder herausgeben, die Sonderankläger Jaworski für den Prozeß gegen mehrere Präsidenten-Berater verlangt hat; der Rechtsausschuß des Repräsentantenhauses sprach sich in der Nacht zum Sonntag mit 27:11 Stimmen für ein Amtsenthebungsverfahren (Impeachment) aus.')
,(uuid_generate_v4(), 'Sollte das russische Unterhaus in der für den 15. April angesetzten Abstimmung über die Amtsenthebung mehrheitlich für das Impeachment stimmen, werde Präsident Boris Jelzin zur Auflösung des Parlaments schreiten, glaubt das Blatt.')
,(uuid_generate_v4(), 'Warum hat Boris Jelzin ausgerechnet unmittelbar vor der Abstimmung über das Impeachment den im Parlament angesehenen Primakow entlassen?')
,(uuid_generate_v4(), 'Jelzin darf zwar das Parlament nicht auflösen, wenn ein Impeachment gegen ihn läuft.')
,(uuid_generate_v4(), 'Sergej Stepaschin konnte fast zwei Drittel der Abgeordneten für sich gewinnen, mehr, als am Sonntag für das gescheiterte Impeachment gegen Jelzin stimmten.')
,(uuid_generate_v4(), 'Beobachter rechneten damit, daß die Duma im angeheizten Machtkampf mit Jelzin die notwendige Mehrheit für die Einleitung des Impeachments sammeln könnte.')
ON CONFLICT DO NOTHING
;


-- 
-- Generate fake example items
-- A1. Whitespace Tokenization with STRING_TO_ARRAY
-- A2. Expand sql array row to N txt rows (UNNEST)
-- A3. Trim each string
-- A4. Remove all non-alphanumeric symbols
-- B. Add some non-saying context data
-- C. Generate random score
-- 
INSERT INTO evidence.example_items (sentence_id, lemma, context, score)
    SELECT sentence_id
        , regexp_replace(regexp_replace(
                UNNEST(STRING_TO_ARRAY(sentence_text, ' ')),
                '[\s+]', '', 'g'), '\W+', '', 'g')::text as "lemma"
        , '{"publisher": "DWDS Wörterbuch"}'::jsonb as "context"
        , random()::double precision as "score"
    FROM evidence.sentences_cache
ON CONFLICT DO NOTHING
;

