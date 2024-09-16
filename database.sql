DROP TABLE source;
DROP TABLE country;
DROP TABLE country_source;
DROP TABLE state;
DROP TABLE world_vaccination_record;
DROP TABLE us_state_vaccination_record;
DROP TABLE vaccinations_by_manufacturer;
DROP TABLE vaccinations_by_age;

-- Create the source table
CREATE TABLE source (
    source_id INTEGER PRIMARY KEY,
    source_name TEXT NOT NULL,
    source_url TEXT
);

-- Create the country table
CREATE TABLE country (
    iso_code TEXT PRIMARY KEY,
    country_name TEXT NOT NULL
);

-- Create the country_source table
CREATE TABLE country_source (
    iso_code TEXT NOT NULL,
    source_id INTEGER NOT NULL,
    PRIMARY KEY (iso_code),
    FOREIGN KEY (iso_code) REFERENCES country(iso_code) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (source_id) REFERENCES source(source_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create the state table
CREATE TABLE state (
    state_name TEXT PRIMARY KEY,
    iso_code TEXT NOT NULL,
    FOREIGN KEY (iso_code) REFERENCES country(iso_code) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create the world_vaccination_record table
CREATE TABLE world_vaccination_record (
    date DATE NOT NULL,
    iso_code TEXT NOT NULL,
    people_vaccinated INTEGER,
    people_fully_vaccinated INTEGER,
    total_boosters INTEGER,
    daily_people_vaccinated INTEGER,
    daily_vaccinations_raw INTEGER,
    daily_vaccinations INTEGER,
    PRIMARY KEY (date, iso_code),
    FOREIGN KEY (iso_code) REFERENCES country(iso_code) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create the us_state_vaccination_record table
CREATE TABLE us_state_vaccination_record (
    date DATE NOT NULL,
    state_name TEXT NOT NULL,
    people_vaccinated INTEGER,
    people_fully_vaccinated INTEGER,
    total_boosters INTEGER,
    daily_people_vaccinated INTEGER,
    total_distributed INTEGER,
    daily_vaccinations_raw INTEGER,
    daily_vaccinations INTEGER,
    PRIMARY KEY (date, state_name),
    FOREIGN KEY (state_name) REFERENCES state(state_name) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create the vaccinations_by_manufacturer table
CREATE TABLE vaccinations_by_manufacturer (
    date DATE NOT NULL,
    vaccine TEXT NOT NULL,
    iso_code TEXT NOT NULL,
    total_vaccinations INTEGER,
    PRIMARY KEY (date, vaccine, iso_code),
    FOREIGN KEY (iso_code) REFERENCES country(iso_code) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create the vaccinations_by_age table
CREATE TABLE vaccinations_by_age (
    date DATE NOT NULL,
    age_group TEXT NOT NULL,
    iso_code TEXT NOT NULL,
    people_vaccinated_per_hundred REAL,
    people_fully_vaccinated_per_hundred REAL,
    people_with_booster_per_hundred REAL,
    PRIMARY KEY (date, age_group, iso_code),
    FOREIGN KEY (iso_code) REFERENCES country(iso_code) ON DELETE CASCADE ON UPDATE CASCADE
);
