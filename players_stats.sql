/*
Project Title: Premier League Player Statistics Analysis
   Introduction
The purpose of this project is to analyze the statistics of Premier League players using SQL queries. The dataset used contains detailed information about player performance, including appearances, goals, assists, tackles, and more. By querying this dataset, we aim to gain insights into player performance, team statistics, and identify notable trends or patterns.

   Dataset Description
The dataset used in this project is the Premier League Player Statistics dataset. It contains information about various player attributes and performance statistics. The dataset includes the following columns:

Name: Player's name
Jersey Number: Player's jersey number
Club: Player's club/team
Position: Player's position on the field
Nationality: Player's nationality
Age: Player's age
Appearances: Number of appearances
Wins: Number of wins
Losses: Number of losses
Goals: Number of goals scored
Goals per match: Average number of goals per match
Headed goals: Number of goals scored with a header
Goals with right foot: Number of goals scored with the right foot
Goals with left foot: Number of goals scored with the left foot
Penalties scored: Number of penalties scored
Freekicks scored: Number of freekicks scored
Shots: Total number of shots attempted
Shots on target: Number of shots on target
Shooting accuracy %: Percentage of shots on target
Hit woodwork: Number of shots hitting the woodwork
Big chances missed: Number of big scoring chances missed
Clean sheets: Number of clean sheets (for goalkeepers)
Goals conceded: Number of goals conceded (for goalkeepers)
Tackles: Number of tackles
Tackle success %: Percentage of successful tackles
Last man tackles: Number of last man tackles
Blocked shots: Number of shots blocked
Interceptions: Number of interceptions
Clearances: Number of clearances
Headed Clearance: Number of clearances with a header
Clearances off line: Number of clearances off the goal line
Recoveries: Number of ball recoveries
Duels won: Number of duels won
Duels lost: Number of duels lost
Successful 50/50s: Number of successful 50/50 challenges
Aerial battles won: Number of aerial battles won
Aerial battles lost: Number of aerial battles lost
Own goals: Number of own goals
Errors leading to goal: Number of errors leading to a goal
Assists: Number of assists
Passes: Total number of passes
Passes per match: Average number of passes per match
Big chances created: Number of big scoring chances created
Crosses: Number of crosses
Cross accuracy %: Percentage of successful crosses
Through balls: Number of successful through balls
Accurate long balls: Number of accurate long balls
Saves: Number of saves (for goalkeepers)
Penalties saved: Number of penalties saved (for goalkeepers)
Punches: Number of punches (for goalkeepers)
High Claims: Number of high claims (for goalkeepers)
Catches: Number of catches (for goalkeepers)
Sweeper clearances: Number of sweeper clearances (for goalkeepers)
Throw outs: Number of throw-outs (for goalkeepers)
Goal Kicks: Number of goal kicks (for goalkeepers)
Yellow cards: Number of yellow cards received
Red cards: Number of red cards received
Fouls: Number of fouls committed
Offsides: Number of offsides
*/




use Premier_League_Player_Statistics
-- Return a list of all the columns in the players_stat table, along with their data types
SELECT column_name, data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'players_stat'

--View all the data in the table
SELECT *
FROM dbo.players_stat

--Select the name, club and position for every player groupped by the club name
select Club, Name, Position 
from dbo.players_stat 
group by Club, Name, Position


--Count the number of players from each nationality:
select Nationality, COUNT(*) as Number_of_players
from dbo.players_stat
group by Nationality

--Find the top goal scorers in the Premier League:
SELECT Name, Goals 
FROM dbo.players_stat 
ORDER BY Goals DESC

--Calculate the total number of goals scored by all players:
SELECT SUM(Goals) AS Total_Goals 
FROM dbo.players_stat ;

--Calculate the average number of goals per match:
SELECT
     ROUND(AVG(Goals),2) AS Average_Goals_Per_Match 
FROM dbo.players_stat ;


--Get the players with the highest number of assists:
SELECT Name, Assists 
FROM dbo.players_stat  
ORDER BY Assists DESC;

--Find the average age of players in the dataset:
SELECT ROUND(AVG(Age),2) AS Average_Age 
FROM dbo.players_stat ;

--Determine the player with the most appearances:
SELECT Name, Appearances 
FROM dbo.players_stat 
WHERE Appearances = (SELECT MAX(Appearances) FROM dbo.players_stat);

--Calculate the percentage of shots on target for each player:
SELECT 
    Name, 
    ROUND((Shots_on_target / NULLIF(Shots, 0)) * 100, 2) AS Shot_Accuracy_Percentage
FROM dbo.players_stat
WHERE Shots <> 0;

--Find the clubs with the most goals scored:
SELECT Club, SUM(Goals) AS Total_Goals 
FROM Premier_League_Player_Statistics.dbo.players_stat 
GROUP BY Club 
ORDER BY Total_Goals DESC;

--Calculate the number of clean sheets per team:
select Club, sum(Clean_sheets) as Nbr_Clean_Sheets_Per_Team
from dbo.players_stat
group by Club
order by Nbr_Clean_Sheets_Per_Team desc

--Calculate the number of goals per team:
select Club, sum(goals) as Number_Of_Goals
from dbo.players_stat
group by Club 
order by Number_Of_Goals desc

select position, count(*) from dbo.players_stat group by position

--Create view contain all the defenders:

CREATE VIEW defenders AS
SELECT ROW_NUMBER() OVER (ORDER BY Name) AS ID,
       Name,
       Jersey_number,
       Club,
       Nationality,
       Age,
       Appearances
FROM dbo.players_stat
WHERE Position = 'Defender';

