--
-- PostgreSQL database cluster dump
--

-- Started on 2024-08-27 17:17:32

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'secret';
CREATE ROLE sikula;
ALTER ROLE sikula WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'secret';

--
-- User Configurations
--








--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.2

-- Started on 2024-08-27 17:17:32

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Completed on 2024-08-27 17:17:34

--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.2

-- Started on 2024-08-27 17:17:34

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Completed on 2024-08-27 17:17:35

--
-- PostgreSQL database dump complete
--

--
-- Database "sikula24" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.2

-- Started on 2024-08-27 17:17:35

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3544 (class 1262 OID 16388)
-- Name: sikula24; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE sikula24 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE sikula24 OWNER TO postgres;

\connect sikula24

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 245 (class 1255 OID 16389)
-- Name: insert_into_nabidka(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_into_nabidka() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_exists BOOLEAN;
BEGIN
    -- Kontrola existence položky se stejným názvem a nižším id v tabulce nabidka s v_nabidce=true
    SELECT EXISTS (
        SELECT 1
        FROM nabidka
        JOIN polozky ON nabidka.id_polozka = polozky.id
        WHERE polozky.nazev = NEW.nazev AND nabidka.id < NEW.id AND nabidka.v_nabidce = true
    ) INTO item_exists;

    -- Vložení nové položky do tabulky nabidka
    INSERT INTO public.nabidka (id_polozka, zbyvajici_kusy, v_nabidce)
    VALUES (NEW.id, NEW.nakoupene_kusy, NOT item_exists);

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_into_nabidka() OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 16390)
-- Name: insert_into_nakupy(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_into_nakupy() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	castka_polozky numeric;
	castka_lahve integer;
	castka_prepravky integer;
	kategorie_zaznam RECORD;
BEGIN
	-- castky jsou zaporne, nebot to jsou vydaje
	castka_polozky = -(NEW.nakoupene_kusy * NEW.nakupni_cena);
	
	SELECT INTO kategorie_zaznam *
    FROM kategorie
    WHERE kategorie.id = NEW.id_kategorie;

    INSERT INTO public.nakupy (id_polozka, castka, id_ucet, id_transakce)
    VALUES (NEW.id, castka_polozky, NEW.id_ucet, '1');
	
	-- Toto je napsané natvrdo, přes id kategorie a id_transakce!!!
	
	IF NEW.id_kategorie = 1 OR NEW.id_kategorie = 6 THEN
		castka_lahve = -(kategorie_zaznam.zaloha_lahev * NEW.nakoupene_kusy);
	    INSERT INTO public.nakupy (id_polozka, castka, id_ucet, id_transakce)
    	VALUES (NEW.id, castka_lahve, NEW.id_ucet, '2');
	END IF;
	IF NEW.id_kategorie = 1 OR NEW.id_kategorie = 5 THEN
		castka_prepravky = -(kategorie_zaznam.zaloha_prepravka * (NEW.nakoupene_kusy / kategorie_zaznam.kusu_v_prepravce));
		INSERT INTO public.nakupy (id_polozka, castka, id_ucet, id_transakce)
    	VALUES (NEW.id, castka_prepravky, NEW.id_ucet, '3');
	END IF;

    RETURN NEW;
END;

$$;


ALTER FUNCTION public.insert_into_nakupy() OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 16391)
-- Name: insert_or_update_obaly(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_or_update_obaly() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    jednotkova_zaloha integer;
BEGIN
    IF NEW.druh = 'Lahve' THEN
        SELECT zaloha_lahev INTO jednotkova_zaloha
        FROM public.kategorie
        WHERE id = '1';
    ELSE
        SELECT zaloha_prepravka INTO jednotkova_zaloha
        FROM public.kategorie
        WHERE id = '1';
    END IF;
	
	 NEW.castka := NEW.kusu * jednotkova_zaloha;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_or_update_obaly() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16392)
-- Name: recalculate_prepravky_from_polozky(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recalculate_prepravky_from_polozky() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    kusy_v_prepravce INTEGER;
    stary_pocet_prepravek INTEGER;
    novy_pocet_prepravek INTEGER;
BEGIN
    -- Získání počtu kusů v jedné přepravce pro kategorii 1
    SELECT kusu_v_prepravce INTO kusy_v_prepravce
    FROM kategorie
    WHERE id = 1;

    -- Výpočet starého a nového počtu přepravek
    stary_pocet_prepravek := OLD.nakoupene_kusy / kusy_v_prepravce;
    novy_pocet_prepravek := NEW.nakoupene_kusy / kusy_v_prepravce;

    -- Aktualizace tabulky obaly_sklipek
    UPDATE obaly_sklipek
    SET kusu = kusu - stary_pocet_prepravek + novy_pocet_prepravek
    WHERE id = 2;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.recalculate_prepravky_from_polozky() OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 16624)
-- Name: trg_update_nabidka_from_konzumace_update_polozka(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_update_nabidka_from_konzumace_update_polozka() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Pokud se změnilo id_polozka, proveď úpravy
    IF OLD.id_polozka IS DISTINCT FROM NEW.id_polozka THEN
        RAISE NOTICE 'OLD.id_polozka: %, NEW.id_polozka: %', OLD.id_polozka, NEW.id_polozka;
        RAISE NOTICE 'OLD.kusu: %, NEW.kusu: %', OLD.kusu, NEW.kusu;

        -- Snížení počtu kusů staré položky v tabulce nabidka
        IF OLD.id_polozka IS NOT NULL THEN
            UPDATE nabidka
            SET zbyvajici_kusy = zbyvajici_kusy + OLD.kusu
            WHERE id_polozka = OLD.id_polozka;
        END IF;

        -- Zvýšení počtu kusů nové položky v tabulce nabidka
        IF NEW.id_polozka IS NOT NULL THEN
            UPDATE nabidka
            SET zbyvajici_kusy = zbyvajici_kusy - NEW.kusu
            WHERE id_polozka = NEW.id_polozka;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_update_nabidka_from_konzumace_update_polozka() OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 16393)
