from flask import render_template
from Sports_League import create_app, mysql  # Import create_app and mysql from __init__.py

app = create_app()

@app.route('/home')
def home():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM team")
    fetchdata = cur.fetchall()
    cur.close()
    return render_template('home.html', data=fetchdata)

@app.route('/team')
def team():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM Team")
    teams = cur.fetchall()
    cur.close()
    return render_template('team.html', teams=teams)

@app.route('/stadium')
def stadium():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM Stadium")
    stadiums = cur.fetchall()
    cur.close()
    return render_template('stadium.html', stadiums=stadiums)

@app.route('/team/<int:team_id>')
def team_players(team_id):
    cursor = mysql.connection.cursor()
    query = """
        SELECT P.Player_ID, CONCAT(P.First_Name, ' ', P.Last_Name) AS Player_Name, P.Role 
        FROM Player P
        WHERE P.Current_Team_ID = %s
    """
    cursor.execute(query, (team_id,))
    players = cursor.fetchall()
    cursor.close()
    return render_template('team_players.html', players=players)

@app.route('/player/<int:player_id>')
def player_details(player_id):
    cursor = mysql.connection.cursor()
    query = """
        SELECT Player_ID, CONCAT(First_Name, ' ', Last_Name) AS Full_Name, Nationality, Role, 
               Batting_Style, Bowling_Style, Total_Runs_Scored, Total_Wickets_Taken, 
               Total_Catches_Taken, Total_Matches_Played, Total_Half_Centuries, Total_Centuries 
        FROM Player 
        WHERE Player_ID = %s
    """
    cursor.execute(query, (player_id,))
    player = cursor.fetchone()
    cursor.close()
    return render_template('player_details.html', player=player)

if __name__ == "__main__":
    app.run(debug=True)
