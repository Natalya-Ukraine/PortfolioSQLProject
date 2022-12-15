--Data download check

SELECT* From PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4


SELECT* From PortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4

--Select data that we are going to be using


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking  at  Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases,  total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Looking at Total cases vs Population
--Shows what percentage of  Canadian  population got covid

SELECT location, date,Population, total_cases, (total_deaths/Population)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

--Looking at Countries with highest  infection rate compare to population

SELECT location,Population, MAX(total_cases) AS HighestInfectioCount,
MAX ((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location,Population
ORDER BY PercentPopulationInfected DESC


--Counties Highest death count per  population

SELECT location, MAX (CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Total Deaths by Continent

SELECT continent, MAX (CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Highest Death Count By Continent

SELECT continent, MAX (CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global Numbers

SELECT SUM(new_cases) as total_cases, 
SUM (CAST(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Order BY 1,2


SELECT date, SUM(new_cases) as total_cases, 
SUM (CAST(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
Order BY 1,2

--Join two tables
--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.date)
AS UpdatedVaccinationCount
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--CTE

WITH PopulationVsVaccination
(continent, location, date, population, new_vaccinations,
UpdatedVaccinationCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.date)
AS UpdatedVaccinationCount
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT*,(UpdatedVaccinationCount/population)*100
FROM PopulationVsVaccination

--Temp Table

DROP TABLE if exists PercentPopulationVaccinated
CREATE TABLE PortfolioProject.dbo.PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar (225),
Date datetime,
Population numeric,
New_vaccinations numeric,
UpdatedVaccinationCount numeric
)

INSERT INTO PortfolioProject.dbo.PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.date)
AS UpdatedVaccinationCount
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

SELECT*,(UpdatedVaccinationCount/population)*100
FROM PortfolioProject.dbo.PercentPopulationVaccinated



--Create view to store data

USE PortfolioProject
GO
CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.date)
AS UpdatedVaccinationCount
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3


SELECT * FROM PercentagePopulationVaccinated