-- Name: update_konzumenti_from_konzumace(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_konzumenti_from_konzumace() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Pokud se konzument mění, upravíme starého konzumenta
    IF OLD.id_konzument IS DISTINCT FROM NEW.id_konzument THEN
        -- Odečteme staré hodnoty od starého konzumenta
        UPDATE public.konzumenti
        SET kredit = kredit - OLD.pevna_cena,
            zkonzumovanych_kusu = zkonzumovanych_kusu - OLD.kusu
        WHERE id = OLD.id_konzument;

        -- Přičteme nové hodnoty k novému konzumentovi
        UPDATE public.konzumenti
        SET kredit = kredit + NEW.pevna_cena,
            zkonzumovanych_kusu = zkonzumovanych_kusu + NEW.kusu
        WHERE id = NEW.id_konzument;
    ELSE
        -- Pokud se konzument nemění, upravíme hodnoty jen jednou
        UPDATE public.konzumenti
        SET kredit = kredit - OLD.pevna_cena + NEW.pevna_cena,
            zkonzumovanych_kusu = zkonzumovanych_kusu - OLD.kusu + NEW.kusu
        WHERE id = NEW.id_konzument;
    END IF;

    -- Úprava načárkovaných kusů u starého carkujici
    UPDATE public.konzumenti
    SET nacarkovanych_kusu = nacarkovanych_kusu - OLD.kusu
    WHERE id = OLD.id_carkujici;

    -- Úprava načárkovaných kusů u nového carkujici
    UPDATE public.konzumenti
    SET nacarkovanych_kusu = nacarkovanych_kusu + NEW.kusu
    WHERE id = NEW.id_carkujici;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_konzumenti_from_konzumace() OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 16394)
-- Name: update_kredit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_kredit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	
	UPDATE public.konzumenti
    SET kredit = kredit - OLD.castka + NEW.castka
    WHERE id = NEW.id_konzument;
	
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_kredit() OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 16395)
-- Name: update_kredit_after_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_kredit_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN
	UPDATE public.konzumenti
    SET kredit = kredit + NEW.castka
    WHERE id = NEW.id_konzument;
	
    RETURN NEW;
END;

$$;


ALTER FUNCTION public.update_kredit_after_insert() OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 16396)
-- Name: update_kredit_from_konzumace(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_kredit_from_konzumace() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN
	UPDATE public.konzumenti
    SET kredit = kredit + NEW.pevna_cena
    WHERE id = NEW.id_konzument;
	
    RETURN NEW;
END;

$$;


ALTER FUNCTION public.update_kredit_from_konzumace() OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 16397)
-- Name: update_kusu_from_konzumace(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_kusu_from_konzumace() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    id_kategorie INTEGER;
BEGIN
    -- Získání id_kategorie z tabulky polozky
    SELECT p.id_kategorie INTO id_kategorie
    FROM public.polozky p
    WHERE p.id = NEW.id_polozka;

    -- Pokud id_kategorie je 1 nebo 6, aktualizuj obaly_sklipek
    IF id_kategorie = 1 OR id_kategorie = 6 THEN
        UPDATE public.obaly_sklipek
        SET kusu = kusu + NEW.kusu
        WHERE id = 1;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_kusu_from_konzumace() OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 16398)
-- Name: update_kusu_from_konzumace_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_kusu_from_konzumace_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    id_kategorie INTEGER;
    old_kusu INTEGER;
BEGIN
    -- Získání id_kategorie z tabulky polozky
    SELECT p.id_kategorie INTO id_kategorie
    FROM public.polozky p
    WHERE p.id = NEW.id_polozka;

    -- Pokud id_kategorie je 1 nebo 6, aktualizuj obaly_sklipek
    IF id_kategorie = 1 OR id_kategorie = 6 THEN
        -- Odečtení starých kusů
        UPDATE public.obaly_sklipek
        SET kusu = kusu - OLD.kusu
        WHERE id = 1;

        -- Přičtení nových kusů
        UPDATE public.obaly_sklipek
        SET kusu = kusu + NEW.kusu
        WHERE id = 1;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_kusu_from_konzumace_update() OWNER TO postgres;

--
-- TOC entry 274 (class 1255 OID 16399)
-- Name: update_kusu_from_obaly_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_kusu_from_obaly_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Podmínka pro druh 'Lahve'
    IF NEW.druh = 'Lahve' THEN
        -- Odečtení počtu kusů z tabulky obaly_sklipek
        UPDATE public.obaly_sklipek
        SET kusu = kusu - NEW.kusu
        WHERE id = 1;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_kusu_from_obaly_insert() OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 16400)
-- Name: update_kusu_from_obaly_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_kusu_from_obaly_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Podmínka pro druh 'Lahve'
    IF NEW.druh = 'Lahve' THEN
        -- Odečtení starých kusů a přičtení nových kusů v tabulce obaly_sklipek
        UPDATE public.obaly_sklipek
        SET kusu = kusu + OLD.kusu - NEW.kusu
        WHERE id = 1;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_kusu_from_obaly_update() OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 16401)
