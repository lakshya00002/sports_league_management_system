from flask import render_template, url_for, flash, redirect, request, Blueprint
from flask_login import login_user, current_user, logout_user, login_required
from Sports_League import mysql, bcrypt
from Sports_League.users.form import RegistrationForm, LoginForm, UpdateAccountForm
from Sports_League.users.utils import save_picture
from Sports_League.models import Admin

users = Blueprint('users', __name__)

# Helper function to convert fetched results to dictionary format
def dict_factory(cursor, row):
    return {col[0]: row[idx] for idx, col in enumerate(cursor.description)}

# Use a helper function to get a DictCursor
def get_dict_cursor():
    cur = mysql.connection.cursor()
    cur.row_factory = dict_factory  # Assign the factory for dictionary output
    return cur

@users.route("/register", methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('mysqlconnection.home'))
    form = RegistrationForm()
    if form.validate_on_submit():
        hashed_password = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        cur = mysql.connection.cursor()
        cur.execute(
            "INSERT INTO ADMIN (username, email, password) VALUES (%s, %s, %s)",
            (form.username.data, form.email.data, hashed_password)
        )
        mysql.connection.commit()
        cur.close()  # Close the cursor
        flash('Your account has been created! You are now able to log in', 'success')
        return redirect(url_for('users.login'))
    return render_template('register.html', title='Register', form=form)

@users.route("/login", methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('mysqlconnection.home'))
    form = LoginForm()
    if form.validate_on_submit():
        cur = mysql.connection.cursor()  # Get the cursor directly
        cur.execute(
            "SELECT * FROM ADMIN WHERE email = %s", (form.email.data,)
        )
        result = cur.fetchone()
        cur.close()  # Close the cursor
        
        # Debugging: Print the fetched result
        print(f"Fetched result: {result}")

        if result:  # Check if any result is returned
            if bcrypt.check_password_hash(result[3], form.password.data):  # Change 'result[3]' to the correct index for the password
                # Adjust index based on your schema
                user = Admin(result[0], result[1], result[2])  # Adjust indices for Admin_ID, username, email
                login_user(user, remember=form.remember.data)
                next_page = request.args.get('next')
                return redirect(next_page) if next_page else redirect(url_for('mysqlconnection.home'))
            else:
                flash('Login Unsuccessful. Please check email and password', 'danger')
        else:
            flash('No user found with that email.', 'danger')
    return render_template('login.html', title='Login', form=form)

@users.route("/logout")
def logout():
    logout_user()
    return redirect(url_for('mysqlconnection.home'))

@users.route("/account", methods=['GET', 'POST'])
@login_required
def account():
    form = UpdateAccountForm()
    if form.validate_on_submit():
        picture_file = current_user.image_file  # Default to current image
        if form.picture.data:
            picture_file = save_picture(form.picture.data)
        cur = mysql.connection.cursor()
        cur.execute(
            "UPDATE ADMIN SET username = %s, email = %s, image_file = %s WHERE Admin_ID = %s",
            (form.username.data, form.email.data, picture_file, current_user.id)
        )
        mysql.connection.commit()  # Commit the transaction
        cur.close()  # Close the cursor
        flash('Your account has been updated!', 'success')
        return redirect(url_for('users.account'))
    elif request.method == 'GET':
        form.username.data = current_user.username
        form.email.data = current_user.email
    image_file = url_for('static', filename='profile_pics/' + current_user.image_file)
    return render_template('account.html', title='Account', image_file=image_file, form=form)
