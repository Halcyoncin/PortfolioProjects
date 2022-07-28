--removing data where continent is null

Select *
from Portfolio_project..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from Portfolio_project..CovidVaccinations
--order by 3,4

--select data we will be using
Select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project..CovidDeaths
order by 1,2

--looking at total cases vs. total deaths
--shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_project..CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs. population
--shows what percentage of population contracted covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from Portfolio_project..CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infection rates compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_project..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
--changing(casting) total_deaths from numeric? to int

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--breaking things down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

--showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio_project..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--total number global deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio_project..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2


-- Looking at Total Population vs. Vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
	dea.Date) as RollingPeopleVaccinated --this is so when we get to a new location the sum count starts over, rather than increasing
--, (RollingPeopleVaccinated/population)*100  --this won't run since we just created it
from Portfolio_project..CovidDeaths as dea
join Portfolio_project..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
--CONVERT is similar to CAST


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
	dea.Date) as RollingPeopleVaccinated --this is so when we get to a new location the sum count starts over, rather than increasing
--, (RollingPeopleVaccinated/population)*100  --this won't run since we just created it
from Portfolio_project..CovidDeaths as dea
join Portfolio_project..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentageLocationVaccinated
from PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
	dea.Date) as RollingPeopleVaccinated --this is so when we get to a new location the sum count starts over, rather than increasing
--, (RollingPeopleVaccinated/population)*100  --this won't run since we just created it
from Portfolio_project..CovidDeaths as dea
join Portfolio_project..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100 as PercentageLocationVaccinated
from #PercentPopulationVaccinated


--  Creating View to Store Data for Later Visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
	dea.Date) as RollingPeopleVaccinated 
from Portfolio_project..CovidDeaths as dea
join Portfolio_project..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *
from PercentPopulationVaccinated

