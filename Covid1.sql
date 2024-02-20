SELECT * FROM 
Portfolioproject..CovidDeaths
order by 3,4



SELECT Location, date, total_cases, new_cases, total_deaths, population FROM 
Portfolioproject..CovidDeaths
order by 1,2

--looking at the total cases vs total deaths
--shows the likehood of dying ir covid contracted per country
select location, date, Total_cases, Total_deaths, (total_deaths/total_cases)*100 AS PercentageDeath from
Portfolioproject..CovidDeaths
where location like '%kingdom%'
order by 1,2

--looking at total cases vs population 
--shows what percentage of population has got covid
select location, date, Population, Total_cases,  (total_cases/Population)*100 AS Populationinfected from
Portfolioproject..CovidDeaths
--where location like '%kingdom%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, Population, MAX(Total_cases) As HighIF,  MAX(total_cases/Population)*100 AS MaxPopulationinfected from
Portfolioproject..CovidDeaths
--where location like '%kingdom%'
Group by Location, Population
order by MaxPopulationinfected desc

--looking at countries with the highest death count per population
select location, MAX(cast(Total_deaths as int)) As TotalDeathcount from
Portfolioproject..CovidDeaths
where continent is not null
Group by Location, Population
order by TotalDeathcount desc

--check by continent instead
select continent, MAX(cast(Total_deaths as int)) As TotalDeathcount from
Portfolioproject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathcount desc

select location, MAX(cast(Total_deaths as int)) As TotalDeathcount from
Portfolioproject..CovidDeaths
where continent is null
Group by location
order by TotalDeathcount desc

--showing the continents with thehighest death
select continent, MAX(cast(Total_deaths as int)) As TotalDeathcount from
Portfolioproject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathcount desc

--Global numbers
select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS PercentageDeath from
Portfolioproject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
Group by date
order by 1,2

select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS PercentageDeath from
Portfolioproject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
--Group by date
order by 1,2

--looking at total population vs vaccinations
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (partition by da.location order by da.location, da.date) as rollingpeoplevaccinated, 
(rollingpeoplevaccinated/population)*100
FROM 
Portfolioproject..CovidVaccinations VAC
Join Portfolioproject..Coviddeaths DA
	on da.location = vac.location 
	and da.date = vac.date
where da.continent is not null
order by 2,3

--USE CTE
with PopvsVac (continent, location, date, population, rollingpeoplevaccinated, new_vaccinations)
as
(
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (partition by da.location order by da.location, da.date) as rollingpeoplevaccinated 
--(rollingpeoplevaccinated/population)*100
FROM 
Portfolioproject..CovidVaccinations VAC
Join Portfolioproject..Coviddeaths DA
	on da.location = vac.location 
	and da.date = vac.date
where da.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated)*100 from popvsvac

--TEMP Table

DROP TABLE if exists #percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
continent nvarchar(255), 
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #percentpopulationVaccinated
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (partition by da.location order by da.location, da.date) as rollingpeoplevaccinated 
--(rollingpeoplevaccinated/population)*100
FROM 
Portfolioproject..CovidVaccinations VAC
Join Portfolioproject..Coviddeaths DA
	on da.location = vac.location 
	and da.date = vac.date
--where da.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated)*100 from #percentpopulationvaccinated

creating view to store data for later visualisations

Drop view percentpopulationvaccinated
create  View percentpopulationvaccinated as
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (partition by da.location order by da.location, da.date) as rollingpeoplevaccinated 
--(rollingpeoplevaccinated/population)*100
FROM 
Portfolioproject..CovidDeaths da
Join Portfolioproject..Covidvaccinations vac
	on da.location = vac.location 
	and da.date = vac.date
where da.continent is not null
--order by 2,3

Select * from percentpopulationvaccinated