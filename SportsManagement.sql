CREATE DATABASE SPORTS_LEAGUE;

USE SPORTS_LEAGUE;

CREATE TABLE Stadium (
	Stadium_ID INT PRIMARY KEY AUTO_INCREMENT,
	Stadium_Name VARCHAR(60) NOT NULL,
	City VARCHAR(60) NOT NULL,
	Country VARCHAR(60) NOT NULL,
	Capacity INT CHECK (Capacity > 0),
	Pitch_Type VARCHAR(100),
	Average_First_Innings_Score INT CHECK (Average_First_Innings_Score >= 0),
	Total_Matches_Hosted INT DEFAULT 0 CHECK (Total_Matches_Hosted >= 0)
);

CREATE TABLE Coach (
	Coach_ID INT PRIMARY KEY AUTO_INCREMENT,
	First_Name VARCHAR(55) NOT NULL,
	Last_Name VARCHAR(55) NOT NULL,
	Nationality VARCHAR(55),
	Coach_Role ENUM('Head Coach', 'Batting Coach', 'Bowling Coach') NOT NULL,
	Years_Of_Experience INT CHECK (Years_Of_Experience >= 0)
);

CREATE TABLE Team (
	Team_ID INT PRIMARY KEY AUTO_INCREMENT,
    Team_Name VARCHAR(50) NOT NULL,
    City VARCHAR(30) NOT NULL,
    Coach_ID INT,
    Team_Founding_Year DATE,
    Total_Titles_Won INT DEFAULT 0 CHECK (Total_Titles_Won >= 0),
    Team_Logo BLOB, -- Consider moving this to a file server for better performance
    Team_Dress_Colour VARCHAR(20),
    Team_Website_Link VARCHAR(50),
    Team_Net_Worth DECIMAL(15, 2) CHECK (Team_Net_Worth >= 0),
    Home_Stadium_ID INT,
    FOREIGN KEY (Coach_ID) REFERENCES Coach (Coach_ID) ON UPDATE CASCADE,
    FOREIGN KEY (Home_Stadium_ID) REFERENCES Stadium (Stadium_ID) ON UPDATE CASCADE
);

CREATE TABLE Player (
	Player_ID INT PRIMARY KEY AUTO_INCREMENT,
	First_Name VARCHAR(50) NOT NULL,
	Last_Name VARCHAR(50) NOT NULL,
	Date_Of_Birth DATE , 
	Nationality VARCHAR(55),
	Role ENUM('Batsman', 'Bowler', 'All-rounder', 'Wicketkeeper') NOT NULL, -- ENUM for consistency
	Batting_Style ENUM('Right_handed', 'Left_handed') NOT NULL,
	Bowling_Style ENUM('Right_arm Fast', 'Left_arm Fast', 'Left_arm Spin', 'Right_arm Spin') NULL,
	Total_Runs_Scored INT DEFAULT 0 CHECK (Total_Runs_Scored >= 0),
	Total_Wickets_Taken INT DEFAULT 0 CHECK (Total_Wickets_Taken >= 0),
	Total_Catches_Taken INT DEFAULT 0 CHECK (Total_Catches_Taken >= 0),
	Total_Matches_Played INT DEFAULT 0 CHECK (Total_Matches_Played >= 0),
	Total_Half_Centuries INT DEFAULT 0 CHECK (Total_Half_Centuries >= 0),
	Total_Centuries INT DEFAULT 0 CHECK (Total_Centuries >= 0),
	Base_Price INT CHECK (Base_Price >= 0),
	Current_Team_ID INT,
	IPL_Debut_Year DATE CHECK (IPL_Debut_Year >= '2008-01-01'), -- IPL started in 2008
	International_Career_Start DATE,
	Total_IPL_Trophies_Won INT DEFAULT 0 CHECK (Total_IPL_Trophies_Won >= 0),
	FOREIGN KEY (Current_Team_ID) REFERENCES Team (Team_ID) ON UPDATE CASCADE
);

CREATE TABLE Umpire (
	Umpire_ID INT PRIMARY KEY AUTO_INCREMENT,
	First_Name VARCHAR(20) NOT NULL,
	Last_Name VARCHAR(20) NOT NULL,
	Nationality VARCHAR(20),
	Total_Matches INT DEFAULT 0 CHECK (Total_Matches >= 0),
	Date_Of_Birth DATE ,
	Umpire_Rating INT CHECK (Umpire_Rating BETWEEN 0 AND 10)
);

CREATE TABLE Sponsorship (
	Sponsorship_ID INT PRIMARY KEY AUTO_INCREMENT,
	Team_ID INT,
	Sponsor_Name VARCHAR(200) NOT NULL,
	Sponsorship_Type VARCHAR(200) NOT NULL,
	Contract_Start_Year DATE,
	Contract_End_Year DATE,
	Sponsorship_Amount DECIMAL(15, 2) CHECK (Sponsorship_Amount >= 0),
	FOREIGN KEY (Team_ID) REFERENCES Team (Team_ID)
);

CREATE TABLE Contract (
	Contract_ID INT PRIMARY KEY AUTO_INCREMENT,
	Player_ID INT,
	Contract_Start_Year DATE NOT NULL,
	Contract_End_Year DATE NOT NULL,
	Amount DECIMAL(15, 2) CHECK (Amount >= 0),
	Team_ID INT,
	FOREIGN KEY (Player_ID) REFERENCES Player (Player_ID),
	FOREIGN KEY (Team_ID) REFERENCES Team (Team_ID)
);

