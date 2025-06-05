-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: mysql
-- Erstellungszeit: 05. Jun 2025 um 07:09
-- Server-Version: 9.2.0
-- PHP-Version: 8.2.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `TS-Lager`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `brands`
--

CREATE TABLE `brands` (
  `brandID` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `manufacturerID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `categories`
--

CREATE TABLE `categories` (
  `categoryID` int NOT NULL,
  `name` varchar(20) NOT NULL,
  `abbreviation` varchar(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `customers`
--

CREATE TABLE `customers` (
  `customerID` int NOT NULL,
  `companyname` varchar(100) DEFAULT NULL,
  `lastname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `firstname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `street` varchar(100) DEFAULT NULL,
  `housenumber` varchar(20) DEFAULT NULL,
  `ZIP` varchar(20) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `federalstate` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `phonenumber` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `customertype` varchar(50) DEFAULT NULL,
  `notes` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `devices`
--

CREATE TABLE `devices` (
  `deviceID` varchar(50) NOT NULL,
  `productID` int DEFAULT NULL,
  `serialnumber` varchar(50) DEFAULT NULL,
  `purchaseDate` date DEFAULT NULL,
  `lastmaintenance` date DEFAULT NULL,
  `nextmaintenance` date DEFAULT NULL,
  `insurancenumber` varchar(50) DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'free',
  `insuranceID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Trigger `devices`
--
DELIMITER $$
CREATE TRIGGER `devices` BEFORE INSERT ON `devices` FOR EACH ROW BEGIN
  DECLARE abkuerzung   VARCHAR(50);
  DECLARE pos_cat       INT;
  DECLARE next_counter  INT;

  -- 1) Abkürzung holen
  SELECT s.abbreviation
    INTO abkuerzung
    FROM subcategories s
    JOIN products      p ON s.subcategoryID = p.subcategoryID
   WHERE p.productID   = NEW.productID
   LIMIT 1;

  -- 2) pos_in_category holen
  SELECT p.pos_in_category
    INTO pos_cat
    FROM products p
   WHERE p.productID = NEW.productID;

  -- 3) Laufindex ermitteln (max. der letzten 3 Ziffern + 1)
  SELECT COALESCE(MAX(CAST(RIGHT(d.deviceID, 3) AS UNSIGNED)), 0) + 1
    INTO next_counter
    FROM devices d
   WHERE d.deviceID LIKE CONCAT(abkuerzung, pos_cat, '%');

  -- 4) deviceID zusammenbauen (ohne Bindestrich!)
  SET NEW.deviceID = CONCAT(
                        abkuerzung,
                        pos_cat,
                        LPAD(next_counter, 3, '0')
                      );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `devicestatushistory`
--

