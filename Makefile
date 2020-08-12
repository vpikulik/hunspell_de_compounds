
.DEFAULT_GOAL := all
EXTENSION = hu_de_cmp
EXTVERSION   = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
DATA_TSEARCH = hunspell_de_compounds.affix hunspell_de_compounds.dict

EXTRA_CLEAN = build/$(EXTENSION)--$(EXTVERSION).sql

build:
	mkdir build

build/$(EXTENSION)--$(EXTVERSION).sql: build
	cat install.sql > $@

DATA_built = build/$(EXTENSION)--$(EXTVERSION).sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
