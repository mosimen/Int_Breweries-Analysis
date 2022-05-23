--From the international breweries data recorded for a duration of three years, you are directed to do the analyses 
--in the document to aid better decision-making in order to maximize profit and reduce loss to the lowest minimum.

--Session A
--PROFIT ANALYSIS
--1. Within the space of the last three years, what was the profit worth of the breweries,
--inclusive of the anglophone and the francophone territories?
alter table int_breweries
alter column profit float
go
alter table int_breweries
alter column quantity float
go



select sum(PROFIT) as ProfitSum
from int_breweries

--2. Compare the total profit between these two territories in order for the territory manager 
---Mr. Stone to make a strategic decision that will aid profit maximization in 2020.

drop table if exists #terrtab
;with terrtab as
(select *,case when
	COUNTRIES in ('Ghana', 'Nigeria') then 'anglophone'
	else 'francophone'
	end as Territories
from int_breweries)

select *
into #terrtab
from terrtab

select YEARS, Territories, SUM(profit) as TotalProfit
from #terrtab
group by YEARS,territories
order by YEARS 

--3. Country that generated the highest profit in 2019
select *
from
(select distinct COUNTRIES,sum(PROFIT)over(partition by countries) as SumOfProfit
from int_breweries
where YEARS=2019) as HighProfit
order by HighProfit.SumOfProfit desc

--4. Help him find the year with the highest profit.
with profit_tab as
(select distinct YEARS,sum(PROFIT) over(partition by years)as ProfitSum
from int_breweries)

select years,ProfitSum
from profit_tab
order by profit_tab.ProfitSum desc

--5. Which month in the three years was the least profit generated?
drop table if exists #leastprofittab
;with profittab as
(select YEARS,MONTHS,sum(PROFIT) as ProfitSum
from int_breweries
group by YEARS,MONTHS)

select *
into #leastprofittab
from profittab

select YEARS,MONTHS,ProfitSum
from #leastprofittab
order by ProfitSum asc

--6. What was the minimum profit in the month of December 2018?

select min(PROFIT) as min_profit
from int_breweries
where MONTHS='december'and YEARS=2018

--7. Compare the profit in percentage for each of the month in 2019
select MONTHS,MonthProfit, round(MonthProfit/nullif(totalprofit,0),4)*100 as ProfitPercent
from
	(select distinct MONTHS,
		sum(PROFIT) over(partition by months) as MonthProfit,
		(select sum(PROFIT) from int_breweries where YEARS=2019)  as TotalProfit
	from int_breweries
	where YEARS=2019) as profit_tab
order by 2 desc

--8. Which particular brand generated the highest profit in Senegal?

select BRANDS,max(PROFIT) as max_profit
from int_breweries
where COUNTRIES = 'senegal'
group by brands 
order by max(PROFIT) desc

select distinct BRANDS,sum(PROFIT) over (partition by brands) as max_profit
from int_breweries
where COUNTRIES = 'senegal' 
order by 2 desc

--Session B
--BRAND ANALYSIS
--1. Within the last two years, the brand manager wants to know the top three brands
--consumed in the francophone countries
with qty_tab as
(select distinct BRANDS,count(QUANTITY) over(order by brands) as total_qty
from #terrtab
where Territories='francophone' and YEARS in (2019,2018)
),

qty_rnk as
(select *,
	DENSE_RANK() over(order by total_qty desc) as rnk
from qty_tab)

select BRANDS,total_qty
from qty_rnk
where rnk<4
order by 2 desc

--2. Find out the top two choice of consumer brands in Ghana

select distinct BRANDS,sum(QUANTITY)over(partition by brands) as CountOfQty
from int_breweries
where countries='ghana'
order by 2 desc

--3. Find out the details of beers consumed in the past three years in the most oil reached
--country in West Africa.
select  years,BRANDS,sum(QUANTITY) as CountOfQty
from int_breweries
where countries like 'nigeria' and BRANDS not like '%malt' 
group by years,brands
order by 1,3 desc

--4. Favorites malt brand in Anglophone region between 2018 and 2019
select distinct BRANDS,sum(QUANTITY) as CntQty
from #terrtab
where Territories='anglophone' and years>2017 and  BRANDS like '%malt'
group by BRANDS
order by 1 desc

--5. Which brands sold the highest in 2019 in Nigeria?

select BRANDS,sum(UNIT_PRICE*QUANTITY) as sumsales
from int_breweries
where COUNTRIES='nigeria' and YEARS=2019
group by BRANDS
order by 2 desc

--6. Favorites brand in South_South region in Nigeria
select BRANDS,sum(QUANTITY) as QtyCnt
from int_breweries
where COUNTRIES='nigeria' and [REGION ]='southsouth'
group by BRANDS
order by 2 desc

--7. Beer consumption in Nigeria
select BRANDS, sum(QUANTITY) as beer_count
from int_breweries
where COUNTRIES ='nigeria' and BRANDS not like '%malt'
group by BRANDS
order by 2 desc

--8. Level of consumption of Budweiser in the regions in Nigeria

select COUNTRIES,[REGION ],BRANDS,sum(QUANTITY) as qty
from int_breweries
where BRANDS='budweiser' and COUNTRIES='nigeria'
group by BRANDS,COUNTRIES,[REGION ]
order by 4 desc

--9. Level of consumption of Budweiser in the regions in Nigeria in 2019 (Decision on Promo)
select COUNTRIES,[REGION ],BRANDS,sum(QUANTITY) as qty
from int_breweries
where BRANDS='budweiser' and COUNTRIES='nigeria' and years=2019
group by BRANDS,COUNTRIES,[REGION ]
order by 4 desc

--Session C
--COUNTRIES ANALYSIS
--1. Country with the highest consumption of beer.

select COUNTRIES,BRANDS,sum(QUANTITY) as qty
from int_breweries
where BRANDS not like '%malt'
group by COUNTRIES,BRANDS
order by 3 desc

--2. Highest sales personnel of Budweiser in Senegal
select SALES_REP,sum(QUANTITY) qty
from int_breweries
where BRANDS='budweiser'and COUNTRIES='senegal'
group by sales_rep
order by 2 desc

--3. Country with the highest profit of the fourth quarter in 2019

select COUNTRIES,sum(PROFIT) ProfitSum
from int_breweries
where YEARS=2019 and MONTHS in ('october','november','december')
group by COUNTRIES
order by 2 desc
