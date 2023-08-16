
--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

 SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

 --Total cases vs Total deaths

 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths
 Where Location Like '%india%'
 ORDER BY 1,2

 --Total cases vs Population

 SELECT location, date, total_cases, population, (total_cases/population)*100 as PerecnetPopulationInfected
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

 SELECT location, date, total_cases, population, (total_cases/population)*100 as PerecnetPopulationInfected
 FROM PortfolioProject..CovidDeaths
 Where Location Like '%india%'
 ORDER BY 1,2

 --Highest Infection rate country to population

 SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PerecnetPopulationInfected
 FROM PortfolioProject..CovidDeaths
 GROUP BY location,population
 ORDER BY PerecnetPopulationInfected desc

 --Countries with most death count per population

 SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 GROUP BY location
 ORDER BY TotalDeathCount desc

 --Breakdown by Continent

 --SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
 --FROM PortfolioProject..CovidDeaths
 --WHERE continent is null
 --GROUP BY location
 --ORDER BY TotalDeathCount desc

 --Continent with highest death count per population

 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 GROUP BY continent
 ORDER BY TotalDeathCount desc

 -- Global Numbers

 --SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPerecnet
 --FROM PortfolioProject..CovidDeaths
 --WHERE continent is not null
 --GROUP BY date
 --ORDER BY 1,2

 SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPerecnet
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

 --CovidVacination

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Total popluation vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

--use of CTE

With PopvsVac (continent, location, Date, Popluation, new_vaccinations, TotalPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (TotalPeopleVaccinated/Popluation)*100 as PercentageOfPeopleVaccinated
From PopvsVac
ORDER by 1,2 desc


--use of temptable

Drop table if exists #PopluationVaccinated

Create table #PopluationVaccinated
(
Continet nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric,
)
Insert into #PopluationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (TotalPeopleVaccinated/Population)as PercentageOfPeopleVaccinated
From #PopluationVaccinated

  
--Creating View data for visualizations

Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentagePopulationVaccinated
