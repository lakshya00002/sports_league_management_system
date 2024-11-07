from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileAllowed
from wtforms import StringField, PasswordField, SubmitField, BooleanField
from wtforms.validators import DataRequired, Length, Email, EqualTo, ValidationError
from flask_login import current_user
from Sports_League import mysql  # Assuming you've imported the `mysql` object from your main app

class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired(), Length(min=2, max=20)])
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    confirm_password = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Sign Up')

    def validate_username(self, username):
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM ADMIN WHERE username = %s", (username.data,))
        result = cur.fetchone()
        cur.close()
        if result:
            raise ValidationError('That username is taken. Please choose a different one.')

    def validate_email(self, email):
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM ADMIN WHERE email = %s", (email.data,))
        result = cur.fetchone()
        cur.close()
        if result:
            raise ValidationError('That email is taken. Please choose a different one.')

class LoginForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')

class UpdateAccountForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired(), Length(min=2, max=20)])
    email = StringField('Email', validators=[DataRequired(), Email()])
    picture = FileField('Update Profile Picture', validators=[FileAllowed(['jpg', 'png'])])
    submit = SubmitField('Update')

    def validate_username(self, username):
        if username.data != current_user.username:
            cur = mysql.connection.cursor()
            cur.execute("SELECT * FROM ADMIN WHERE username = %s", (username.data,))
            result = cur.fetchone()
            cur.close()
            if result:
                raise ValidationError('That username is taken. Please choose a different one.')

    def validate_email(self, email):
        if email.data != current_user.email:
            cur = mysql.connection.cursor()
            cur.execute("SELECT * FROM ADMIN WHERE email = %s", (email.data,))
            result = cur.fetchone()
            cur.close()
            if result:
                raise ValidationError('That email is taken. Please choose a different one.')

class RequestResetForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    submit = SubmitField('Request Password Reset')

    def validate_email(self, email):
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM ADMIN WHERE email = %s", (email.data,))
        result = cur.fetchone()
        cur.close()
        if result is None:
            raise ValidationError('There is no account with that email. You must register first.')

class ResetPasswordForm(FlaskForm):
    password = PasswordField('Password', validators=[DataRequired()])
    confirm_password = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Reset Password')
