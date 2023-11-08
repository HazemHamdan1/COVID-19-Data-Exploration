--select * 
--from [dbo].[CovidDeaths]
--order by 3,4

--select the data we are going to use:

select location , date , total_cases , new_cases , total_deaths , population
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2



--Finding Death Percentage : 

select location , date , total_cases , total_deaths ,(total_deaths/total_cases )*100 as deaths_Percentage
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2



--Finding total cases vs population :
select location , date , total_cases , population ,(total_cases/population )*100 as cases_Percentage 
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total deaths in each Location :
select location , date , total_deaths , population
from portfolioProject..CovidDeaths
where date in (select max(date)
from portfolioProject..CovidDeaths
)
and continent is not null
order by location


--Highest infection rate compared to population:
select location , max(total_cases) MAX_cases , population ,max((total_cases/population )*100) as cases_Percentage 
from portfolioProject..CovidDeaths
where continent is not null
group by location , population
order by 4 desc



--Highest Deaths compared to population :
select location , max(cast(total_deaths as int)) MAX_deaths 
from portfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc



--Hightest Deaths by Continent :
select continent , max(cast(total_deaths as int)) MAX_deaths 
from portfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc



--Globl Numbers:
--Total cases and deaths by date:
select date , sum(new_cases) Total_Cases,sum(cast(new_deaths as int)) Total_Deathe ,(sum(cast(new_deaths as int))/sum(new_cases) )*100 as death_Percentage
from portfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2,3



--Total cases and deaths: 
select sum(new_cases) Total_Cases,sum(cast(new_deaths as int)) Total_Deathe ,(sum(cast(new_deaths as int))/sum(new_cases) )*100 as death_Percentage
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2,3


--------------------------------
--Check the tables:
Select * 
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths de
on vac.continent=de.continent and vac.date=de.date



--Total Vaccinations vs Popultions:
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(BIGINT ,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RoolingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on vac.continent=dea.continent and vac.date=dea.date
where dea.continent is not null 
order by 1,2,3


-- --Vaccinated People vs Population :
--creat CTE:
with RoPeVacc 
as
(Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(BIGINT ,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) 
as RoolingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on vac.continent=dea.continent and vac.date=dea.date
where dea.continent is not null )
--
select*,(roolingpeoplevaccinated/population)*100 as VaccinatedPeoplePercet
from RoPeVacc
order by 1,2

--With temp table:
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
continent nvarchar(50),
location nvarchar(50),
date datetime,
population numeric,
new_vaccinations numeric,
roolingpeoplevaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(BIGINT ,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) 
as RoolingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on vac.continent=dea.continent and vac.date=dea.date
where dea.continent is not null

select*,(roolingpeoplevaccinated/population)*100 as VaccinatedPeoplePercet
from #PercentPopulationVaccinated
order by 1,2



--Storting Views :
create View PercentPopulationVaccinated
as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(BIGINT ,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) 
as RoolingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on vac.continent=dea.continent and vac.date=dea.date
where dea.continent is not null

create View Global_Numbers as
select date , sum(new_cases) Total_Cases,sum(cast(new_deaths as int)) Total_Deathe ,(sum(cast(new_deaths as int))/sum(new_cases) )*100 as death_Percentage
from portfolioProject..CovidDeaths
where continent is not null
group by date


create View Death_Percentage as
select sum(new_cases) Total_Cases,sum(cast(new_deaths as int)) Total_Deathe ,(sum(cast(new_deaths as int))/sum(new_cases) )*100 as death_Percentage
from portfolioProject..CovidDeaths
where continent is not null


create VIew MaxDeathsByContinents as
select continent , max(cast(total_deaths as int)) MAX_deaths 
from portfolioProject..CovidDeaths
where continent is not null
group by continent