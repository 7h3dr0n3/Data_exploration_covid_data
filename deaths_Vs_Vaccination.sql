/*checking datasets covidDeaths and covidVaccinations*/

SELECT * FROM PortfolioProject..covidDeaths
WHERE continent is not null
ORDER BY 3, 4;
--SELECT * FROM PortfolioProject..covidVaccinations
--ORDER BY 3, 4;

/*select and check data we are going to use from covidDeaths*/

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..covidDeaths
--ORDER BY 1, 2

/*SELECT and check total Deaths vs Total cases and Death percentage*/

--SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS INT) * 100.0 / CAST(total_cases AS INT)) AS deathPercentage
--FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%India%' 
--ORDER BY 1, 2

/*select and check total cases vs population and find out the infected percentage*/

--SELECT location, date, total_cases, population, (CAST(total_cases AS INT) * 100.0 / CAST(population AS INT)) AS infectedPercentage
--FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%India%' 
--ORDER BY 1, 2

/*select and compare the highest percentage of the populdation infection of all countries using total cases vs population*/

--SELECT location, population, MAX(total_cases) as highest_Infected_Count,
--MAX((CAST(total_cases AS numeric) / CAST(population AS numeric)) * 100) AS percent_Population_Infected
--FROM PortfolioProject..covidDeaths
----WHERE location LIKE '%India%' 
--GROUP BY location, population
--ORDER BY percent_Population_Infected desc

/*show highest death count per population of each countries*/

SELECT location, MAX(CAST(total_deaths as numeric)) AS total_Death_Count
FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%India%' 
WHERE continent is not null
GROUP BY location
ORDER BY total_Death_Count desc

/*show total death count of above by continents*/

SELECT continent, MAX(CAST(total_deaths as numeric)) AS total_Death_Count
FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%India%' 
WHERE continent is not null
GROUP BY continent
ORDER BY total_Death_Count desc

 /*Global infected cases with death percentage*/

 --SELECT date, SUM(new_cases) as new_cases_globally, SUM(new_deaths) as total_new_Deaths
 --,(SUM(new_deaths)/SUM(new_cases))*100 AS deathPercentGlobally /*Error: Divide by zero error encountered. Warning: Null value is eliminated by an aggregate or other SET operation*/ 
 --FROM PortfolioProject..covidDeaths
 --WHERE continent is not null
 --WHERE location LIKE '%India%' 
 --GROUP BY date
 --ORDER BY 1,2

 SELECT date, SUM(new_cases) AS new_cases_globally, SUM(new_deaths) AS total_new_deaths,
    /*Solution for Divide BY Zero error*/
	CASE
        WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) * 100.0 / SUM(new_cases))
        ELSE 0
    END AS death_percent_globally
FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%India%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

/*total population vs total vaccincated population*/

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,vac.total_vaccinations 
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null and dea.location LIKE '%albania%'
ORDER BY 2,3

/*total population vs total vaccincated population using CTE*/

WITH PopvsVac (continent, location, date, population, newly_Vaccinated, total_People_Vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null and dea.location LIKE '%albania%'
--ORDER BY 2,3
)
SELECT *
FROM PopvsVac

/*total population vs total vaccincated population using TEMP tables*/

DROP TABLE IF EXISTS #peopleVaccinatedPopulation 
CREATE TABLE #peopleVaccinatedPopulation
(
    continent nvarchar(255),
    location nvarchar(255),
    data datetime,
	Population numeric,
    newly_Vaccinated numeric,
    total_People_Vaccinated int
)

INSERT INTO #peopleVaccinatedPopulation (continent, location, data, Population, newly_Vaccinated, total_People_Vaccinated)
SELECT
    dea.continent,
    dea.location,
    dea.date,
	dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM
    PortfolioProject..covidDeaths dea
JOIN
    PortfolioProject..covidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
    AND dea.location LIKE '%albania%'

SELECT *
FROM #peopleVaccinatedPopulation