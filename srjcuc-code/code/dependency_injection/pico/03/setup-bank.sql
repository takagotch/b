CREATE DATABASE bank;
CREATE USER 'teller'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON bank.* TO 'teller'@'localhost';