-- Name: update_nabidka_from_konzumace(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_nabidka_from_konzumace() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE public.nabidka
    SET zbyvajici_kusy = zbyvajici_kusy - (NEW.kusu - OLD.kusu)
    WHERE id_polozka = OLD.id_polozka;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_nabidka_from_konzumace() OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 16402)
-- Name: update_nabidka_from_polozky(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_nabidka_from_polozky() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.nabidka
    SET zbyvajici_kusy = zbyvajici_kusy - OLD.nakoupene_kusy + NEW.nakoupene_kusy
    WHERE id_polozka = NEW.id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_nabidka_from_polozky() OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 16403)
-- Name: update_nakupy_from_polozky(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_nakupy_from_polozky() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.nakupy
    SET id_ucet = NEW.id_ucet
    WHERE id_polozka = NEW.id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_nakupy_from_polozky() OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 16404)
-- Name: update_obaly_sklipek_from_korekce(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_obaly_sklipek_from_korekce() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Zkontrolujeme, zda je id_polozka 1 nebo 2
    IF NEW.id_polozka = 1 OR NEW.id_polozka = 2 THEN
        -- Aktualizujeme odpovídající záznam v tabulce obaly_sklipek
        UPDATE obaly_sklipek
        SET kusu = kusu + NEW.rozdil_kusu
        WHERE id = NEW.id_polozka;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_obaly_sklipek_from_korekce() OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 16405)
-- Name: update_prepravky_after_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_prepravky_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ověření, že druh obalu je 'Přepravky'
    IF NEW.druh = 'Přepravky' THEN
        -- Aktualizace tabulky obaly_sklipek
        UPDATE obaly_sklipek
        SET kusu = kusu - NEW.kusu
        WHERE id = 2;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_prepravky_after_insert() OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 16406)
-- Name: update_prepravky_after_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_prepravky_after_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ověření, že druh obalu je 'Přepravky'
    IF NEW.druh = 'Přepravky' THEN
        -- Aktualizace tabulky obaly_sklipek
        UPDATE obaly_sklipek
        SET kusu = kusu - (NEW.kusu - OLD.kusu)
        WHERE id = 2;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_prepravky_after_update() OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 16407)
-- Name: update_prepravky_from_polozky(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_prepravky_from_polozky() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    kusy_v_prepravce INTEGER;
    pocet_prepravek INTEGER;
BEGIN
    -- Získání počtu kusů v jedné přepravce pro kategorii 1
    SELECT kusu_v_prepravce INTO kusy_v_prepravce
    FROM kategorie
    WHERE id = 1;

    -- Výpočet počtu přepravek
    pocet_prepravek := NEW.nakoupene_kusy / kusy_v_prepravce;

    -- Aktualizace tabulky obaly_sklipek
    UPDATE obaly_sklipek
    SET kusu = kusu + pocet_prepravek
    WHERE id = 2; -- předpokládám, že id pro přepravky je 1, případně uprav podle potřeby

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_prepravky_from_polozky() OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 16408)
-- Name: update_v_nabidce(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_v_nabidce() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_name VARCHAR(255);
    higher_item RECORD;
BEGIN
    -- Získáme název položky pomocí spojení s tabulkou polozky
    SELECT INTO item_name polozky.nazev
    FROM nabidka
	JOIN polozky ON nabidka.id_polozka = polozky.id
    WHERE polozky.id = NEW.id_polozka;

    -- Pokud počet zbylých kusů klesne na nulu, nastavíme v_nabidce na false
    IF NEW.zbyvajici_kusy <= 0 THEN
        UPDATE nabidka
        SET v_nabidce = false
        WHERE id = NEW.id;

        -- Zkontrolujeme, zda existuje jiná položka se stejným názvem a vyšším id a nenulovým počtem zbylých kusů
        SELECT INTO higher_item *
        FROM nabidka
        JOIN polozky ON nabidka.id_polozka = polozky.id
        WHERE polozky.nazev = item_name AND nabidka.id > NEW.id AND nabidka.zbyvajici_kusy > 0
        ORDER BY nabidka.id ASC
        LIMIT 1;

        -- Pokud taková položka existuje, nastavíme její v_nabidce na true
        IF higher_item.id IS NOT NULL THEN
            UPDATE nabidka
            SET v_nabidce = true
            WHERE id = higher_item.id;
        END IF;
    ELSE
        -- Pokud počet zbylých kusů je kladný, nastavíme v_nabidce na true
        UPDATE nabidka
        SET v_nabidce = true
        WHERE id = NEW.id;

        -- Zkontrolujeme, zda existuje jiná položka se stejným názvem a vyšším id a nenulovým počtem zbylých kusů
        SELECT INTO higher_item *
        FROM nabidka
        JOIN polozky ON nabidka.id_polozka = polozky.id
        WHERE polozky.nazev = item_name AND nabidka.id > NEW.id AND nabidka.zbyvajici_kusy > 0
        ORDER BY nabidka.id ASC
        LIMIT 1;

        -- Pokud taková položka existuje, nastavíme její v_nabidce na false
        IF higher_item.id IS NOT NULL THEN
            UPDATE nabidka
            SET v_nabidce = false
            WHERE id = higher_item.id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_v_nabidce() OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 16409)
-- Name: update_v_nabidce_false(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_v_nabidce_false() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.zbyvajici_kusy = 0 THEN
        UPDATE public.nabidka
        SET v_nabidce = false
        WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_v_nabidce_false() OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 16410)
-- Name: update_zbyvajici_kusy(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_zbyvajici_kusy() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.nabidka
    SET zbyvajici_kusy = zbyvajici_kusy - NEW.kusu
    WHERE id_polozka = NEW.id_polozka;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_zbyvajici_kusy() OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 16411)
-- Name: update_zbyvajici_kusy_from_korekce(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_zbyvajici_kusy_from_korekce() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Aktualizace sloupce zbyvajici_kusy v tabulce nabidka
    UPDATE public.nabidka
    SET zbyvajici_kusy = zbyvajici_kusy + NEW.rozdil_kusu
    WHERE id_polozka = NEW.id_polozka;

    -- Pokud je id_kategorie = 1, aktualizujeme tabulku obaly_sklipek
    IF (SELECT id_kategorie FROM public.polozky WHERE id = NEW.id_polozka) = 1 THEN
        UPDATE public.obaly_sklipek
        SET kusu = kusu - NEW.rozdil_kusu
        WHERE id = 1;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_zbyvajici_kusy_from_korekce() OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 16412)
-- Name: update_zkonzumovane_nacarkovane_kusy(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_zkonzumovane_nacarkovane_kusy() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

	UPDATE public.konzumenti
    SET kredit = kredit + NEW.pevna_cena
    WHERE id = NEW.id_konzument;
	
	UPDATE public.konzumenti
    SET zkonzumovanych_kusu = zkonzumovanych_kusu + NEW.kusu
    WHERE id = NEW.id_konzument;

    UPDATE public.konzumenti
    SET nacarkovanych_kusu = nacarkovanych_kusu + NEW.kusu
    WHERE id = NEW.id_carkujici;
	
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_zkonzumovane_nacarkovane_kusy() OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16413)
-- Name: kategorie_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kategorie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kategorie_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 16414)
-- Name: kategorie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kategorie (
    id integer DEFAULT nextval('public.kategorie_id_seq'::regclass) NOT NULL,
    oznaceni character varying(255),
    popis character varying(255),
    zaloha_lahev integer,
    zaloha_prepravka integer,
    kusu_v_prepravce integer
);


ALTER TABLE public.kategorie OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16420)
-- Name: konzumace_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.konzumace_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.konzumace_id_seq OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16421)
-- Name: konzumace; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.konzumace (
    id integer DEFAULT nextval('public.konzumace_id_seq'::regclass) NOT NULL,
    datum_cas timestamp without time zone,
    id_konzument integer,
    id_carkujici integer,
    id_polozka integer,
    kusu integer,
    pevna_cena numeric,
    poznamka character varying(255)
);


ALTER TABLE public.konzumace OWNER TO postgres;

--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN konzumace.pevna_cena; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.konzumace.pevna_cena IS 'Cena nikam neodkazuje, ale je pevna. Konzument si to kupuje za znamou cenu, ktera by se pote jiz nemela menit, ani zasahem zmeny prodejni ceny polozky hospodarem. Ochrana spotrebitele.';


--
-- TOC entry 219 (class 1259 OID 16427)
-- Name: konzumenti_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.konzumenti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.konzumenti_id_seq OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16428)
-- Name: konzumenti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.konzumenti (
    id integer DEFAULT nextval('public.konzumenti_id_seq'::regclass) NOT NULL,
    id_vedouci integer,
    cip character varying(255),
    kredit numeric,
    zkonzumovanych_kusu integer,
    nacarkovanych_kusu integer
);


ALTER TABLE public.konzumenti OWNER TO postgres;

--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN konzumenti.nacarkovanych_kusu; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.konzumenti.nacarkovanych_kusu IS 'počet kusů, který konzument někomu (nebo i sobě) načárkoval = tedy program legolas / dobíječ';


--
-- TOC entry 221 (class 1259 OID 16434)
-- Name: korekce_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.korekce_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.korekce_id_seq OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16435)
-- Name: korekce; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.korekce (
    id integer DEFAULT nextval('public.korekce_id_seq'::regclass) NOT NULL,
    datum_cas timestamp without time zone,
    id_polozka integer,
    rozdil_kusu integer,
    id_zapsal integer,
    poznamka character varying(255)
);


ALTER TABLE public.korekce OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16439)
-- Name: nabidka_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nabidka_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nabidka_id_seq OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16440)
-- Name: nabidka; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nabidka (
    id integer DEFAULT nextval('public.nabidka_id_seq'::regclass) NOT NULL,
    id_polozka integer,
    zbyvajici_kusy integer,
    v_nabidce boolean
);


ALTER TABLE public.nabidka OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16444)
-- Name: nakupy_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nakupy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nakupy_id_seq OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16445)
-- Name: nakupy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nakupy (
    id integer DEFAULT nextval('public.nakupy_id_seq'::regclass) NOT NULL,
    id_polozka integer,
    castka numeric,
    id_ucet integer,
    id_transakce integer
);


ALTER TABLE public.nakupy OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16451)
-- Name: obaly_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.obaly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.obaly_id_seq OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16452)
-- Name: obaly; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.obaly (
    id integer DEFAULT nextval('public.obaly_id_seq'::regclass) NOT NULL,
    datum_cas timestamp without time zone,
    kusu integer,
    castka numeric,
    druh character varying(255),
    id_ucet integer,
    id_vyridil integer,
    poznamka character varying(255)
);


ALTER TABLE public.obaly OWNER TO postgres;

--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE obaly; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.obaly IS 'tabulka s vrácenými obaly';


