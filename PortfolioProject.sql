SELECT * FROM CovidDeaths WHERE continent <> 'NULL' ORDER BY 3,4

--SELECT * FROM CovidVaccinations ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population FROM CovidDeaths ORDER BY 1,2

--Total cases vs Total deaths 
--Shows likelihood of dying from covid
SELECT location, date, total_cases,new_cases,total_deaths,population,(total_deaths/total_cases)*100
AS DeathPercentage FROM CovidDeaths WHERE location like '%states'
ORDER BY 1,2

--Total cases vs population
--Shows what percentage of population got covid
SELECT location, date, total_cases,new_cases,total_deaths,population,(total_cases/population)*100
AS PercentPopulationInfected FROM CovidDeaths WHERE location like '%states'
ORDER BY 1,2


--Looking at maximum infection rate compared to population
SELECT location,population, MAX(total_cases) AS MaxCases, MAX((total_cases/population)) * 100 AS PercentPopulationInfected FROM CovidDeaths 
GROUP BY location, population ORDER BY 4 DESC


--Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount FROM CovidDeaths WHERE continent is not null
GROUP BY location ORDER BY TotalDeathCount DESC

--Showing continents with highest death counts
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount FROM CovidDeaths WHERE continent is null
GROUP BY location ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
SELECT date,SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths WHERE continent is not null
GROUP BY date ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths WHERE continent is not null
 ORDER BY 1,2

 --CTE

 WITH PopvsVac (Continent, Location,Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 AS
 (
 SELECT Dea.continent,Dea.location,Dea.date,population, CAST(new_vaccinations AS int ) AS new_vaccinations, SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
 FROM CovidDeaths Dea JOIN CovidVaccinations Vac ON Dea.location=Vac.location and Dea.date = Vac.date
 WHERE Dea.continent is not null )

 SELECT *,(RollingPeopleVaccinated/Population) * 100 FROM PopvsVac

DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(50),
Location varchar(50),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated  
SELECT Dea.continent,Dea.location,Dea.date,population, CAST(new_vaccinations AS int ) AS new_vaccinations, SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
 FROM CovidDeaths Dea JOIN CovidVaccinations Vac ON Dea.location=Vac.location and Dea.date = Vac.date
 WHERE Dea.continent is not null 

 SELECT * FROM #PercentPopulationVaccinated



--Creating view to store data for later visualizations

CREATE VIEW  PercentPopulationVaccinated AS 
SELECT Dea.continent,Dea.location,Dea.date,population, CAST(new_vaccinations AS int ) AS new_vaccinations, SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
 FROM CovidDeaths Dea JOIN CovidVaccinations Vac ON Dea.location=Vac.location and Dea.date = Vac.date
 WHERE Dea.continent is not null 

 SELECT * FROM PercentPopulationVaccinated


 CREATE VIEW DeathCount AS 
 SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount FROM CovidDeaths WHERE continent is null
GROUP BY location 

SELECT * FROM DeathCount