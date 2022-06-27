--Inspect Table
SELECT *
FROM PortfolioProject..CovidsDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Segmenting for Loc., Date, Cases & Pop.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidsDeaths
ORDER BY 1,2 

-- Total Cases vs Total Deaths % at Malaysia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidsDeaths
WHERE location like '%Malay%'
ORDER BY 1,2 

--Total cases vs Populations % at Malaysia
SELECT location, date, population,total_cases, (total_cases/ population) *100 AS InfectedPercentage
FROM PortfolioProject..CovidsDeaths
WHERE location like '%Malay%' AND continent IS NOT NULL
ORDER BY 1,2

--Highest infaction % rate to Population by Country
SELECT location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/ population)) *100 AS HighestInfectedPercentage
FROM PortfolioProject..CovidsDeaths
GROUP BY location, population
ORDER BY 4 DESC

--Highest death count to Popopulation by Country
SELECT location, population,MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidsDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC

--Highest death count to Population by Continent
SELECT continent,MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidsDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY 2 DESC

-- Global Numbers Covid cases and deaths
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidsDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

--Total Population vs Total Vaccination by Location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.location, dea.Date) AS CumNewVaccinations
FROM PortfolioProject..CovidsDeaths AS dea
JOIN PortfolioProject..CovidsVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CTE to find CummulativeVaccinated population %
WITH PopVsTVac (Continent, Country, Date, Population, NewVaccination, CumNewVaccinations) 
AS(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS CumNewVaccinations
FROM PortfolioProject..CovidsDeaths AS dea
JOIN PortfolioProject..CovidsVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, CumNewVaccinations/population *100 AS CummulativeVaccinatedPopulation
FROM PopVsTVac

--Create view for visualisation (Total Population vs Total Vaccination by Location)
CREATE VIEW PercentPopulationVaccinated AS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS CumNewVaccinations
FROM PortfolioProject..CovidsDeaths AS dea
JOIN PortfolioProject..CovidsVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