--
-- TOC entry 229 (class 1259 OID 16458)
-- Name: obaly_sklipek_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.obaly_sklipek_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.obaly_sklipek_id_seq OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16459)
-- Name: obaly_sklipek; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.obaly_sklipek (
    id integer DEFAULT nextval('public.obaly_sklipek_id_seq'::regclass) NOT NULL,
    nazev character varying(255),
    kusu integer
);


ALTER TABLE public.obaly_sklipek OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16463)
-- Name: polozky_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.polozky_id_seq
    START WITH 3
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.polozky_id_seq OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16464)
-- Name: polozky; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.polozky (
    id integer DEFAULT nextval('public.polozky_id_seq'::regclass) NOT NULL,
    datum_cas timestamp without time zone,
    nazev character varying(255),
    nakoupene_kusy integer,
    nakupni_cena numeric,
    prodejni_cena numeric,
    id_kategorie integer,
    id_nakoupil integer,
    id_ucet integer,
    poznamka character varying(255)
);


ALTER TABLE public.polozky OWNER TO postgres;

--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE polozky; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.polozky IS 'zacinat s id u 3, 1 a 2 jsou rezervované pro lahve a prepravky';


--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN polozky.id_nakoupil; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.polozky.id_nakoupil IS 'je to id_vedouci ne konzument, hospdoar nutne nemusí být konzument, navíc nakup polozek s konzumací nesouvisi';


--
-- TOC entry 233 (class 1259 OID 16470)
-- Name: presuny_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.presuny_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.presuny_id_seq OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16471)
-- Name: presuny; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.presuny (
    id integer DEFAULT nextval('public.presuny_id_seq'::regclass) NOT NULL,
    datum_cas timestamp without time zone,
    id_pocatecni_ucet integer,
    id_koncovy_ucet integer,
    id_vyridil integer,
    castka numeric,
    poznamka character varying(255)
);


ALTER TABLE public.presuny OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16477)
-- Name: transakce_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transakce_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transakce_id_seq OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16478)
-- Name: transakce; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transakce (
    id integer DEFAULT nextval('public.transakce_id_seq'::regclass) NOT NULL,
    oznaceni character varying(255)
);


ALTER TABLE public.transakce OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16482)
-- Name: ucty_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ucty_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ucty_id_seq OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16483)
-- Name: ucty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ucty (
    id integer DEFAULT nextval('public.ucty_id_seq'::regclass) NOT NULL,
    nazev character varying(255)
);


ALTER TABLE public.ucty OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16487)
-- Name: vedouci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vedouci (
    id integer NOT NULL,
    prezdivka character varying(255),
    email character varying(255),
    funkce character varying(255),
    bankovni_ucet character varying(255)
);


ALTER TABLE public.vedouci OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16492)
-- Name: uzivatele_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.uzivatele_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.uzivatele_id_seq OWNER TO postgres;

--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 240
-- Name: uzivatele_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.uzivatele_id_seq OWNED BY public.vedouci.id;


--
-- TOC entry 241 (class 1259 OID 16493)
-- Name: zalohy_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zalohy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.zalohy_id_seq OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 16494)
-- Name: zalohy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zalohy (
    id integer DEFAULT nextval('public.zalohy_id_seq'::regclass) NOT NULL,
    id_konzument integer,
    datum_cas timestamp without time zone,
    castka numeric,
    id_ucet integer,
    id_vyridil integer,
    id_transakce integer,
    poznamka character varying(255)
);


ALTER TABLE public.zalohy OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16500)
-- Name: zpetna_vazba_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zpetna_vazba_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.zpetna_vazba_id_seq OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 16501)
-- Name: zpetna_vazba; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zpetna_vazba (
    id integer DEFAULT nextval('public.zpetna_vazba_id_seq'::regclass) NOT NULL,
    datum_cas timestamp without time zone,
    id_vedouci integer,
    funkce character varying(255),
    komentar text
);


ALTER TABLE public.zpetna_vazba OWNER TO postgres;

--
-- TOC entry 3310 (class 2604 OID 16507)
-- Name: vedouci id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vedouci ALTER COLUMN id SET DEFAULT nextval('public.uzivatele_id_seq'::regclass);


--
-- TOC entry 3510 (class 0 OID 16414)
-- Dependencies: 216
-- Data for Name: kategorie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kategorie (id, oznaceni, popis, zaloha_lahev, zaloha_prepravka, kusu_v_prepravce) FROM stdin;
1	Standard (3*20+100)	Nápoj v zálohovaném obalu se zálohovanou přepravkou 	3	100	20
2	Nezálohovaný nápoj	Nápoj v nezálohovaném obalu	0	0	0
3	Pochutiny	Veškeré pochutiny	0	0	0
4	Na objednávku	Veškeré zboží nakoupené na objednávku	0	0	0
6	Zalohovaný nápoj bez přepravky	Zalohovaný nápoj bez přepravky	3	0	0
\.


--
-- TOC entry 3512 (class 0 OID 16421)
-- Dependencies: 218
-- Data for Name: konzumace; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.konzumace (id, datum_cas, id_konzument, id_carkujici, id_polozka, kusu, pevna_cena, poznamka) FROM stdin;
\.


--
-- TOC entry 3514 (class 0 OID 16428)
-- Dependencies: 220
-- Data for Name: konzumenti; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.konzumenti (id, id_vedouci, cip, kredit, zkonzumovanych_kusu, nacarkovanych_kusu) FROM stdin;
\.


--
-- TOC entry 3516 (class 0 OID 16435)
-- Dependencies: 222
-- Data for Name: korekce; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.korekce (id, datum_cas, id_polozka, rozdil_kusu, id_zapsal, poznamka) FROM stdin;
\.