CREATE TABLE `devicestatushistory` (
  `statushistoryID` int NOT NULL,
  `deviceID` varchar(10) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `notes` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `device_earnings_summary`
-- (Siehe unten für die tatsächliche Ansicht)
--
CREATE TABLE `device_earnings_summary` (
`deviceID` varchar(50)
,`deviceName` varchar(50)
,`numJobs` bigint
,`totalEarnings` decimal(51,2)
);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `employee`
--

CREATE TABLE `employee` (
  `employeeID` int NOT NULL,
  `firstname` varchar(50) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `street` varchar(100) DEFAULT NULL,
  `housenumber` varchar(20) DEFAULT NULL,
  `ZIP` varchar(20) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `federalstate` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `phonenumber` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `employeejob`
--

CREATE TABLE `employeejob` (
  `employeeID` int NOT NULL,
  `jobID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `insuranceprovider`
--

CREATE TABLE `insuranceprovider` (
  `insuranceproviderID` int NOT NULL,
  `name` varchar(20) NOT NULL,
  `website` varchar(20) NOT NULL,
  `phonenumber` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `insurances`
--

CREATE TABLE `insurances` (
  `insuranceID` int NOT NULL,
  `name` varchar(20) NOT NULL,
  `insuranceproviderID` int NOT NULL,
  `policynumber` varchar(50) DEFAULT NULL,
  `coveragedetails` text,
  `validuntil` date DEFAULT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `jobCategory`
--

CREATE TABLE `jobCategory` (
  `jobcategoryID` int NOT NULL,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `abbreviation` varchar(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `jobdevices`
--

CREATE TABLE `jobdevices` (
  `jobID` int NOT NULL,
  `deviceID` varchar(10) NOT NULL,
  `custom_price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `jobs`
--

CREATE TABLE `jobs` (
  `jobID` int NOT NULL,
  `customerID` int DEFAULT NULL,
  `startDate` date DEFAULT NULL,
  `endDate` date DEFAULT NULL,
  `statusID` int DEFAULT NULL,
  `jobcategoryID` int DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL,
  `discount` decimal(10,2) DEFAULT '0.00',
  `discount_type` enum('percent','amount') DEFAULT 'amount',
  `revenue` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT 'Tatsächliche Einnahmen des Jobs in EUR',
  `final_revenue` decimal(10,2) DEFAULT NULL COMMENT 'Netto-Umsatz nach Rabatt'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Trigger `jobs`
--
DELIMITER $$
CREATE TRIGGER `jobs_before_insert` BEFORE INSERT ON `jobs` FOR EACH ROW BEGIN
  IF NEW.discount_type = 'percent' THEN
    -- Prozentualer Rabatt
    SET NEW.final_revenue = ROUND(
      NEW.revenue * (1 - NEW.discount/100),
      2
    );
  ELSE
    -- Fixer Betrag
    SET NEW.final_revenue = ROUND(
      GREATEST(NEW.revenue - NEW.discount, 0),
      2
    );
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `jobs_before_update` BEFORE UPDATE ON `jobs` FOR EACH ROW BEGIN
  IF NEW.discount_type = 'percent' THEN
    SET NEW.final_revenue = ROUND(
      NEW.revenue * (1 - NEW.discount/100),
      2
    );
  ELSE
    SET NEW.final_revenue = ROUND(
      GREATEST(NEW.revenue - NEW.discount, 0),
      2
    );
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `maintenanceLogs`
--

CREATE TABLE `maintenanceLogs` (
  `maintenanceLogID` int NOT NULL,
  `deviceID` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `employeeID` int DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `notes` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `manufacturer`
--

CREATE TABLE `manufacturer` (
  `manufacturerID` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `website` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `products`
--

CREATE TABLE `products` (
  `productID` int NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `categoryID` int DEFAULT NULL,
  `subcategoryID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `subbiercategoryID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `manufacturerID` int DEFAULT NULL,
  `brandID` int DEFAULT NULL,
  `description` text,
  `maintenanceInterval` int DEFAULT NULL,
  `itemcostperday` decimal(10,2) DEFAULT NULL,
  `weight` decimal(10,2) DEFAULT NULL,
  `height` decimal(10,2) DEFAULT NULL,
  `width` decimal(10,2) DEFAULT NULL,
  `depth` decimal(10,2) DEFAULT NULL,
  `powerconsumption` decimal(10,2) DEFAULT NULL,
  `pos_in_category` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Trigger `products`
--
DELIMITER $$
CREATE TRIGGER `pos_in_subcategory` BEFORE INSERT ON `products` FOR EACH ROW BEGIN
  DECLARE next_pos INT;

  -- Ermittele die höchste bereits vergebene Position in dieser Subkategorie
  SELECT COALESCE(MAX(pos_in_category), 0) + 1
    INTO next_pos
    FROM products
   WHERE subcategoryID = NEW.subcategoryID;

  -- Setze das neue pos_in_category-Feld
  SET NEW.pos_in_category = next_pos;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `product_revenue`
-- (Siehe unten für die tatsächliche Ansicht)
--
CREATE TABLE `product_revenue` (
`product_name` varchar(50)
,`total_revenue` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `status`
--

CREATE TABLE `status` (
  `statusID` int NOT NULL,
  `status` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `subbiercategories`
--

CREATE TABLE `subbiercategories` (
  `subbiercategoryID` varchar(50) NOT NULL,
  `name` varchar(20) DEFAULT NULL,
  `abbreviation` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `subcategoryID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Trigger `subbiercategories`
--
DELIMITER $$
CREATE TRIGGER `before_insert_subbiercategory` BEFORE INSERT ON `subbiercategories` FOR EACH ROW BEGIN
    DECLARE subcat_abkuerzung VARCHAR(50);
    DECLARE naechste_nummer INT;
    
    -- Abkürzung aus der subcategories-Tabelle abrufen
    SELECT s.abbreviation INTO subcat_abkuerzung
    FROM subcategories s
    WHERE s.subcategoryID = NEW.subcategoryID
    LIMIT 1;
    
    -- Nächste verfügbare Nummer für diese Abkürzung finden
    SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(subbiercategoryID, subcat_abkuerzung, -1) AS UNSIGNED)), 1000) + 1 
    INTO naechste_nummer
    FROM subbiercategories sb
    JOIN subcategories s ON sb.subcategoryID = s.subcategoryID
    WHERE s.abbreviation = subcat_abkuerzung;
    
    -- subbiercategoryID setzen als Kombination aus Unterkategorie-Abkürzung und nächster Nummer
    SET NEW.subbiercategoryID = CONCAT(subcat_abkuerzung, naechste_nummer);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `subcategories`
--

CREATE TABLE `subcategories` (
  `subcategoryID` varchar(50) NOT NULL,
  `name` varchar(20) NOT NULL,
  `abbreviation` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `categoryID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Trigger `subcategories`
--
DELIMITER $$
CREATE TRIGGER `before_insert_subcategory` BEFORE INSERT ON `subcategories` FOR EACH ROW BEGIN
    DECLARE cat_abkuerzung VARCHAR(50);
    DECLARE naechste_nummer INT;
    
    -- Abkürzung aus der categories-Tabelle abrufen
    SELECT c.abbreviation INTO cat_abkuerzung
    FROM categories c
    WHERE c.categoryID = NEW.categoryID
    LIMIT 1;
    
    -- Nächste verfügbare Nummer für diese Abkürzung finden
    SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(subcategoryID, cat_abkuerzung, -1) AS UNSIGNED)), 1000) + 1 
    INTO naechste_nummer
    FROM subcategories s
    JOIN categories c ON s.categoryID = c.categoryID
    WHERE c.abbreviation = cat_abkuerzung;
    
    -- subcategoryID setzen als Kombination aus Kategorie-Abkürzung und nächster Nummer
    SET NEW.subcategoryID = CONCAT(cat_abkuerzung, naechste_nummer);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stellvertreter-Struktur des Views `view_device_product`
-- (Siehe unten für die tatsächliche Ansicht)
--
CREATE TABLE `view_device_product` (
`deviceID` varchar(50)
,`product_name` varchar(50)
,`productID` int
);

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`brandID`),
  ADD KEY `idx_brands_manufacturerID` (`manufacturerID`);

--
-- Indizes für die Tabelle `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`categoryID`);

--
-- Indizes für die Tabelle `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`customerID`);

--
-- Indizes für die Tabelle `devices`
--
ALTER TABLE `devices`
  ADD PRIMARY KEY (`deviceID`),
  ADD KEY `idx_devices_insuranceID` (`insuranceID`),
  ADD KEY `idx_devices_productID` (`productID`);

--
-- Indizes für die Tabelle `devicestatushistory`
--
ALTER TABLE `devicestatushistory`
  ADD PRIMARY KEY (`statushistoryID`),
  ADD KEY `idx_devicestatushistory_deviceID` (`deviceID`);

--
-- Indizes für die Tabelle `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`employeeID`);

--
-- Indizes für die Tabelle `employeejob`
--
ALTER TABLE `employeejob`
  ADD PRIMARY KEY (`employeeID`,`jobID`),
  ADD KEY `idx_employeejob_jobID` (`jobID`);

--
-- Indizes für die Tabelle `insuranceprovider`
--
ALTER TABLE `insuranceprovider`
  ADD PRIMARY KEY (`insuranceproviderID`);

--
-- Indizes für die Tabelle `insurances`
--
ALTER TABLE `insurances`
  ADD PRIMARY KEY (`insuranceID`),
  ADD KEY `insuranceproviderID` (`insuranceproviderID`);

--
-- Indizes für die Tabelle `jobCategory`
--
ALTER TABLE `jobCategory`
  ADD PRIMARY KEY (`jobcategoryID`);

--
-- Indizes für die Tabelle `jobdevices`
--
ALTER TABLE `jobdevices`
  ADD PRIMARY KEY (`jobID`,`deviceID`),
  ADD KEY `deviceID` (`deviceID`);

--
-- Indizes für die Tabelle `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`jobID`),
  ADD KEY `idx_jobs_customerID` (`customerID`),
  ADD KEY `idx_jobs_jobcategoryID` (`jobcategoryID`),
  ADD KEY `statusID` (`statusID`);

--
-- Indizes für die Tabelle `maintenanceLogs`
--
ALTER TABLE `maintenanceLogs`
  ADD PRIMARY KEY (`maintenanceLogID`),
  ADD KEY `idx_maintenanceLogs_deviceID` (`deviceID`),
  ADD KEY `idx_maintenanceLogs_employeeID` (`employeeID`);

--
-- Indizes für die Tabelle `manufacturer`
--
ALTER TABLE `manufacturer`
  ADD PRIMARY KEY (`manufacturerID`);

--
-- Indizes für die Tabelle `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`productID`),
  ADD KEY `idx_products_categoryID` (`categoryID`),
  ADD KEY `idx_products_manufacturerID` (`manufacturerID`),
  ADD KEY `idx_products_brandID` (`brandID`),
  ADD KEY `idx_products_subcategoryID` (`subcategoryID`),
  ADD KEY `idx_products_subbiercategoryID` (`subbiercategoryID`);

--
-- Indizes für die Tabelle `status`
--
ALTER TABLE `status`
  ADD PRIMARY KEY (`statusID`);

--
-- Indizes für die Tabelle `subbiercategories`
--
ALTER TABLE `subbiercategories`
  ADD PRIMARY KEY (`subbiercategoryID`),
  ADD KEY `idx_subbiercategories_subcategoyID_unique` (`subcategoryID`) USING BTREE;

--
-- Indizes für die Tabelle `subcategories`
--
ALTER TABLE `subcategories`
  ADD PRIMARY KEY (`subcategoryID`),
  ADD KEY `categoryID` (`categoryID`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `brands`
--
ALTER TABLE `brands`
  MODIFY `brandID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `categories`
--
ALTER TABLE `categories`
  MODIFY `categoryID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `customers`
--
ALTER TABLE `customers`
  MODIFY `customerID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `devicestatushistory`
--
ALTER TABLE `devicestatushistory`
  MODIFY `statushistoryID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `employee`
--
ALTER TABLE `employee`
  MODIFY `employeeID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `insuranceprovider`
--
ALTER TABLE `insuranceprovider`
  MODIFY `insuranceproviderID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `insurances`
--
ALTER TABLE `insurances`
  MODIFY `insuranceID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `jobCategory`
--
ALTER TABLE `jobCategory`
  MODIFY `jobcategoryID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `jobs`
--
ALTER TABLE `jobs`
  MODIFY `jobID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `maintenanceLogs`
--
ALTER TABLE `maintenanceLogs`
  MODIFY `maintenanceLogID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `manufacturer`
--
ALTER TABLE `manufacturer`
  MODIFY `manufacturerID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `products`
--
ALTER TABLE `products`
  MODIFY `productID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `status`
--
ALTER TABLE `status`
  MODIFY `statusID` int NOT NULL AUTO_INCREMENT;

-- --------------------------------------------------------

--
-- Struktur des Views `device_earnings_summary`
--
DROP TABLE IF EXISTS `device_earnings_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `device_earnings_summary`  AS SELECT `d`.`deviceID` AS `deviceID`, `p`.`name` AS `deviceName`, count(distinct `jd`.`jobID`) AS `numJobs`, round(coalesce(sum((case when (`j`.`discount_type` = 'percent') then (coalesce(`jd`.`custom_price`,(((to_days(`j`.`endDate`) - to_days(`j`.`startDate`)) + 1) * `p`.`itemcostperday`)) * (1 - (`j`.`discount` / 100))) when (`j`.`discount_type` = 'amount') then greatest((coalesce(`jd`.`custom_price`,(((to_days(`j`.`endDate`) - to_days(`j`.`startDate`)) + 1) * `p`.`itemcostperday`)) - (`j`.`discount` / `jd_count`.`device_count`)),0) else coalesce(`jd`.`custom_price`,(((to_days(`j`.`endDate`) - to_days(`j`.`startDate`)) + 1) * `p`.`itemcostperday`)) end)),0),2) AS `totalEarnings` FROM ((((`devices` `d` left join `jobdevices` `jd` on((`d`.`deviceID` = `jd`.`deviceID`))) left join (select `jobdevices`.`jobID` AS `jobID`,count(0) AS `device_count` from `jobdevices` group by `jobdevices`.`jobID`) `jd_count` on((`jd`.`jobID` = `jd_count`.`jobID`))) left join `jobs` `j` on((`jd`.`jobID` = `j`.`jobID`))) left join `products` `p` on((`d`.`productID` = `p`.`productID`))) GROUP BY `d`.`deviceID`, `p`.`name` ;

-- --------------------------------------------------------

--
-- Struktur des Views `product_revenue`
--
DROP TABLE IF EXISTS `product_revenue`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `product_revenue`  AS SELECT `p`.`name` AS `product_name`, sum(`jd`.`custom_price`) AS `total_revenue` FROM (((`jobdevices` `jd` join `devices` `d` on((`jd`.`deviceID` = `d`.`deviceID`))) join `products` `p` on((`d`.`productID` = `p`.`productID`))) join `jobs` `j` on((`jd`.`jobID` = `j`.`jobID`))) GROUP BY `p`.`name` ORDER BY `total_revenue` DESC ;

-- --------------------------------------------------------

--
-- Struktur des Views `view_device_product`
--
DROP TABLE IF EXISTS `view_device_product`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `view_device_product`  AS SELECT `d`.`deviceID` AS `deviceID`, `p`.`name` AS `product_name`, `p`.`productID` AS `productID` FROM (`devices` `d` join `products` `p` on((`d`.`productID` = `p`.`productID`))) ;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `brands`
--
ALTER TABLE `brands`
  ADD CONSTRAINT `brands_ibfk_1` FOREIGN KEY (`manufacturerID`) REFERENCES `manufacturer` (`manufacturerID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints der Tabelle `devices`
--
ALTER TABLE `devices`
  ADD CONSTRAINT `devices_ibfk_1` FOREIGN KEY (`productID`) REFERENCES `products` (`productID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `devices_ibfk_2` FOREIGN KEY (`insuranceID`) REFERENCES `insurances` (`insuranceID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints der Tabelle `employeejob`
--
ALTER TABLE `employeejob`
  ADD CONSTRAINT `employeejob_ibfk_1` FOREIGN KEY (`employeeID`) REFERENCES `employee` (`employeeID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `employeejob_ibfk_2` FOREIGN KEY (`jobID`) REFERENCES `jobs` (`jobID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints der Tabelle `insurances`
--
ALTER TABLE `insurances`
  ADD CONSTRAINT `insurances_ibfk_1` FOREIGN KEY (`insuranceproviderID`) REFERENCES `insuranceprovider` (`insuranceproviderID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints der Tabelle `jobdevices`
--
ALTER TABLE `jobdevices`
  ADD CONSTRAINT `jobdevices_ibfk_2` FOREIGN KEY (`jobID`) REFERENCES `jobs` (`jobID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `jobdevices_ibfk_3` FOREIGN KEY (`deviceID`) REFERENCES `devices` (`deviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints der Tabelle `jobs`
--
ALTER TABLE `jobs`
  ADD CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`customerID`) REFERENCES `customers` (`customerID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `jobs_ibfk_2` FOREIGN KEY (`jobcategoryID`) REFERENCES `jobCategory` (`jobcategoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `jobs_ibfk_3` FOREIGN KEY (`statusID`) REFERENCES `status` (`statusID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints der Tabelle `maintenanceLogs`
--
ALTER TABLE `maintenanceLogs`
  ADD CONSTRAINT `maintenanceLogs_ibfk_2` FOREIGN KEY (`employeeID`) REFERENCES `employee` (`employeeID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints der Tabelle `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`brandID`) REFERENCES `brands` (`brandID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `products_ibfk_2` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `products_ibfk_3` FOREIGN KEY (`manufacturerID`) REFERENCES `manufacturer` (`manufacturerID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `products_ibfk_4` FOREIGN KEY (`subbiercategoryID`) REFERENCES `subbiercategories` (`subbiercategoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `products_ibfk_5` FOREIGN KEY (`subcategoryID`) REFERENCES `subcategories` (`subcategoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints der Tabelle `subbiercategories`
--
ALTER TABLE `subbiercategories`
  ADD CONSTRAINT `subbiercategories_ibfk_1` FOREIGN KEY (`subcategoryID`) REFERENCES `subcategories` (`subcategoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints der Tabelle `subcategories`
--
ALTER TABLE `subcategories`
  ADD CONSTRAINT `subcategories_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
