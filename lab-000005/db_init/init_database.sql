-- Database initialization script for AWS FCJ Management
-- This script creates necessary tables and populates them with initial data


USE awsfcjuser;

-- Create tables
CREATE TABLE IF NOT EXISTS user
(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `first_name` VARCHAR(45) NOT NULL,
    `last_name` VARCHAR(45) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` VARCHAR(15) NOT NULL,
    `comments` TEXT NOT NULL,
    `status` ENUM('active', 'inactive') NOT NULL DEFAULT 'active'
) ENGINE = InnoDB;

-- Insert sample data
INSERT INTO user
(`first_name`, `last_name`, `email`, `phone`, `comments`, `status`)
VALUES
('Amanda', 'Nunes', 'anunes@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Alexander', 'Volkanovski', 'avolkanovski@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Khabib', 'Nurmagomedov', 'knurmagomedov@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Kamaru', 'Usman', 'kusman@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Israel', 'Adesanya', 'iadesanya@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Henry', 'Cejudo', 'hcejudo@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Valentina', 'Shevchenko', 'vshevchenko@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Tyron', 'Woodley', 'twoodley@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Rose', 'Namajunas', 'rnamajunas@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Tony', 'Ferguson', 'tferguson@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Jorge', 'Masvidal', 'jmasvidal@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Nate', 'Diaz', 'ndiaz@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Conor', 'McGregor', 'cmcGregor@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Cris', 'Cyborg', 'ccyborg@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Tecia', 'Torres', 'ttorres@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Ronda', 'Rousey', 'rrousey@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Holly', 'Holm', 'hholm@ufc.com', '012345 678910', 'I love AWS FCJ', 'active'),
('Joanna', 'Jedrzejczyk', 'jjedrzejczyk@ufc.com', '012345 678910', 'I love AWS FCJ', 'active');
