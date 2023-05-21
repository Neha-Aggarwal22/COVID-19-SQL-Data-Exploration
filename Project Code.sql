SELECT *
FROM project1..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

/*SELECT *
FROM project1..CovidVaccinations
ORDER BY 3,4 */


--Select data in use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM project1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--USE project1;

-- Altering data types of columns for calculation purposes

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths float



-- Looking at Total Cases vs Total Deaths
-- Shows the liklihood of dying if one contacts covid in one's country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM project1..CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1,2



-- Looking at Total Cases vs Population
-- Shows the %age of the population infected by COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM project1..CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM project1..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC


-- Showing countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM project1..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC


-- Breaking things down by Continent
-- Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM project1..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM project1..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1


SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM project1..CovidDeaths
WHERE continent is not null
ORDER BY 1



--Looking at total population vs Vaccinations
--Storing the data in a Temp Table to increase the efficiency

DROP TABLE if exists DataInUse
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition By d.location Order By d.location, d.date) AS TotalVaccinationsbyDate
INTO DataInUse
FROM project1..CovidDeaths d
JOIN project1..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3



--Looking at total & percentage of population vs Vaccinations using a CTE

WITH cte_PopVsVac AS
(SELECT continent, location, date, population, new_vaccinations,
SUM(new_vaccinations) OVER (Partition By location Order By location, date) AS TotalVaccinationsbyDate
FROM DataInUse
WHERE continent is not null
--ORDER BY 2,3
)
SELECT *, (TotalVaccinationsbyDate/population)*100 AS PercentPopulationVaccinated
FROM cte_PopVsVac
ORDER BY 2,3



-- Creating view to store data for later visualizations

DROP VIEW if exists v_PercentPopulationVaccinated

CREATE VIEW v_PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition By d.location Order By d.location, d.date) AS TotalVaccinationsbyDate
FROM project1..CovidDeaths d
JOIN project1..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3