--
-- PostgreSQL database dump
--

SET statement_timeout = 5000;
SET client_encoding = 'UTF8';
SET check_function_bodies = true;
SET client_min_messages = warning;

CREATE LANGUAGE plpgsql;
--ALTER LANGUAGE OWNER TO $owner;

CREATE OR REPLACE FUNCTION public.audit() RETURNS trigger
    LANGUAGE plpgsql
    IMMUTABLE
    AS $$
BEGIN
    NEW.modified = current_timestamp; -- set modification timestamp
    IF (TG_OP = 'UPDATE') THEN
        NEW.created = OLD.created; -- write only
    END IF;
    RETURN NEW;
END
$$;

--ALTER FUNCTION public.audit() OWNER TO $owner;

--============================================================================
-- APPBASE
--============================================================================

CREATE SCHEMA appbase;
--ALTER SCHEMA appbase OWNER TO $owner;
SET search_path = appbase;

CREATE TYPE appbase.gender AS ENUM (
    'M',
    'F'
);

--ALTER TYPE appbase.gender OWNER TO $owner;

------------------------------------------------------------------------------
-- BASE
------------------------------------------------------------------------------

CREATE TABLE base (
    id SERIAL PRIMARY KEY,
    created TIMESTAMP NOT NULL DEFAULT NOW(),
    modified TIMESTAMP NOT NULL,
    modified_by INTEGER NOT NULL
);

--ALTER TABLE base OWNER TO $owner

------------------------------------------------------------------------------
-- AGENT
------------------------------------------------------------------------------

CREATE TABLE agent LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    username CHARACTER VARYING NOT NULL,
    
    timezone CHARACTER VARYING,
    language CHARACTER VARYING,
    
    systemuser BOOLEAN NOT NULL DEFAULT FALSE,
    person INTEGER NOT NULL REFERENCES person(id),
    
    storage CHARACTER VARYING
);

--ALTER TABLE agent OWNER TO $owner

CREATE UNIQUE INDEX agent_username_unique ON agent USING btree (username) WHERE deleted = FALSE;

ALTER TABLE agent ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON agent
    FOR EACH ROW
    EXECUTE PROCEDURE public.audit();
    

------------------------------------------------------------------------------
-- PERSON
------------------------------------------------------------------------------

CREATE TABLE person LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    firstname CHARACTER VARYING,
    lastname CHARACTER VARYING,
    
    title CHARACTER VARYING,
    birthday DATE,
    gender GENDER,
    organization CHARACTER VARYING,
    
    address_line1 CHARACTER VARYING,
    address_line2 CHARACTER VARYING,
    address_city CHARACTER VARYING,
    address_state CHARACTER VARYING,
    address_zip CHARACTER VARYING,
    address_country CHAR(2)
    
    storage CHARACTER VARYING
);

--ALTER TABLE person OWNER TO $owner

ALTER TABLE person ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON person
    FOR EACH ROW
    EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- AGENT AUTHENTICATION
------------------------------------------------------------------------------

CREATE TABLE agent_authentication LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    agent INTEGER NOT NULL REFERENCES agent(id),
    type CHARACTER VARYING NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    valid_to DATE,
    storage CHARACTER VARYING NOT NULL
);

--ALTER TABLE agent_authentication OWNER TO $owner

ALTER TABLE agent_authentication ADD FOREIGN KEY (modified_by) REFERENCES agent;
CREATE INDEX agent_authentication_agent_key ON agent_authentication(agent);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON agent_authentication
    FOR EACH ROW
    EXECUTE PROCEDURE public.audit();
    
------------------------------------------------------------------------------
-- AGENT AUTH TOKEN
------------------------------------------------------------------------------

CREATE TABLE agent_authtoken LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    agent INTEGER NOT NULL REFERENCES agent(id),
    type CHARACTER VARYING NOT NULL,
    token CHARACTER VARYING NOT NULL,
    valid_to DATE,
    onetime BOOLEAN NOT NULL DEFAULT FALSE,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

--ALTER TABLE agent_authtoken OWNER TO $owner

ALTER TABLE agent_authtoken ADD FOREIGN KEY (modified_by) REFERENCES agent;
CREATE INDEX agent_authtoken_agent_key ON agent_authtoken(agent);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON agent_authtoken
    FOR EACH ROW
     EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- GROUPS
------------------------------------------------------------------------------

CREATE TABLE agentgroup LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    name CHARACTER VARYING NOT NULL,
    memo CHARACTER VARYING,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

