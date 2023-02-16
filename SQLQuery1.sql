select * from PortfolioProject ..CovidDeaths
order by 3,4 
--select * from PortfolioProject ..CovidVaccinations
--order by 3,4


--Looking at total_cases vs total_deaths
select location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as death_Percentage
from PortfolioProject ..CovidDeaths
order by 1,2


--Shows the likelihood of you dying if you contract covid in United States 
select location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as death_Percentage
from PortfolioProject ..CovidDeaths
where location like '%States%'
order by location,date

--looking at the total cases vs the population 

select location, date, total_cases, population , (total_cases/population)*100 as cases_Percentage
from PortfolioProject ..CovidDeaths
order by location,date



--looking at the total cases vs the population and cases percentage in states
select location, date, total_cases, population , (total_cases/population)*100 as cases_Percentage
from PortfolioProject ..CovidDeaths
where location like '%States%'
order by location,date

--looking at the highest infection rate compared to population
select location, population,  max(total_cases) as highest_count, max(total_cases/population)*100 as percentage_infecetd_cases
from PortfolioProject ..CovidDeaths
group by location, population
order by percentage_infecetd_cases desc
 
--showing countries with highest death per popluation
select location, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by  location
order by highest_death_count desc


--showing continents with  death per popluation
select location, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is  null
group by  location
order by highest_death_count desc


--showing continents with  death per popluation
select location, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
where continent like  '%Asia%'
group by  location
order by highest_death_count desc



--Shows the likelihood of you dying if you contract covid in United States 
select date, total_cases, total_deaths , (total_deaths/total_cases)*100 as death_Percentage
from PortfolioProject ..CovidDeaths
--where location like '%States%'
where total_cases is not null
order by 1,2




Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths , SUM(cast (new_deaths as int ))/Sum( new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2






Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



--Total Population Vs Vaccination
select *

from PortfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date

--Total Population Vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

from PortfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 1,2


-- Shows Percentage of Population that has recieved at least one Covid Vaccine

		Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
		From PortfolioProject..CovidDeaths dea
		Join PortfolioProject..CovidVaccinations vac
			On dea.location = vac.location
			and dea.date = vac.date
			where vac.new_vaccinations is not null
 and  dea.continent is not null
		order by 2,3

	-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as rpllingpercentage
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 