--
-- TOC entry 3518 (class 0 OID 16440)
-- Dependencies: 224
-- Data for Name: nabidka; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nabidka (id, id_polozka, zbyvajici_kusy, v_nabidce) FROM stdin;
\.


--
-- TOC entry 3520 (class 0 OID 16445)
-- Dependencies: 226
-- Data for Name: nakupy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nakupy (id, id_polozka, castka, id_ucet, id_transakce) FROM stdin;
\.


--
-- TOC entry 3522 (class 0 OID 16452)
-- Dependencies: 228
-- Data for Name: obaly; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.obaly (id, datum_cas, kusu, castka, druh, id_ucet, id_vyridil, poznamka) FROM stdin;
\.


--
-- TOC entry 3524 (class 0 OID 16459)
-- Dependencies: 230
-- Data for Name: obaly_sklipek; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.obaly_sklipek (id, nazev, kusu) FROM stdin;
2	Přepravky	0
1	Prázdné lahve	0
\.


--
-- TOC entry 3526 (class 0 OID 16464)
-- Dependencies: 232
-- Data for Name: polozky; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.polozky (id, datum_cas, nazev, nakoupene_kusy, nakupni_cena, prodejni_cena, id_kategorie, id_nakoupil, id_ucet, poznamka) FROM stdin;
\.


--
-- TOC entry 3528 (class 0 OID 16471)
-- Dependencies: 234
-- Data for Name: presuny; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.presuny (id, datum_cas, id_pocatecni_ucet, id_koncovy_ucet, id_vyridil, castka, poznamka) FROM stdin;
\.


--
-- TOC entry 3530 (class 0 OID 16478)
-- Dependencies: 236
-- Data for Name: transakce; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transakce (id, oznaceni) FROM stdin;
1	Nákup položek
2	Nákup lahví
3	Nákup přepravek
4	Vratka lahví
5	Vratka přepravek
6	Výběr zálohy
7	Vratka zálohy
\.


--
-- TOC entry 3532 (class 0 OID 16483)
-- Dependencies: 238
-- Data for Name: ucty; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ucty (id, nazev) FROM stdin;
1	Karta
2	Hotovost
\.


--
-- TOC entry 3533 (class 0 OID 16487)
-- Dependencies: 239
-- Data for Name: vedouci; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vedouci (id, prezdivka, email, funkce, bankovni_ucet) FROM stdin;
\.


--
-- TOC entry 3536 (class 0 OID 16494)
-- Dependencies: 242
-- Data for Name: zalohy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zalohy (id, id_konzument, datum_cas, castka, id_ucet, id_vyridil, id_transakce, poznamka) FROM stdin;
\.


--
-- TOC entry 3538 (class 0 OID 16501)
-- Dependencies: 244
-- Data for Name: zpetna_vazba; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zpetna_vazba (id, datum_cas, id_vedouci, funkce, komentar) FROM stdin;
\.


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 215
-- Name: kategorie_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kategorie_id_seq', 6, true);


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 217
-- Name: konzumace_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.konzumace_id_seq', 1, false);


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 219
-- Name: konzumenti_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.konzumenti_id_seq', 1, false);


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 221
-- Name: korekce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.korekce_id_seq', 1, false);


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 223
-- Name: nabidka_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nabidka_id_seq', 1, false);


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 225
-- Name: nakupy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nakupy_id_seq', 1, false);


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 227
-- Name: obaly_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.obaly_id_seq', 1, false);


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 229
-- Name: obaly_sklipek_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.obaly_sklipek_id_seq', 2, true);


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 231
-- Name: polozky_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.polozky_id_seq', 3, false);


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 233
-- Name: presuny_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.presuny_id_seq', 1, false);


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 235
-- Name: transakce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transakce_id_seq', 7, true);


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 237
-- Name: ucty_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ucty_id_seq', 2, true);


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 240
-- Name: uzivatele_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.uzivatele_id_seq', 1, false);


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 241
-- Name: zalohy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zalohy_id_seq', 1, false);


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 243
-- Name: zpetna_vazba_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zpetna_vazba_id_seq', 1, false);


--
-- TOC entry 3314 (class 2606 OID 16509)
-- Name: kategorie kategorie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategorie
    ADD CONSTRAINT kategorie_pkey PRIMARY KEY (id);


--
-- TOC entry 3316 (class 2606 OID 16511)
-- Name: konzumace konzumace_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.konzumace
    ADD CONSTRAINT konzumace_pkey PRIMARY KEY (id);


--
-- TOC entry 3318 (class 2606 OID 16513)
-- Name: konzumenti konzumenti_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.konzumenti
    ADD CONSTRAINT konzumenti_pkey PRIMARY KEY (id);


--
-- TOC entry 3320 (class 2606 OID 16515)
-- Name: korekce korekce_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.korekce
    ADD CONSTRAINT korekce_pkey PRIMARY KEY (id);


--
-- TOC entry 3322 (class 2606 OID 16517)
-- Name: nabidka nabidka_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nabidka
    ADD CONSTRAINT nabidka_pkey PRIMARY KEY (id);


--
-- TOC entry 3324 (class 2606 OID 16519)
-- Name: nakupy nakupy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nakupy
    ADD CONSTRAINT nakupy_pkey PRIMARY KEY (id);


--
-- TOC entry 3326 (class 2606 OID 16521)
-- Name: obaly obaly_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.obaly
    ADD CONSTRAINT obaly_pkey PRIMARY KEY (id);


