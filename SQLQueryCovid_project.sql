Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..CovidVacinations
--Order by 3, 4

-- Select Data that we're going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Looking at total_cases vs total_deaths

Select location, date, total_cases, total_deaths, ((Select CAST(total_deaths as float))/(Select CAST(total_cases as float)))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Order by 1, 2

Select location, date, total_cases, total_deaths, ((Select CAST(total_deaths as float))/(Select CAST(total_cases as float)))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

-- Total_cases vs population
-- shows what percentage of pop. got covid

Select location, date, total_cases, population, ((Select CAST(total_cases as float))/(Select CAST(population as float)))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

Select location, date, total_cases, population, ((Select CAST(total_cases as float))/(Select CAST(population as float)))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1, 2

-- Looking at countries with highest infection rate compared to pop.

Select location, population, MAX((CAST(total_cases as float))) as HighestInfectionCount, max(((CAST(total_cases as float))/(CAST(population as float))))*100 as PercentOfPopInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentOfPopInfected desc

-- Countries with highest death count per population

Select location, MAX((CAST(total_deaths as float))) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
Order by TotalDeathCount desc

-- Continent

Select continent, MAX((CAST(total_deaths as float))) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

Select location, MAX((CAST(total_deaths as float))) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is null
Group by location
Order by TotalDeathCount desc

-- showing continents with highest deathcount

Select continent, MAX((CAST(total_deaths as float))) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- global numbers
Select date, SUM(new_cases), SUM(new_deaths)--, (SUM(new_deaths)/SUM(new_cases))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where  continent is not null
Group by date
Order by 1, 2

Select date, SUM(new_cases_smoothed), SUM(new_deaths_smoothed), (SUM(new_deaths_smoothed)/SUM(new_cases_smoothed))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where  continent is not null
Group by date
Order by 1, 2

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where  continent is not null
--Group by date
Order by 1, 2

-- Total Population vs Total Vac.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location = 'Canada'
order by 2, 3

-- Using CTE

With PopvsVac(Continent, Location, Date, Population, New_Vac, RollingPeopleVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location = 'Canada'
--order by 2, 3
)
Select *, (RollingPeopleVac/Population)*100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null --and dea.location = 'Canada'
--order by 2, 3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location = 'Canada'
--order by 2, 3