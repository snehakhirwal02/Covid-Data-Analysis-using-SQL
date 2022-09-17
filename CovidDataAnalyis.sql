select * from PortfolioProject..CovidDeaths
order by 3,4

select * from PortfolioProject..CovidVaccinations
order by 3,4

--Data we are dealing with:
SELECT location, date , total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths 
where continent is not NULL
ORDER BY 1,2

--What are the percentage of deaths for the total number of the cases(who are infected) found?
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths 
WHERE location = 'India' 
ORDER BY 1,2
--RESULT: shows the likelihood of 1-3% of chances of dying if you contract COVID in India

-- Total cases vs Population
SELECT location, date, total_cases, population,(total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths 
WHERE location = 'India'
ORDER BY 1,2
--RESULT: shows the percentage of population who got covid

-- Which is the country with the highest infection rate in comparison to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)*100) AS InfectionRate
FROM PortfolioProject..CovidDeaths 
WHERE continent is not NULL 
GROUP BY location,population
ORDER BY population desc

-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is not NULL 
GROUP BY location
ORDER BY TotalDeathCount desc

-- Highest death count with respect to the continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is not NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc

-- The number of cases globally on a daily basis
SELECT date, SUM(new_cases) AS TotalCases,SUM(cast(new_deaths as int)) AS TotalDeaths
,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not NULL 
GROUP BY date
ORDER BY 1,2

--The number of cases, total deaths and death percentage worldwide
SELECT SUM(new_cases) AS TotalCases,SUM(cast(new_deaths as int)) AS TotalDeaths
,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not NULL 
ORDER BY 1,2  -- 2% of death worldwide who got infected

--Joining Tables for death and vaccination related information for further exploration 
Select *
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations vc
ON cd.location=vc.location
and cd.date= vc.date
where cd.continent is not null
order by 1,2,3

--Population vaccinated with atleast one vaccine in a particular location on a daily basis all over the world
Select cd.continent,cd.location,cd.date, cd.population,vc.new_vaccinations,
SUM(CONVERT(int,vc.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations vc
ON cd.location=vc.location
and cd.date= vc.date
where cd.continent is not null
order by 1,2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent,cd.location,cd.date, cd.population,vc.new_vaccinations,
SUM(CONVERT(int,vc.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations vc
ON cd.location=vc.location
and cd.date= vc.date
where cd.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Using TEMP table 
--DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select cd.continent,cd.location,cd.date, cd.population,vc.new_vaccinations,
SUM(CONVERT(int,vc.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations vc
ON cd.location=vc.location
and cd.date= vc.date
where cd.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view for later 
Create View PercentagePopulationVaccinated as 
Select cd.continent,cd.location,cd.date, cd.population,vc.new_vaccinations,
SUM(CONVERT(int,vc.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations vc
ON cd.location=vc.location
and cd.date= vc.date
where cd.continent is not null

Select * from PercentagePopulationVaccinated 
