# Hunspell german dictionary with support of compound words

This is Postgresql extension that installs Hunspell dictionaries with recognizing of the words that can be compounds of other words.
The dictionaries were copied from here: http://www.sai.msu.su/~megera/postgres/gist/tsearch/V2/

## Install

```bash
make
sudo make install
```

If you need to specify path to `pg_config`
```bash
make PG_CONFIG=/usr/pgsql-12/bin/pg_config
sudo make PG_CONFIG=/usr/pgsql-12/bin/pg_config install
```

## Usage

```sql
CREATE EXTENSION hu_de_cmp;

SELECT ts_lexize('de_cmp', 'wärmepumpen');
SELECT to_tsvector('de_cmp', 'wärmepumpen');
```