--ALTER TABLE agentgroup OWNER TO $owner

ALTER TABLE agentgroup ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE UNIQUE INDEX agentgroup_name_unique ON agentgroup USING btree (name);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON agentgroup
    FOR EACH ROW
     EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- AGENT <-> GROUP
------------------------------------------------------------------------------

CREATE TABLE agent_agentgroup LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    agent INTEGER REFERENCES agent(id) NOT NULL,
    agentgroup INTEGER REFERENCES agentgroup(id) NOT NULL
);

--ALTER TABLE agent_agentgroup OWNER TO $owner

ALTER TABLE agent_agentgroup ADD FOREIGN KEY (modified_by) REFERENCES agent;
CREATE INDEX agent_agentgroup_agent_key ON agent_agentgroup(agent);
CREATE INDEX agent_agentgroup_agentgroup_key ON agent_agentgroup(agentgroup);

CREATE UNIQUE INDEX agent_agentgroup_agent_agentgroup_unique ON agent_agentgroup USING btree (agent,agentgroup);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON agent_agentgroup
    FOR EACH ROW
     EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- ROLE
------------------------------------------------------------------------------

CREATE TABLE role LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    name CHARACTER VARYING NOT NULL,
    memo CHARACTER VARYING,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

--ALTER TABLE role OWNER TO $owner

ALTER TABLE role ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE UNIQUE INDEX role_name_unique ON role USING btree (name);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON role
    FOR EACH ROW
     EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- AGENT<->ROLE
------------------------------------------------------------------------------

CREATE TABLE agent_role LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    agent INTEGER REFERENCES agent(id) NOT NULL,
    role INTEGER REFERENCES role(id) NOT NULL
);

--ALTER TABLE agent_role OWNER TO $owner

ALTER TABLE agent_role ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE UNIQUE INDEX agent_role_agent_role_unique ON agent_role USING btree (agent,role);
CREATE INDEX agent_role_agent_key ON agent_role(agent);
CREATE INDEX agent_role_role_key ON agent_role(role);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON agent_role
    FOR EACH ROW
     EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- AGENTGROUP<->ROLE
------------------------------------------------------------------------------

CREATE TABLE agentgroup_role LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    agentgroup INTEGER REFERENCES agentgroup(id) NOT NULL,
    role INTEGER REFERENCES role(id) NOT NULL
);

--ALTER TABLE agentgroup_role OWNER TO $owner

ALTER TABLE agentgroup_role ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE UNIQUE INDEX agentgroup_role_agentgroup_role_unique ON agentgroup_role USING btree (agentgroup,role);
CREATE INDEX agent_role_agentgroup_key ON agentgroup_role(agentgroup);
CREATE INDEX agent_role_role_key ON agentgroup_role(role);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON agentgroup_role
    FOR EACH ROW
     EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- SESSION
------------------------------------------------------------------------------

CREATE TABLE session LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    agent INTEGER REFERENCES agent(id) NOT NULL,
    agent_authentication INTEGER REFERENCES agent_authentication(id) NOT NULL,

    sessionid CHARACTER VARYING NOT NULL,
    start_timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    end_timestamp TIMESTAMP,
    
    storage CHARACTER VARYING,
    client_device CHARACTER VARYING NOT NULL,
    client_address CHARACTER VARYING NOT NULL
);

--ALTER TABLE session OWNER TO $owner

ALTER TABLE session ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE UNIQUE INDEX session_sessionid_unique ON session USING btree(sessionid);
CREATE INDEX session_agent_key ON session(agent);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON session
    FOR EACH ROW
     EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- AGENT LOG
------------------------------------------------------------------------------

CREATE TABLE agent_log LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    agent INTEGER REFERENCES agent(id) NOT NULL,
    type CHARACTER VARYING NOT NULL,
    message CHARACTER VARYING NOT NULL,
    storage CHARACTER VARYING
);

--ALTER TABLE agent_log OWNER TO $owner

ALTER TABLE agent_log ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE INDEX agent_log_agent_key ON agent_log(agent);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON agent_log
    FOR EACH ROW
    EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- LOCKS
------------------------------------------------------------------------------

CREATE TABLE lock LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    session INTEGER REFERENCES session(id) NOT NULL,
    class CHARACTER VARYING NOT NULL,
    element INTEGER NOT NULL,
    maxage TIMESTAMP
);

--ALTER TABLE lock OWNER TO $owner

