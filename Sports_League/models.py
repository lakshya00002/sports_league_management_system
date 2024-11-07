from flask_mysqldb import MySQL

mysql = MySQL()
class Admin:
    def __init__(self, admin_id, username, email, image_file):
        self.id = admin_id
        self.username = username
        self.email = email
        self.image_file = image_file

    @classmethod
    def get(cls, admin_id):
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT * FROM ADMIN WHERE Admin_ID = %s", (admin_id,))
        result = cursor.fetchone()
        cursor.close()
        if result:
            return cls(result['Admin_ID'], result['username'], result['email'], result['image_file'])
        return None