--
-- TOC entry 3328 (class 2606 OID 16523)
-- Name: obaly_sklipek obaly_sklipek_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.obaly_sklipek
    ADD CONSTRAINT obaly_sklipek_pkey PRIMARY KEY (id);


--
-- TOC entry 3330 (class 2606 OID 16525)
-- Name: polozky polozky_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polozky
    ADD CONSTRAINT polozky_pkey PRIMARY KEY (id);


--
-- TOC entry 3332 (class 2606 OID 16527)
-- Name: presuny presuny_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.presuny
    ADD CONSTRAINT presuny_pkey PRIMARY KEY (id);


--
-- TOC entry 3334 (class 2606 OID 16529)
-- Name: transakce transakce_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transakce
    ADD CONSTRAINT transakce_pkey PRIMARY KEY (id);


--
-- TOC entry 3336 (class 2606 OID 16531)
-- Name: ucty ucty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ucty
    ADD CONSTRAINT ucty_pkey PRIMARY KEY (id);


--
-- TOC entry 3338 (class 2606 OID 16533)
-- Name: vedouci uzivatele_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vedouci
    ADD CONSTRAINT uzivatele_pkey PRIMARY KEY (id);


--
-- TOC entry 3340 (class 2606 OID 16535)
-- Name: zalohy zalohy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zalohy
    ADD CONSTRAINT zalohy_pkey PRIMARY KEY (id);


--
-- TOC entry 3342 (class 2606 OID 16537)
-- Name: zpetna_vazba zpetna_vazba_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zpetna_vazba
    ADD CONSTRAINT zpetna_vazba_pkey PRIMARY KEY (id);


--
-- TOC entry 3358 (class 2620 OID 16538)
-- Name: polozky trg_insert_into_nabidka; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_insert_into_nabidka AFTER INSERT ON public.polozky FOR EACH ROW EXECUTE FUNCTION public.insert_into_nabidka();


--
-- TOC entry 3359 (class 2620 OID 16539)
-- Name: polozky trg_insert_into_nakupy; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_insert_into_nakupy AFTER INSERT ON public.polozky FOR EACH ROW EXECUTE FUNCTION public.insert_into_nakupy();


--
-- TOC entry 3353 (class 2620 OID 16540)
-- Name: obaly trg_insert_or_update_obaly; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_insert_or_update_obaly BEFORE INSERT OR UPDATE ON public.obaly FOR EACH ROW EXECUTE FUNCTION public.insert_or_update_obaly();


--
-- TOC entry 3360 (class 2620 OID 16541)
-- Name: polozky trg_recalculate_prepravky_from_polozky; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_recalculate_prepravky_from_polozky AFTER UPDATE ON public.polozky FOR EACH ROW WHEN (((new.id_kategorie = 1) AND (old.nakoupene_kusy IS DISTINCT FROM new.nakoupene_kusy))) EXECUTE FUNCTION public.recalculate_prepravky_from_polozky();


--
-- TOC entry 3343 (class 2620 OID 16542)
-- Name: konzumace trg_update_konzumenti_from_konzumace; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_konzumenti_from_konzumace AFTER UPDATE ON public.konzumace FOR EACH ROW EXECUTE FUNCTION public.update_konzumenti_from_konzumace();


--
-- TOC entry 3364 (class 2620 OID 16543)
-- Name: zalohy trg_update_kredit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_kredit AFTER UPDATE ON public.zalohy FOR EACH ROW EXECUTE FUNCTION public.update_kredit();


--
-- TOC entry 3365 (class 2620 OID 16544)
-- Name: zalohy trg_update_kredit_after_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_kredit_after_insert AFTER INSERT ON public.zalohy FOR EACH ROW EXECUTE FUNCTION public.update_kredit_after_insert();


--
-- TOC entry 3344 (class 2620 OID 16545)
-- Name: konzumace trg_update_kusu_from_konzumace; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_kusu_from_konzumace AFTER INSERT ON public.konzumace FOR EACH ROW EXECUTE FUNCTION public.update_kusu_from_konzumace();


--
-- TOC entry 3345 (class 2620 OID 16546)
-- Name: konzumace trg_update_kusu_from_konzumace_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_kusu_from_konzumace_update AFTER UPDATE ON public.konzumace FOR EACH ROW EXECUTE FUNCTION public.update_kusu_from_konzumace_update();


--
-- TOC entry 3354 (class 2620 OID 16547)
-- Name: obaly trg_update_kusu_from_obaly_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_kusu_from_obaly_insert AFTER INSERT ON public.obaly FOR EACH ROW EXECUTE FUNCTION public.update_kusu_from_obaly_insert();


--
-- TOC entry 3355 (class 2620 OID 16548)
-- Name: obaly trg_update_kusu_from_obaly_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_kusu_from_obaly_update AFTER UPDATE ON public.obaly FOR EACH ROW EXECUTE FUNCTION public.update_kusu_from_obaly_update();


--
-- TOC entry 3346 (class 2620 OID 16549)
-- Name: konzumace trg_update_nabidka_from_konzumace; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_nabidka_from_konzumace AFTER UPDATE OF kusu ON public.konzumace FOR EACH ROW EXECUTE FUNCTION public.update_nabidka_from_konzumace();


--
-- TOC entry 3347 (class 2620 OID 24829)
-- Name: konzumace trg_update_nabidka_from_konzumace_update_polozka; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_nabidka_from_konzumace_update_polozka AFTER UPDATE OF id_polozka ON public.konzumace FOR EACH ROW EXECUTE FUNCTION public.trg_update_nabidka_from_konzumace_update_polozka();


