use CovidProject;

select * 
from Coviddeaths
where continent is not null
order by 3,4;

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from Coviddeaths
where continent is not null
order  by 1,2

--Looking at Total Cases VS Total Deaths
--Show liklihood of dying if you contacted the virus in your country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Coviddeaths
where location= 'India'
and continent is not null
order  by 1,2

--Looking at Total Cases vs Population
--Shows how many contracted the virus
select location, date, total_cases,population,  (total_cases/population)*100 as PercentagePopulationInfected
from Coviddeaths
where location= 'India'
and continent is not null
order  by 1,2

--Countries with highest infection rate compared to Population
select location, max(total_cases) as HighhestInfectionCount, population,  max((total_cases/population))*100 as PercentagePopulationInfected
from Coviddeaths
where continent is not null
group  by location, population
order  by PercentagePopulationInfected desc

--Countries with highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount 
from Coviddeaths
where continent is not null
group  by location
order  by TotalDeathCount desc


--Getting Info on Continents
--Continents with Highest Death Count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from Coviddeaths
where continent is not null
group  by continent
order  by TotalDeathCount desc

--Global Numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from Coviddeaths
where continent is not null
group by date
order by 1,2


--Total Death across the world as in the month of August 2021
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from Coviddeaths
where continent is not null
--group by date
order by 1,2


--Total Population vs Vaccination

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from Coviddeaths d 
join
CovidVaccinations v
on d.location = v.location and d.date= v.date
where d.continent is not null
order by 2,3


--Use CTE

With popvsvac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from Coviddeaths d 
join
CovidVaccinations v
on d.location = v.location and d.date= v.date
where d.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationPercentage
from popvsvac




--Temp Table

Drop table if exists
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
POpulation numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from Coviddeaths d 
join
CovidVaccinations v
on d.location = v.location and d.date= v.date
where d.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationPercentage
from #PercentPopulationVaccinated


--CReating viewsfor visualizatios

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from Coviddeaths d 
join
CovidVaccinations v
on d.location = v.location and d.date= v.date
where d.continent is not null
--order by 2,3