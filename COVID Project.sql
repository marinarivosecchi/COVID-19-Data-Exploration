SELECT *
	FROM PortfolioProject..CovidDeaths 
	WHERE continent IS NOT NULL
	ORDER BY 3,4

--ALTER TABLE PortfolioProject..CovidDeaths
--ALTER COLUMN total_deaths float

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
WHERE location like '%argentina%'
order by 1,2

--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looing at total cases vs population
-- show what percentage of population got covid
SELECT location, date,  population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looing at total cases vs population
-- show what percentage of population got covid
SELECT location, date,  population, total_cases, (total_cases/population)*100 as InfectedPercentage
	FROM PortfolioProject..CovidDeaths
	--WHERE location like '%argentina%'
	order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT TOP 10 location, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX(total_cases/population)*100,3) as InfectedPercentage
	FROM PortfolioProject..CovidDeaths
	GROUP BY location, population
	ORDER BY InfectedPercentage DESC

-- Showing countries with highest death count 

SELECT location, MAX(total_deaths) AS TotalDeathCount 
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY TotalDeathCount DESC

-- Breaking things down by continent

SELECT location, MAX(total_deaths) AS TotalDeathCount 
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NULL
	GROUP BY location
	ORDER BY TotalDeathCount DESC



-- Showing continents with the highest death count
SELECT continent, MAX(total_deaths) AS TotalDeathCount 
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY TotalDeathCount DESC

-- Global numbers  by date

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, ROUND(SUM(cast(new_deaths AS INT))/SUM(new_cases)*100,2) AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY 1,2

-- Total pandemic values

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, ROUND(SUM(cast(new_deaths AS INT))/SUM(new_cases)*100,2) AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY 1,2


-- VACCINATIONS 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

-- USE CTE

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


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
		FROM PortfolioProject..CovidDeaths dea
		JOIN PortfolioProject..CovidVaccinations vac
			ON dea.location = vac.location AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated