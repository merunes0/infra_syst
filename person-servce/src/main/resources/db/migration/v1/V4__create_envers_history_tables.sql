CREATE SCHEMA IF NOT EXISTS person_history;

CREATE TABLE IF NOT EXISTS person_history.revinfo_seq (
                                                          revision INT PRIMARY KEY,
                                                          revision_timestamp BIGINT
);

CREATE TABLE IF NOT EXISTS person_history.addresses_history (
                                                                id INT,
                                                                revision INT NOT NULL,
                                                                revision_type SMALLINT,
                                                                active BOOLEAN,
                                                                created TIMESTAMP,
                                                                updated TIMESTAMP,
                                                                city VARCHAR(255),
    zip_code VARCHAR(20),
    address VARCHAR(255),
    country_id INT,
    PRIMARY KEY (id, revision),
    CONSTRAINT fk_addresses_history_revinfo FOREIGN KEY (revision) REFERENCES person_history.revinfo_seq(revision)
    );

CREATE TABLE IF NOT EXISTS person_history.individuals_history (
                                                                  id UUID,
                                                                  revision INT NOT NULL,
                                                                  revision_type SMALLINT,
                                                                  active BOOLEAN,
                                                                  created TIMESTAMP,
                                                                  updated TIMESTAMP,
                                                                  user_id UUID,
                                                                  address_id INT,
                                                                  PRIMARY KEY (id, revision),
    CONSTRAINT fk_individuals_history_revinfo FOREIGN KEY (revision) REFERENCES person_history.revinfo_seq(revision)
    );

CREATE TABLE IF NOT EXISTS person_history.users_history (
                                                            id UUID,
                                                            revision INT NOT NULL,
                                                            revision_type SMALLINT,
                                                            active BOOLEAN,
                                                            created TIMESTAMP,
                                                            updated TIMESTAMP,
                                                            email VARCHAR(255),
    PRIMARY KEY (id, revision),
    CONSTRAINT fk_users_history_revinfo FOREIGN KEY (revision) REFERENCES person_history.revinfo_seq(revision)
    );