--
-- TOC entry 3361 (class 2620 OID 16550)
-- Name: polozky trg_update_nabidka_from_polozky; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_nabidka_from_polozky AFTER UPDATE OF nakoupene_kusy ON public.polozky FOR EACH ROW EXECUTE FUNCTION public.update_nabidka_from_polozky();


--
-- TOC entry 3362 (class 2620 OID 16551)
-- Name: polozky trg_update_nakupy_from_polozky; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_nakupy_from_polozky AFTER UPDATE ON public.polozky FOR EACH ROW EXECUTE FUNCTION public.update_nakupy_from_polozky();


--
-- TOC entry 3350 (class 2620 OID 16552)
-- Name: korekce trg_update_obaly_sklipek_from_korekce; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_obaly_sklipek_from_korekce AFTER INSERT ON public.korekce FOR EACH ROW EXECUTE FUNCTION public.update_obaly_sklipek_from_korekce();


--
-- TOC entry 3356 (class 2620 OID 16553)
-- Name: obaly trg_update_prepravky_after_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_prepravky_after_insert AFTER INSERT ON public.obaly FOR EACH ROW WHEN (((new.druh)::text = 'Přepravky'::text)) EXECUTE FUNCTION public.update_prepravky_after_insert();


--
-- TOC entry 3357 (class 2620 OID 16554)
-- Name: obaly trg_update_prepravky_after_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_prepravky_after_update AFTER UPDATE ON public.obaly FOR EACH ROW WHEN (((new.druh)::text = 'Přepravky'::text)) EXECUTE FUNCTION public.update_prepravky_after_update();


--
-- TOC entry 3363 (class 2620 OID 16555)
-- Name: polozky trg_update_prepravky_from_polozky; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_prepravky_from_polozky AFTER INSERT ON public.polozky FOR EACH ROW WHEN ((new.id_kategorie = 1)) EXECUTE FUNCTION public.update_prepravky_from_polozky();


--
-- TOC entry 3352 (class 2620 OID 16556)
-- Name: nabidka trg_update_v_nabidce; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_v_nabidce AFTER UPDATE OF zbyvajici_kusy ON public.nabidka FOR EACH ROW EXECUTE FUNCTION public.update_v_nabidce();


--
-- TOC entry 3348 (class 2620 OID 16557)
-- Name: konzumace trg_update_zbyvajici_kusy; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_zbyvajici_kusy AFTER INSERT ON public.konzumace FOR EACH ROW EXECUTE FUNCTION public.update_zbyvajici_kusy();


--
-- TOC entry 3351 (class 2620 OID 16558)
-- Name: korekce trg_update_zbyvajici_kusy_from_korekce; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_zbyvajici_kusy_from_korekce AFTER INSERT ON public.korekce FOR EACH ROW EXECUTE FUNCTION public.update_zbyvajici_kusy_from_korekce();


--
-- TOC entry 3349 (class 2620 OID 16559)
-- Name: konzumace trg_update_zkonzumovane_nacarkovane_kusy; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_zkonzumovane_nacarkovane_kusy AFTER INSERT ON public.konzumace FOR EACH ROW EXECUTE FUNCTION public.update_zkonzumovane_nacarkovane_kusy();


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO sikula;


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 215
-- Name: SEQUENCE kategorie_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.kategorie_id_seq TO sikula;


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE kategorie; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.kategorie TO sikula;


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 217
-- Name: SEQUENCE konzumace_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.konzumace_id_seq TO sikula;


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE konzumace; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.konzumace TO sikula;


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 219
-- Name: SEQUENCE konzumenti_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.konzumenti_id_seq TO sikula;


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE konzumenti; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.konzumenti TO sikula;


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 221
-- Name: SEQUENCE korekce_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.korekce_id_seq TO sikula;


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE korekce; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.korekce TO sikula;


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 223
-- Name: SEQUENCE nabidka_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.nabidka_id_seq TO sikula;


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE nabidka; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.nabidka TO sikula;


--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE nakupy_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.nakupy_id_seq TO sikula;


--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE nakupy; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.nakupy TO sikula;


--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE obaly_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.obaly_id_seq TO sikula;


--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE obaly; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.obaly TO sikula;


--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 229
-- Name: SEQUENCE obaly_sklipek_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.obaly_sklipek_id_seq TO sikula;


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE obaly_sklipek; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.obaly_sklipek TO sikula;


--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 231
-- Name: SEQUENCE polozky_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.polozky_id_seq TO sikula;


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE polozky; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.polozky TO sikula;


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 233
-- Name: SEQUENCE presuny_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.presuny_id_seq TO sikula;


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE presuny; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.presuny TO sikula;


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 235
-- Name: SEQUENCE transakce_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.transakce_id_seq TO sikula;


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE transakce; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.transakce TO sikula;


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 237
-- Name: SEQUENCE ucty_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.ucty_id_seq TO sikula;


--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE ucty; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.ucty TO sikula;


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE vedouci; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.vedouci TO sikula;


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 240
-- Name: SEQUENCE uzivatele_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.uzivatele_id_seq TO sikula;


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 241
-- Name: SEQUENCE zalohy_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.zalohy_id_seq TO sikula;


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE zalohy; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.zalohy TO sikula;


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 243
-- Name: SEQUENCE zpetna_vazba_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.zpetna_vazba_id_seq TO sikula;


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE zpetna_vazba; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.zpetna_vazba TO sikula;


-- Completed on 2024-08-27 17:17:38

--
-- PostgreSQL database dump complete
--

-- Completed on 2024-08-27 17:17:38

--
-- PostgreSQL database cluster dump complete
--

