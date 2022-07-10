/*

Covid 19 Data Exploration 
Skills used: Joins, Windows Functions, Data type conversion, Aggregate Functions, Temp Tables, CTE's, Creating views

*/

--------------------------------------------------------------------------------------------------------------------------

/* Two data table: Covid Deaths and Covid Vaccinations */

Select *
FROM PortfolioProject..CovidDeaths
ORDER BY location, date

Select *
FROM PortfolioProject..CovidVaccinations
ORDER BY location, date

--------------------------------------------------------------------------------------------------------------------------

/* Cases in Argentina */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%argentina%'
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------

/* Total Cases vs Total Deaths */
-- Percentage of people who died out of the total number of people who had covid 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Argentina%'
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------

/* Total Cases vs Population */
-- Percentage of population who got covid in Argentina 

SELECT location, date,  population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%argentina%'
order by 1,2

--------------------------------------------------------------------------------------------------------------------------

/* Probability of dying if you get covid in china */
-- China actually has a higher precentage of death, but their total deaths of 4632 has not changed since 2020-05-16. US total deaths on the same date is 92073.

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%china%'
ORDER BY Location, date

--------------------------------------------------------------------------------------------------------------------------

/* Countries with highest infection rate */

SELECT TOP 10 location, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX(total_cases/population)*100,3) as InfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC

--------------------------------------------------------------------------------------------------------------------------

/* Countries with highest death count  */

SELECT location, MAX(total_deaths) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------------

/* Countries with highest death rate per population  */

Select Location, population, MAX(cast(total_deaths as int)) as deaths, MAX((cast(total_deaths as int)/population))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY DeathPercentage desc

--------------------------------------------------------------------------------------------------------------------------

/* Countries with highest death toll  */

SELECT location, MAX(total_deaths) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------------

/* Continents with highest death toll  */

SELECT continent, MAX(total_deaths) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS  NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------------

/* Global numbers  by date */

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, ROUND(SUM(cast(new_deaths AS INT))/SUM(new_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------

/* Total pandemic values */

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, ROUND(SUM(cast(new_deaths AS INT))/SUM(new_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------

/* DATA EXPORATION - Vaccinations */
/* Total population vs vaccinations in rolling basis for countries */
-- Important: The number of vaccinated people is higher than the population, say for Canada and United States. Probably each dose counts as one vaccination, check data. 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--------------------------------------------------------------------------------------------------------------------------

/* CTE */

WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--	ORDER BY 2,3
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--	ORDER BY 2,3

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) FROM #PercentPopulationVaccinated


--------------------------------------------------------------------------------------------------------------------------

/* Create view to store data for later visualizations */

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
		FROM PortfolioProject..CovidDeaths dea
		JOIN PortfolioProject..CovidVaccinations vac
			ON dea.location = vac.location AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated

--------------------------------------------------------------------------------------------------------------------------
