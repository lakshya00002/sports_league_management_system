from flask import Flask
from flask_bcrypt import Bcrypt
from flask_mysqldb import MySQL
from flask_login import LoginManager
from Sports_League.models import Admin

# Initialize extensions
mysql = MySQL()
bcrypt = Bcrypt()
login_manager = LoginManager()
login_manager.login_view = 'users.login'
login_manager.login_message_category = 'info'

@login_manager.user_loader
def load_user(Admin_id):
    return Admin.get(Admin_id)

def create_app():
    app = Flask(__name__)
    
    # Application configuration
    app.config['MYSQL_HOST'] = 'localhost'
    app.config['MYSQL_USER'] = 'root'
    app.config['MYSQL_PASSWORD'] = 'Lakshay'
    app.config['MYSQL_DB'] = 'sports_league'
    app.config['SECRET_KEY'] = 'your_secret_key'  # Required for session management

    # Initialize extensions with app
    mysql.init_app(app)
    bcrypt.init_app(app)
    login_manager.init_app(app)

    # Register blueprints
    from Sports_League.users.routes import users
    app.register_blueprint(users)

    return app