--Create a view contain information related to defence:
create view info_defenders 
as
  select d.ID, 
         Tackles, 
		 Tackle_success, 
		 Last_man_tackles, 
		 Interceptions, 
		 Clearances, 
		 Clearances_off_line, 
		 Headed_Clearance,
         Recoveries,
		 Duels_won, 
		 Duels_lost,
		 Aerial_battles_won, 
		 Aerial_battles_lost, 
		 Own_goals, 
		 Errors_leading_to_goal, 
		 Passes
  from dbo.players_stat p
  join defenders d
  on d.Name = p.Name
  where position = 'Defender'

create view punches 
as 
  select d.id, yellow_cards, red_cards, fouls
  from dbo.players_stat p
  join defenders d
  on d.Name = p.Name
  where position = 'Defender'
  select * from punches order by id
 select * from defenders d 
 join info_defenders i 
 on d.id = i.id 
 select * from info_defenders order by id  

--Averge age of the defenders for each team:
select Club, round(avg(age),2) as Averge_Age
from defenders
group by club

--Number of defenders per team:
select club, count(i.id) as Number_Of_Defenders
from defenders d
join info_defenders i
on d.id = i.id
group by club

--The top 5 defenders with the highest tackle success rate:
select  Name, (Tackle_success / iif(Tackles=0, 1, Tackles)) * 100 as TackleSuccessRate
from info_defenders i
join defenders d
on d.id = i.id
order by TackleSuccessRate desc;

--Club has the highest number of appearances by defenders:
select Club, SUM(Appearances) as TotalAppearances
from defenders d
join info_defenders i
on d.id = i.id
group by Club
order by TotalAppearances desc;

--The average number of interceptions per match for defenders aged 25 or younger:
select round(avg(Interceptions / iif(Appearances=0, null,Appearances)),2) as AverageInterceptionsPerMatch
FROM info_defenders i
join defenders d
on i.id = d.id
WHERE Age <= 25;

--Defenders has the highest number of duels won and duels lost:
select name, Duels_won, Duels_lost
from defenders d
join info_defenders i
on d.id = i.id
where Duels_won = (select max(Duels_won) from info_defenders) 
      or
	  Duels_lost = (select max(Duels_lost) from info_defenders)


--Percentage of wining duel:
select name, round((duels_won / nullif(Duels_won + Duels_lost,0)) * 100,2) as Percentage_win_duel
from defenders d
join info_defenders i
on d.id = i.id

--Averge cleranceces per team:
select club, round(avg(Clearances),2) as Averge_Clearances
from defenders d
join info_defenders i
on d.id = i.id
group by club
order by Averge_Clearances desc

--Top defenders has more Clearances:
select top 10 name, Clearances
from defenders d
join info_defenders i
on d.id = i.id
order by Clearances desc

--Top defenders has more Clearances off line:
select top 10 name, Clearances_off_line
from defenders d
join info_defenders i
on d.id = i.id
order by Clearances_off_line desc

--Top defenders with header clearences:
select top 10 name, Headed_Clearance
from defenders d
join info_defenders i
on d.id = i.id
order by Headed_Clearance desc

--Best defenders on  Aerial battles:
select name, Aerial_battles_won
from defenders d
join info_defenders i
on d.id = i.id
where 
Aerial_battles_won > Aerial_battles_lost
order by Aerial_battles_won desc

--The top 10 defenders with the highest Aerial battles rate:
select top 10 name, round((aerial_battles_won / nullif(aerial_battles_won + Aerial_battles_lost,0)) * 100 ,2) as Rate
from defenders d
join info_defenders i
on d.id = i.id
order by Rate desc

--defenders have the highest pass completion rate:
select Name, round((Passes / (nullif(Passes + Errors_leading_to_goal,0))) * 100,2) as PassCompletionRate
from defenders d
join info_defenders i
on d.id = i.id
order by PassCompletionRate desc

--Players with their number of tackles and cards:
select name, tackles, yellow_cards, red_cards
from defenders d 
join info_defenders i on i.id = d.id 
join punches p on p.id = i.id
order by Tackles desc

--Most defenders make fouls:
select name, fouls as Number_of_fouls
from defenders d 
join punches p
on d.id = p.id
order by Number_of_fouls desc

--teams with the highest numbers of cards:
select club, sum(Yellow_cards)+ sum(Red_cards) as Number_of_cards
from defenders d 
join punches p
on d.id = p.id
group by club
order by Number_of_cards desc

--Retrieve the players who have scored goals with both their left and right foot:
select Name, Goals_with_left_foot, Goals_with_right_foot
from dbo.players_stat
where Goals_with_left_foot > 0 AND Goals_with_right_foot > 0

--Find the player with the highest passing accuracy 
select top 1 Name, Passes, Passes_per_match, round(Passes / nullif(Passes_per_match,0),2) as PassingAccuracy
from dbo.players_stat
order by PassingAccuracy desc;

--Calculate the percentage contribution of each player's goals to their club's total goals:
select Club, Name, Goals, SUM(Goals) over (partition by Club) as TotalClubGoals,
       round((Goals / NULLIF(SUM(Goals) over (partition by Club), 0)) * 100,2) as ContributionPercentage
from dbo.players_stat;
--Most scorers with number nine:
select name, goals
from dbo.players_stat
where Jersey_Number = 9
order by goals desc

/*
Conclusion:
In conclusion, this project utilized SQL queries to analyze the Premier League player statistics dataset. 
By querying the dataset, we were able to derive valuable insights into player performance, team statistics, and various aspects of the game. 
The analysis revealed notable trends, such as the top goal scorers, assists leaders, average age of players, and more. 
These insights can be used to assess player performance, evaluate team strategies, and make data-driven decisions in the context of the Premier League.
*/






