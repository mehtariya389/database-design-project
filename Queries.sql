-- D1
WITH DailyAverage AS (
    SELECT
        date,
        AVG(daily_vaccinations) AS avg_daily_vaccinations
    FROM
        world_vaccination_record
    WHERE
        daily_vaccinations IS NOT NULL
    GROUP BY
        date
)

SELECT
    c.country_name AS "Country Name (CN)",
    COALESCE(wvr.people_vaccinated, 0) + COALESCE(wvr.people_fully_vaccinated, 0) + COALESCE(wvr.total_boosters, 0) AS "Total Vaccinations (administered to date)",
    wvr.daily_vaccinations AS "Daily Vaccinations",
    wvr.date AS "Date"
FROM
    world_vaccination_record AS wvr
JOIN
    country AS c
ON
    wvr.iso_code = c.iso_code
JOIN
    DailyAverage AS da
ON
    wvr.date = da.date
WHERE
    wvr.daily_vaccinations > da.avg_daily_vaccinations
    AND wvr.daily_vaccinations IS NOT NULL
ORDER BY
    c.country_name,
    wvr.date;

-- D2
WITH CumulativeData AS (
    SELECT
        country.iso_code,
        country.country_name,
        SUM(
            COALESCE(world_vaccination_record.people_vaccinated, 0)
            + COALESCE(world_vaccination_record.people_fully_vaccinated, 0)
            + COALESCE(world_vaccination_record.total_boosters, 0)
        ) AS cumulative_doses
    FROM
        country
    JOIN
        world_vaccination_record
    ON
        country.iso_code = world_vaccination_record.iso_code
    GROUP BY
        country.iso_code,
        country.country_name
),
AverageCumulative AS (
    SELECT
        AVG(cumulative_doses) AS avg_cumulative
    FROM
        CumulativeData
    WHERE
        cumulative_doses > 0  
)

SELECT
    country_name AS "Country",
    cumulative_doses AS "Cumulative Doses"
FROM
    CumulativeData
WHERE
    cumulative_doses > (SELECT avg_cumulative FROM AverageCumulative)
ORDER BY
    cumulative_doses DESC;
    
-- D3
SELECT
    c.country_name AS "Country",
    vbm.vaccine AS "Vaccine Type"
FROM
    country AS c
JOIN
    vaccinations_by_manufacturer AS vbm
ON
    c.iso_code = vbm.iso_code
GROUP BY
    c.country_name,
    vbm.vaccine
ORDER BY
    c.country_name,
    vbm.vaccine;

-- D4
WITH VaccinationTotals AS (
    SELECT
        country.iso_code,
        country_source.source_id,
        MAX(
            COALESCE(world_vaccination_record.people_vaccinated, 0)
            + COALESCE(world_vaccination_record.people_fully_vaccinated, 0)
            + COALESCE(world_vaccination_record.total_boosters, 0)
        ) AS biggest_total
    FROM
        country
    JOIN
        country_source
    ON
        country.iso_code = country_source.iso_code
    JOIN
        world_vaccination_record
    ON
        country.iso_code = world_vaccination_record.iso_code
    GROUP BY
        country.iso_code,
        country_source.source_id
)

SELECT
    c.country_name AS "Country",
    s.source_name || ' (' || s.source_url || ')' AS "Source Name (URL)",
    vt.biggest_total AS "Biggest total Administered Vaccines"
FROM
    VaccinationTotals AS vt
JOIN
    country AS c
ON
    vt.iso_code = c.iso_code
JOIN
    source AS s
ON
    vt.source_id = s.source_id
ORDER BY
    s.source_name,
    s.source_url,
    c.country_name;

-- D5
-- Data is grouped in full weeks from Monday to Sunday therefore we chose these dates 2021-01-04 and 2022-12-26
WITH DateRanges AS (
    -- Generate a list of the first day of each week in 2021 and 2022
    SELECT date('2021-01-04') AS week_start
    UNION ALL
    SELECT date(week_start, '+7 day')
    FROM DateRanges
    WHERE week_start < date('2022-12-26')
),
WeeklyVaccinations AS (
    -- Summarize the total number of people fully vaccinated per country per week
    SELECT
        dr.week_start,
        country.country_name,
        SUM(world_vaccination_record.people_fully_vaccinated) AS weekly_fully_vaccinated
    FROM
        DateRanges dr
    JOIN
        world_vaccination_record
    ON
        world_vaccination_record.date BETWEEN dr.week_start AND date(dr.week_start, '+6 day')
    JOIN
        country
    ON
        world_vaccination_record.iso_code = country.iso_code
    WHERE
        country.country_name IN ('Australia', 'Germany', 'England', 'France')
    GROUP BY
        dr.week_start,
        country.country_name
)

SELECT
    week_start || ' to ' || date(week_start, '+6 day') AS "Date Range (Weeks)",
    (SELECT weekly_fully_vaccinated FROM WeeklyVaccinations WHERE week_start = dr.week_start AND country_name = 'Australia') AS Australia,
    (SELECT weekly_fully_vaccinated FROM WeeklyVaccinations WHERE week_start = dr.week_start AND country_name = 'Germany') AS Germany,
    (SELECT weekly_fully_vaccinated FROM WeeklyVaccinations WHERE week_start = dr.week_start AND country_name = 'England') AS England,
    (SELECT weekly_fully_vaccinated FROM WeeklyVaccinations WHERE week_start = dr.week_start AND country_name = 'France') AS France
FROM
    DateRanges dr
ORDER BY
    dr.week_start;
