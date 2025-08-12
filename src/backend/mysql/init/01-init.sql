-- Initialize databases and grant privileges
CREATE DATABASE IF NOT EXISTS `campaign-service` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `company-service` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `driver-service` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `auth-service` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'ad_on_wheels_user'@'%' IDENTIFIED BY 'test';
GRANT ALL PRIVILEGES ON `campaign-service`.* TO 'ad_on_wheels_user'@'%';
GRANT ALL PRIVILEGES ON `company-service`.* TO 'ad_on_wheels_user'@'%';
GRANT ALL PRIVILEGES ON `driver-service`.* TO 'ad_on_wheels_user'@'%';
GRANT ALL PRIVILEGES ON `auth-service`.* TO 'ad_on_wheels_user'@'%';

FLUSH PRIVILEGES;


