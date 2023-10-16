select
location,date,total_cases,new_cases,total_deaths,population
FROM Portfolio..CovidDeaths
WHERE continent is not null
order by 1,2

select
location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM 
Portfolio..CovidDeaths
WHERE continent is not null
order by 1,2

select
location,date,total_cases,population,(total_cases/population)*100 as Percent_Population_Infected
FROM 
Portfolio..CovidDeaths
WHERE location = 'Nigeria' and
continent is not null
order by 1,2

select
location, MAX(total_cases) AS HighestInfectionCount,population,Max((total_cases/population))*100 as Percent_Population_Infected
FROM 
Portfolio..CovidDeaths
WHERE continent is not null
Group by location, population
order by Percent_Population_Infected desc

select
location, MAX(total_deaths) AS TotalDeathCount,population,Max((total_deaths/population))*100 as DeathPerPopulationPercentage
FROM 
Portfolio..CovidDeaths
WHERE continent is not null
Group by location, population
order by TotalDeathCount desc

select
location, MAX(total_deaths) AS TotalDeathCount
FROM 
Portfolio..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

select
location, MAX(total_deaths) AS TotalDeathCount
FROM 
Portfolio..CovidDeaths
where continent ='Africa'
Group by location
order by TotalDeathCount desc

select
date,sum(new_cases)as total_cases,sum(new_deaths)as total_deaths,sum(new_cases)/sum(new_deaths)*100 as death_percentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM 
Portfolio..CovidDeaths
WHERE continent is not null
Group by date
order by 1,2

select
sum(new_cases)as total_cases,sum(new_deaths)as total_deaths,sum(new_cases)/sum(new_deaths)*100 as death_percentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM 
Portfolio..CovidDeaths
WHERE continent is not null
Group by date
order by 1,2

SELECT *
FROM Portfolio..CovidDeaths deaths
JOIN Portfolio..CovidVaccinations vac
ON deaths.location = vac.[location]
and deaths.date = vac.[date]

SELECT  deaths.continent, deaths.LOCATION, deaths.date, deaths.population, vac.new_vaccinations
FROM Portfolio..CovidDeaths deaths
JOIN Portfolio..CovidVaccinations vac
ON deaths.location = vac.[location]
and deaths.date = vac.[date]
where deaths.continent is not null
order by 2,3

SELECT  deaths.continent, deaths.LOCATION, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths deaths
JOIN Portfolio..CovidVaccinations vac
ON deaths.location = vac.[location]
and deaths.date = vac.[date]
where deaths.continent is not null
order by 2,3

With PopvsVac (Continent,location,date,population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT  deaths.continent, deaths.LOCATION, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths deaths
JOIN Portfolio..CovidVaccinations vac
ON deaths.location = vac.[location]
and deaths.date = vac.[date]
where deaths.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

Drop Table if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
    continent nvarchar(255),
    Location nvarchar(255),
    Date DATETIME,
    Population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT  deaths.continent, deaths.LOCATION, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths deaths
JOIN Portfolio..CovidVaccinations vac
ON deaths.location = vac.[location]
and deaths.date = vac.[date]
where deaths.continent is not null
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

Create View PercentPopulationVaccinated AS
SELECT  deaths.continent, deaths.LOCATION, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths deaths
JOIN Portfolio..CovidVaccinations vac
ON deaths.location = vac.[location]
and deaths.date = vac.[date]
where deaths.continent is not null
SELECT *
FROM PercentPopulationVaccinated
ORDER BY RollingPeopleVaccinated DESC