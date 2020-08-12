CREATE TEXT SEARCH DICTIONARY de_cmp (
    TEMPLATE = ispell,
    DictFile = hunspell_de_compounds,
    AffFile = hunspell_de_compounds,
    Stopwords = german);
CREATE TEXT SEARCH CONFIGURATION de_cmp ( COPY = pg_catalog.german );
ALTER TEXT SEARCH CONFIGURATION de_cmp
    ALTER MAPPING FOR asciiword, asciihword, hword_asciipart,
                      word, hword, hword_part
    WITH de_cmp, german_stem;
