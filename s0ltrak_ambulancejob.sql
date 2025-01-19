--
-- 1) Création (ou mise à jour) du job ambulance
--

-- Ajout du job ambulance dans la table jobs
INSERT IGNORE INTO `jobs` (`name`, `label`) 
VALUES ('ambulance', 'Ambulance');

-- Ajout de grades par défaut pour le job ambulance
INSERT IGNORE INTO `job_grades` 
(`job_name`, `grade`, `name`, `label`, `salary`) 
VALUES
('ambulance', 0, 'recruit',     'Recrue EMS',   150),
('ambulance', 1, 'ambulancier', 'Ambulancier',  250),
('ambulance', 2, 'medecin',     'Médecin',      350),
('ambulance', 3, 'boss',        'Chef EMS',     600);

--
-- 2) Ajout de la colonne is_dead dans la table users (si vous voulez la mort persistante)
--   Ajustez la position de la colonne (AFTER ...) selon votre structure.
--   IF NOT EXISTS n’est pas reconnu sur toutes les versions MySQL/MariaDB.
--   Si vous avez déjà la colonne, vous pouvez ignorer cette requête.
--

ALTER TABLE `users` 
  ADD COLUMN `is_dead` TINYINT(1) NOT NULL DEFAULT 0 
  AFTER `status`
;

--
-- 3) Création de la table owned_vehicles si elle n’existe pas encore
--   (Permet de stocker les véhicules achetés par les joueurs avec un job, etc.)
--

CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `owner` VARCHAR(60) NOT NULL,
  `plate` VARCHAR(20) NOT NULL,
  `vehicle` LONGTEXT NOT NULL,
  `type` VARCHAR(20) NOT NULL DEFAULT 'car',
  `job` VARCHAR(20) DEFAULT NULL,
  `stored` TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 4) Insertion des items “wheelchair” et “bed” (fauteuil roulant & lit médical) 
--   dans la table items (si vous utilisez la table items d’ESX).
--   La colonne "weight" peut dépendre de la config. Sur certains ESX, c’est "weight",
--   sur d’autres, ce sont des colonnes comme "limit" ou "usable".
--

INSERT IGNORE INTO `items` (`name`, `label`, `weight`) 
VALUES
('wheelchair', 'Fauteuil Roulant', 1),
('bed',        'Lit Médical',      1);

--
-- 5) Création de la “société” ambulance (society_ambulance) dans les tables 
--   addon_account / addon_inventory / datastore, utilisées par esx_society.
--   Si vous n’utilisez pas esx_society, vous pouvez ignorer cette partie.
--

INSERT IGNORE INTO `addon_account` (`name`, `label`, `shared`) 
VALUES ('society_ambulance', 'Ambulance', 1);

INSERT IGNORE INTO `addon_inventory` (`name`, `label`, `shared`) 
VALUES ('society_ambulance', 'Ambulance', 1);

INSERT IGNORE INTO `datastore` (`name`, `label`, `shared`) 
VALUES ('society_ambulance', 'Ambulance', 1);