ALTER TABLE lock ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE UNIQUE INDEX lock_class_element_unique ON lock USING btree(class,element);

CREATE INDEX lock_session_key ON lock(session);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON lock
    FOR EACH ROW
    EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- AGENT CONTACT
------------------------------------------------------------------------------

CREATE TABLE agent_contact LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    agent INTEGER REFERENCES agent(id) NOT NULL,
    type CHARACTER VARYING NOT NULL,
    primary BOOLEAN DEFAULT FALSE NOT NULL,
    contact CHARACTER VARYING NOT NULL,
    memo CHARACTER VARYING
);

--ALTER TABLE agent_contact OWNER TO $owner

ALTER TABLE agent_contact ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE INDEX agent_contact_agent_key ON agent_contact(agent);

CREATE UNIQUE INDEX agent_contact_agent_type_unique ON lock USING btree(agent,type) WHERE primary = TRUE;

CREATE OR REPLACE FUNCTION agent_contact_primary() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.primary = TRUE THEN
        IF (TG_OP = 'UPDATE') THEN
            UPDATE agent_contact SET primary = FALSE WHERE primary = TRUE AND agent = NEW.agent AND type = NEW.type AND id <> NEW.id;
        ELSEIF (TG_OP = 'INSERT') THEN
            UPDATE agent_contact SET primary = FALSE WHERE primary = TRUE AND agent = NEW.agent AND type = NEW.type;
        END IF;
    END IF;
    RETURN NEW;
END
$$;

--ALTER FUNCTION agent_contact_primary() OWNER TO $owner;

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON agent_contact
    FOR EACH ROW
     EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- DASHBOARD
------------------------------------------------------------------------------

CREATE TABLE dashboard LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    name CHARACTER VARYING NOT NULL,
    memo CHARACTER VARYING,
    public BOOLEAN NOT NULL DEFAULT FALSE,
    agent INTEGER REFERENCES agent(id) NOT NULL
);

--ALTER TABLE dashboard OWNER TO $owner

ALTER TABLE dashboard ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE INDEX dashboard_agent_key ON dashboard(agent);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON dashboard
    FOR EACH ROW
     EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- DASHBOARD <-> WIDGET
------------------------------------------------------------------------------

CREATE TABLE dashboard_widget LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    dashboard INTEGER REFERENCES agent(id) NOT NULL,
    position_block CHARACTER VARYING NOT NULL,
    position_index INTEGER NOT NULL,
    
    type CHARACTER VARYING NOT NULL,
    params CHARACTER VARYING,
    refresh INTEGER
);

--ALTER TABLE dashboard OWNER TO $owner

--CREATE UNIQUE INDEX dashboard_widget_unique ON dashboard_widget USING btree(position_index,position_block,dashboard) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE dashboard_widget ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE INDEX dashboard_widget_dashboard_key ON dashboard_widget(dashboard);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON dashboard_widget
    FOR EACH ROW
    EXECUTE PROCEDURE public.audit();

--============================================================================
-- L10N
--============================================================================

CREATE SCHEMA l10n;
--ALTER SCHEMA l10n OWNER TO $owner;
SET search_path = l10n;

------------------------------------------------------------------------------
-- MSGID
------------------------------------------------------------------------------

CREATE TABLE msgid LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    msgid CHARACTER VARYING NOT NULL,
    memo CHARACTER VARYING
);

--ALTER TABLE msgid OWNER TO $owner

ALTER TABLE msgid ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE UNIQUE INDEX msgid_msgid_unique ON msgid USING btree(UPPER(msgid));

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON msgid
    FOR EACH ROW
    EXECUTE PROCEDURE public.audit();

------------------------------------------------------------------------------
-- TRANSLATION MESSAGE
------------------------------------------------------------------------------

CREATE TABLE msgstr LIKE base INCLUDING INDEXES,DEFAULTS,CONSTRAINTS (
    msgid INTEGER NOT NULL REFERENCES msgid(id),
    msgstr CHARACTER VARYING,
    language CHARACTER VARYING
);

--ALTER TABLE msgstr OWNER TO $owner

ALTER TABLE msgstr ADD FOREIGN KEY (modified_by) REFERENCES agent;

CREATE UNIQUE INDEX msgstr_msgid_language_unique ON translation USING btree(UPPER(msgid),language);

CREATE TRIGGER trigger_audit
    BEFORE UPDATE OR INSERT ON msgstr
    FOR EACH ROW
    EXECUTE PROCEDURE public.audit();