CREATE TABLE Season (
	Season_ID INT PRIMARY KEY AUTO_INCREMENT,
	Year YEAR CHECK (Year >= 2008), -- IPL started in 2008
	Total_Matches_Played INT DEFAULT 0 CHECK (Total_Matches_Played >= 0),
	Winning_Team_ID INT,
	Runner_Team_ID INT,
	Orange_Cap_Winner_ID INT,
	Purple_Cap_Winner_ID INT,
	FOREIGN KEY (Winning_Team_ID) REFERENCES Team (Team_ID),
	FOREIGN KEY (Runner_Team_ID) REFERENCES Team (Team_ID),
	FOREIGN KEY (Orange_Cap_Winner_ID) REFERENCES Player (Player_ID),
	FOREIGN KEY (Purple_Cap_Winner_ID) REFERENCES Player (Player_ID)
);

CREATE TABLE Matches (
	Match_ID INT AUTO_INCREMENT PRIMARY KEY,
	Season_ID INT,
	Team1_ID INT,
	Team2_ID INT,
	Match_Date DATETIME CHECK (Match_Date >= '2008-01-01'), -- IPL started in 2008
	Umpire1_ID INT,
	Umpire2_ID INT,
	Match_Result VARCHAR(200),
	Team1_Score INT DEFAULT 0 CHECK (Team1_Score >= 0),
	Team2_Score INT DEFAULT 0 CHECK (Team2_Score >= 0),
	Winning_Margin VARCHAR(255),
	Total_Overs_Bowled INT CHECK (Total_Overs_Bowled BETWEEN 0 AND 40),
	Match_Type ENUM('League', 'Qualifier', 'Eliminator', 'Final') NOT NULL,
	Stadium_ID INT,
	FOREIGN KEY (Season_ID) REFERENCES Season (Season_ID) ON DELETE CASCADE,
	FOREIGN KEY (Team1_ID) REFERENCES Team (Team_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Team2_ID) REFERENCES Team (Team_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Umpire1_ID) REFERENCES Umpire (Umpire_ID) ON UPDATE CASCADE,
	FOREIGN KEY (Umpire2_ID) REFERENCES Umpire (Umpire_ID) ON UPDATE CASCADE,
	FOREIGN KEY (Stadium_ID) REFERENCES Stadium (Stadium_ID) ON UPDATE CASCADE
);

CREATE TABLE Inning (
	Innings_ID INT PRIMARY KEY AUTO_INCREMENT,
	Match_ID INT,
	Team_Batting_ID INT,
	Total_Runs INT DEFAULT 0 CHECK (Total_Runs >= 0),
	Total_Wickets INT DEFAULT 0 CHECK (Total_Wickets BETWEEN 0 AND 10),
	Overs_Faced DECIMAL(4,2) CHECK (Overs_Faced >= 0 AND Overs_Faced <= 20),
	Inning_Number ENUM('1st Inning', '2nd Inning') NOT NULL,
	FOREIGN KEY (Match_ID) REFERENCES Matches (Match_ID),
	FOREIGN KEY (Team_Batting_ID) REFERENCES Team (Team_ID)
);

CREATE TABLE Statistics (
	Stat_ID INT PRIMARY KEY AUTO_INCREMENT,
	Player_ID INT,
	Season_ID INT,
	Matches_Played INT DEFAULT 0 CHECK (Matches_Played >= 0),
	Runs_Scored INT DEFAULT 0 CHECK (Runs_Scored >= 0),
	Wickets_Taken INT DEFAULT 0 CHECK (Wickets_Taken >= 0),
	Catches_Taken INT DEFAULT 0 CHECK (Catches_Taken >= 0),
	Fours INT DEFAULT 0 CHECK (Fours >= 0),
	Sixes INT DEFAULT 0 CHECK (Sixes >= 0),
	Strike_Rate DECIMAL(5, 2) DEFAULT 0 CHECK (Strike_Rate >= 0),
	Economy_Rate DECIMAL(3,1) DEFAULT 0 CHECK (Economy_Rate >= 0),
	Bowling_Average DECIMAL(5, 2) DEFAULT 0 CHECK (Bowling_Average >= 0),
	Batting_Average DECIMAL(5, 2) DEFAULT 0 CHECK (Batting_Average >= 0),
	FOREIGN KEY (Player_ID) REFERENCES Player (Player_ID),
	FOREIGN KEY (Season_ID) REFERENCES Season (Season_ID)
);

CREATE TABLE Ball (
	Ball_ID INT PRIMARY KEY AUTO_INCREMENT,
	Inning_ID INT,
	Bowler_ID INT,
	Batsman_ID INT,
	Non_striker_ID INT,
	Run_Scored INT DEFAULT 0 CHECK (Run_Scored >= 0),
	Is_Wicket BOOLEAN DEFAULT FALSE,
	Is_NoBall BOOLEAN DEFAULT FALSE,
	Is_Wide BOOLEAN DEFAULT FALSE,
	Is_LegBye BOOLEAN DEFAULT FALSE,
    Ball_Over INT CHECK (Ball_Over BETWEEN 1 AND 20),
	Ball_Number INT CHECK (Ball_Number BETWEEN 1 AND 6), -- Each over has 6 balls max
	FOREIGN KEY (Inning_ID) REFERENCES Inning (Innings_ID),
	FOREIGN KEY (Bowler_ID) REFERENCES Player (Player_ID),
	FOREIGN KEY (Batsman_ID) REFERENCES Player (Player_ID),
	FOREIGN KEY (Non_striker_ID) REFERENCES Player (Player_ID)
);

CREATE TABLE TeamCaptain (
	TeamCaptain_ID INT PRIMARY KEY AUTO_INCREMENT,
	Team_ID INT,
	Player_ID INT,
	Start_Date DATE,
	End_Date DATE,
	FOREIGN KEY (Team_ID) REFERENCES Team (Team_ID),
	FOREIGN KEY (Player_ID) REFERENCES Player (Player_ID)
);
