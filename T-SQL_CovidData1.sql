-- Data Overview

SELECT *
FROM [dbo].[CovidVaccinations]
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths in Brazil
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[CovidDeaths]
where location = 'Brazil'
ORDER BY 1,2

-- Looking at the Total Cases vs Population in Brazil
SELECT location, date, total_cases/10 as total_cases, population/10 as population, (total_cases/population)*100 as percentageInfected
FROM [dbo].[CovidDeaths]
where location like '%B%il'
ORDER BY 1,2

-- Parsing infection rates per capita over time amongst every country in the database
SELECT location, MAX(total_cases)/10 as HighestInfectionCount, population/10 as population,
MAX((total_cases/population))*100 as PercentageInfected
FROM [dbo].[CovidDeaths]
GROUP BY location, population
ORDER BY PercentageInfected desc

-- Showing the top 10 countries with the highest death count overall
SELECT TOP 10 location, MAX(CONVERT(int, total_deaths))/10 as TotalDeaths
FROM [dbo].[CovidDeaths]
Where NULLIF(continent, '') is not null
GROUP BY location
ORDER BY TotalDeaths desc

-- Seeing the distribution of total deaths by continent.
SELECT location, max(cast(total_deaths as int))/10 as TotalDeaths
FROM [dbo].[CovidDeaths]
Where NULLIF(continent, '') is null and location = 'South America'
or location = 'Europe' 
or location = 'North America'
or location = 'Asia'
or location = 'Oceania'
or location = 'Central America'
GROUP BY location
ORDER BY TotalDeaths desc

-- Showing GLOBAL figures of confirmed deaths by date and fatality rates

select date, SUM(new_cases)/10 as ConfirmedCases, SUM(cast(new_deaths as int))/10 as ConfirmedDeaths,
(SUM(cast(new_deaths as int)) / SUM(new_cases))*100 as DeathPercentageGlobal
FROM [dbo].[CovidDeaths]
where NULLIF(continent, '') is not null
Group By date
Order by 1 asc


-- Joining the deaths and vaccinations tables using the location as key
-- Analysing how vaccination unfolded throughout the pandemic in Brazil
select dea.continent, dea.location, dea.date, dea.population/10 as population, CONVERT(float,nullif(vac.new_vaccinations, '')) as NewVaccinations
, SUM(CONVERT(float,nullif(vac.new_vaccinations, ''))) OVER (Partition by dea.location Order by dea.location, 
dea.date) as TotalVaccineDosesApplied
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where NULLIF(dea.continent, '') is not null and dea.location = 'Brazil'
order by date


-- Showing the number of tests throughout de pandemic in Brazil
-- Also, the inaccuracy of the dataset over the number of new tests and the official number of total tests
select vac.location, vac.date, dea.population/10 as population, CONVERT(float,new_tests) as new_tests,
SUM(CONVERT(float,new_tests)) OVER (partition by vac.location order by vac.location, vac.date) 
as TotalTests, CONVERT(float,total_tests) as total_tests
from [dbo].[CovidVaccinations] vac
join [dbo].[CovidDeaths] dea
	on vac.location = dea.location
	and vac.date = dea.date
where NULLIF(vac.continent, '') is not null and vac.location = 'Brazil'
order by vac.date

-- Creating a SQL View of the Brazilian people vaccinated and fully vaccinated in percentage of the population
CREATE VIEW VaccinatedPeopleBrazil as
select vac.location, vac.date, dea.population/10 as population, CONVERT(float,people_vaccinated) as people_vaccinated,
CONVERT(float,people_vaccinated)/ (dea.population/10)*100 as PercentageVaccinated,
CONVERT(float, people_fully_vaccinated) as people_fully_vaccinated,
CONVERT(float, people_fully_vaccinated)/(dea.population/10)*100 as PercentageFullyVaccinated
from [dbo].[CovidVaccinations] vac
join [dbo].[CovidDeaths] dea
	on vac.location = dea.location
	and vac.date = dea.date
where vac.location = 'Brazil' and NULLIF(vac.continent, '') is not null

select *
from VaccinatedPeopleBrazil
order by date



