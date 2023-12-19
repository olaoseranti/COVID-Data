
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPerCent
FROM dbo.CovidDeaths
Where location like '%states%'
order by 1,2 

--% of Population infected

SELECT Location, date, total_cases, Population, (total_cases/Population)*100 AS InfectedPerCent
FROM dbo.CovidDeaths
Where location like '%states%'
order by 1,2 

--Countries with Highest Infection Rate compared to Population

 SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population)*100) AS HighestInfectedPerCent
FROM dbo.CovidDeaths
group by Location, Population
order by 4 desc 



--Continents with highest death count
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
where continent is null
group by Location 

--GLOBAL NUMBERS
SELECT SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPerCent
FROM dbo.CovidDeaths
Where continent is not null
order by 1,2 

--Joining both tables
 SELECT *
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVax vax ON dea.location = vax.location AND dea.date = vax.date 

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaxed
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVax vax ON dea.location = vax.location AND dea.date = vax.date
where dea.continent is not null
order by 2,3

WITH PopVsVax AS (SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaxed
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVax vax ON dea.location = vax.location AND dea.date = vax.date
where dea.continent is not null
)
SELECT *, (RollingPeopleVaxed/Population)*100
FROM PopVsVax

--TEMP TABLE
DROP TABLE if exists #PercentPopVaxed
Create Table #PercentPopVaxed
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopVaxed
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaxed
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVax vax ON dea.location = vax.location AND dea.date = vax.date
