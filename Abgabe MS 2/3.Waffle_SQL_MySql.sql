-- -----------------------------------------------------
-- KONFIGURATION ANWEISUNG				    
-- -----------------------------------------------------
DROP DATABASE IF EXISTS `WaffleDB`;
CREATE DATABASE IF NOT EXISTS `WaffleDB`;
USE `WaffleDB` ;

SET @@SQL_MODE = CONCAT(@@SQL_MODE, ',PIPES_AS_CONCAT');
SET SQL_SAFE_UPDATES = 0;

-- -----------------------------------------------------
-- DROP ANWEISUNG				    
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Addition`;
DROP TABLE IF EXISTS `Inventory`;
DROP TABLE IF EXISTS `ProductOrder`;
DROP TABLE IF EXISTS `WaffleOrder`;
DROP TABLE IF EXISTS `PersonalNotification`;
DROP TABLE IF EXISTS `WaffleStore`;
DROP TABLE IF EXISTS `WaffleIngredient`;
DROP TABLE IF EXISTS `Waffle`;
DROP TABLE IF EXISTS `Ingredient`;
DROP TABLE IF EXISTS `Product`;
DROP TABLE IF EXISTS `NutritionalInformation`;

DROP VIEW IF EXISTS `WaffleConstruction`;
DROP VIEW IF EXISTS `IngredientOverview`;
DROP VIEW IF EXISTS `PersonalNotificationView`;

-- -----------------------------------------------------
-- Table `NutritionalInformation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `NutritionalInformation` 
(
  `idNuIn` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `calories` FLOAT NULL,
  `saturatedFat` FLOAT NULL,
  `transFat` FLOAT NULL,
  `carbohydrates` FLOAT NULL,
  `sugar` FLOAT NULL,
  `protein` FLOAT NULL,
  `salt` FLOAT NULL
);

-- -----------------------------------------------------
-- Table `Product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Product` 
(
  `idProduct` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `idNuIn` INT NOT NULL,
  `price` FLOAT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  CONSTRAINT `fk_Product_NutritionalInformation1`
    FOREIGN KEY (`idNuIn`)
    REFERENCES `NutritionalInformation` (`idNuIn`)
);

CREATE INDEX `fk_Product_NutritionalInformation1_idx` ON `Product` (`idNuIn` ASC);

-- -----------------------------------------------------
-- Table `Addition`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Addition` 
(
  `idAddition` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `optComment` VARCHAR(255) NULL,
  CONSTRAINT `fk_Addition_Product1`
    FOREIGN KEY (`idAddition`)
    REFERENCES `Product` (`idProduct`)
);

CREATE INDEX `fk_Addition_Product1_idx` ON `Addition` (`idAddition` ASC);

-- -----------------------------------------------------
-- Table `Ingredient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ingredient` 
(
  `idIngredient` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `idNuIn` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `unit` VARCHAR(45) NOT NULL,
  `price` FLOAT NULL,
  `processingTimeSec` INT NOT NULL,
  CONSTRAINT `fk_Ingredient_NutritionalInformation1`
    FOREIGN KEY (`idNuIn`)
    REFERENCES `NutritionalInformation` (`idNuIn`)
);

CREATE INDEX `fk_Ingredient_NutritionalInformation1_idx` ON `Ingredient` (`idNuIn` ASC);

-- -----------------------------------------------------
-- Table `Store`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `WaffleStore` 
(
  `idStore` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(255) NULL,
  `areaCode` VARCHAR(15) NULL,
  `location` VARCHAR(255) NULL,
  `streetName` VARCHAR(255) NULL,
  `houseNumber` VARCHAR(45) NULL
);

-- -----------------------------------------------------
-- Table PersonalNotification
-- -----------------------------------------------------
CREATE TABLE PersonalNotification 
(
  `idNotification` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `idStore` INT NOT NULL,
  `message` VARCHAR(255) NOT NULL,
  `messageReason` VARCHAR(255) NOT NULL,
  `idIngredient` INT NOT NULL,
  `ingredientName` VARCHAR(255) NOT NULL,
  `time` TIMESTAMP,
  CONSTRAINT `fk_PersonalNotification_Store1`
    FOREIGN KEY (`idStore`)
    REFERENCES `PersonalNotification` (`idNotification`)
);

-- -----------------------------------------------------
-- Table `Inventory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Inventory` 
(
  `idInventory` INT NOT NULL,
  `idIngredient` INT NOT NULL,
  `idStore` INT NOT NULL,
  `expiryDate` DATE NULL,
  `deliveryDate` DATE NOT NULL,
  `amount` INT NOT NULL,
  `isAccessible` INT NOT NULL,	
  CONSTRAINT `fk_Inventory_Ingredient`
    FOREIGN KEY (`idIngredient`)
    REFERENCES `Ingredient` (`idIngredient`),
  CONSTRAINT `fk_Inventory_StoreA`
    FOREIGN KEY (`idStore`)
    REFERENCES `WaffleStore` (`idStore`),
  CONSTRAINT pk_Inventory
    PRIMARY KEY (idInventory)
);

CREATE INDEX `fk_Inventory_StoreA_idx` ON `Inventory` (`idStore` ASC);

-- -----------------------------------------------------
-- Table `WaffleOrder`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `WaffleOrder` 
(
  `idOrder` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `idStore` INT NOT NULL,
  `totalAmount` DOUBLE NULL,
  `paymentStatus` INT NOT NULL,
  `orderDate` DATE NOT NULL,
  CONSTRAINT `fk_Order_StoreA`
    FOREIGN KEY (`idStore`)
    REFERENCES `WaffleStore` (`idStore`)
);

CREATE INDEX `fk_Order_StoreA_idx` ON `WaffleOrder` (`idStore` ASC);

-- -----------------------------------------------------
-- Table `ProductOrder`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ProductOrder` 
(
  `idOrder` INT NOT NULL,
  `idProduct` INT NOT NULL,
  `amount` INT NULL,
  `calculatedTime` INT,
  PRIMARY KEY (`idOrder`, `idProduct`),
  CONSTRAINT `fk_ProductOrder_Order1`
    FOREIGN KEY (`idOrder`)
    REFERENCES `WaffleOrder` (`idOrder`),
  CONSTRAINT `fk_ProductOrder_Product1`
    FOREIGN KEY (`idProduct`)
    REFERENCES `Product` (`idProduct`)
);

CREATE INDEX `fk_ProductOrder_Order1_idx` ON `ProductOrder` (`idOrder` ASC);

CREATE INDEX `fk_ProductOrder_Product1_idx` ON `ProductOrder` (`idProduct` ASC);

-- -----------------------------------------------------
-- Table `Waffle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Waffle` 
(
  `idWaffle` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `creatorName` VARCHAR(255) NULL,
  `creationDate` DATE NOT NULL,
  `processingTimeSec` INT,
  `healty` VARCHAR(255),
  CONSTRAINT `fk_Waffle_Product1`
    FOREIGN KEY (`idWaffle`)
    REFERENCES `Product` (`idProduct`)
);

CREATE INDEX `fk_Waffle_Product1_idx` ON `Waffle` (`idWaffle` ASC);

-- -----------------------------------------------------
-- Table `WaffleIngredient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `WaffleIngredient` 
(
  `idIngredient` INT NOT NULL,
  `idWaffle` INT NOT NULL,
  `amount` INT NOT NULL,
  PRIMARY KEY (`idIngredient`, `idWaffle`),
  CONSTRAINT `fk_WaffleRecept_Ingredient1`
    FOREIGN KEY (`idIngredient`)
    REFERENCES `Ingredient` (`idIngredient`),
  CONSTRAINT `fk_WaffleRecept_Waffle1`
    FOREIGN KEY (`idWaffle`)
    REFERENCES `Waffle` (`idWaffle`)
);

CREATE INDEX `fk_WaffleRecept_Ingredient1_idx` ON `WaffleIngredient` (`idIngredient` ASC);

CREATE INDEX `fk_WaffleRecept_Waffle1_idx` ON `WaffleIngredient` (`idWaffle` ASC);

-- -----------------------------------------------------
-- Placeholder table for view `WaffleConstruction`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `WaffleConstruction` (`name` INT, `price` INT, `amount` INT, `unit` INT);

-- -----------------------------------------------------
-- Placeholder table for view `IngredientOverview`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `IngredientOverview` (`name` INT, `sum(Inventory.amount)` INT, `unit` INT);

-- -----------------------------------------------------
-- View `WaffleConstruction`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `WaffleConstruction`;
DROP VIEW IF EXISTS `WaffleConstruction`;
USE `WaffleDB`;

CREATE OR REPLACE VIEW `WaffleConstruction` AS
	SELECT Product.name as `ProductName`, Product.price, Ingredient.name as `IngredientName`, WaffleIngredient.amount, Ingredient.unit FROM Product
	Inner join Waffle on Waffle.idWaffle = Product.idProduct
    Inner join WaffleIngredient on Waffle.idWaffle = WaffleIngredient.idWaffle
	Inner join Ingredient on WaffleIngredient.idIngredient = Ingredient.idIngredient
    order by Product.name;

-- -----------------------------------------------------
-- View `IngredientOverview`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IngredientOverview`;
DROP VIEW IF EXISTS `IngredientOverview`;
USE `WaffleDB`;

CREATE OR REPLACE VIEW `IngredientOverview` AS
	Select Ingredient.name as `IngredientName`, sum(Inventory.amount), Ingredient.unit, WaffleStore.name as `StoreName` from Ingredient
	left join Inventory on Ingredient.idIngredient = Inventory.idIngredient
	inner join WaffleStore on WaffleStore.idStore = Inventory.idStore
	Where Inventory.expiryDate < curdate()
	group by Inventory.idStore, WaffleStore.name
	order by Ingredient.name;
    
 -- -----------------------------------------------------
-- View `PersonalNotification`
-- ----------------------------------------------------- 
DROP VIEW IF EXISTS `PersonalNotificationView`;
USE `WaffleDB`;

CREATE OR REPLACE VIEW `PersonalNotificationView` AS 
	SELECT * FROM PersonalNotification ORDER BY time DESC;

-- -----------------------------------------------------
-- INSERTS
-- -----------------------------------------------------
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (1, 300, 2, 2, 5, 10, 5, 1);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (2, 450, 5, 2, 5, 10, 5, 1);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (3, 500, 10, 10, 10, 10, 10, 10);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (4, 60, 0, 0, 0, 0, 0, 0);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (5, 350, 3, 3, 5, 5, 3, 1);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (6, 250, 3, 3, 5, 5, 3, 1);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (7, 80, 3, 1, 3, 1, 3, 1);

INSERT INTO INGREDIENT (idIngredient, idNuIn, name, unit, price, processingTimeSec)
    VALUES (1, 1, 'Banane', 'g', 0.5, 3);
    
INSERT INTO INGREDIENT (idIngredient, idNuIn, name, unit, price, processingTimeSec)
    VALUES (2, 2, 'Schoko', 'g', 1, 3);
    
INSERT INTO INGREDIENT (idIngredient, idNuIn, name, unit, price, processingTimeSec)
    VALUES (3, 4, 'Apfel', 'g', 0.5, 3);
    
INSERT INTO INGREDIENT (idIngredient, idNuIn, name, unit, price, processingTimeSec)
    VALUES (4, 7, 'Teig', 'g', 0.2, 5);
    
INSERT INTO PRODUCT (idProduct, idNuIn, price, name)
    VALUES (1, 1, 10, 'BananenWaffel');
    
INSERT INTO PRODUCT (idProduct, idNuIn, price, name)
    VALUES (2, 2, 10, 'SchokoWaffel');
    
INSERT INTO PRODUCT (idProduct, idNuIn, price, name)
    VALUES (3, 3, 5, 'MegaSchokoWaffel');
    
INSERT INTO PRODUCT (idProduct, idNuIn, price, name)
    VALUES (4, 5, 3.5, 'ApfelWaffel');
    
INSERT INTO PRODUCT (idProduct, idNuIn, price, name)
    VALUES (5, 6, 2, 'Waffel Ohne Alles');
    
INSERT INTO WAFFLE (idWaffle, creatorName, creationDate, processingTimeSec, healty)
    VALUES (1, 'Gustav', '2020-12-01', NULL, NULL);
    
INSERT INTO WAFFLE (idWaffle, creatorName, creationDate, processingTimeSec, healty)
    VALUES (2, 'Gustav', '2020-12-01', NULL, NULL);
    
INSERT INTO WAFFLE (idWaffle, creatorName, creationDate, processingTimeSec, healty)
    VALUES (3, 'Gustav', '2020-12-01', NULL, NULL);
    
INSERT INTO WAFFLE (idWaffle, creatorName, creationDate, processingTimeSec, healty)
    VALUES (4, 'Berndt', '2020-12-01', NULL, NULL);

INSERT INTO WAFFLE (idWaffle, creatorName, creationDate, processingTimeSec, healty)
    VALUES (5, 'Berndt', '2020-12-01', NULL, NULL);

INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (1, 1, 10);
    
INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (2, 2, 5);   
    
INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (3, 3, 5); 
    
INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (3, 4, 2); 
    
INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (4, 5, 1); 

INSERT INTO WaffleStore (idStore, name, areaCode, location, streetName, houseNumber)
    VALUES (1, 'Waffle GMBH', '58540', 'Meinerzhagen', 'Oststraße', '38');
    
INSERT INTO INVENTORY(idInventory, idIngredient, idStore, expiryDate, deliveryDate, amount, isAccessible)
    VALUES (1, 1, 1, '3032-12-30', '3030-12-30', 10, 1);   
    
INSERT INTO INVENTORY(idInventory, idIngredient, idStore, expiryDate, deliveryDate, amount, isAccessible)
    VALUES (2, 3, 1, '3032-12-30', '3032-12-30', 100, 1);  
    
INSERT INTO INVENTORY(idInventory, idIngredient, idStore, expiryDate, deliveryDate, amount, isAccessible)
    VALUES (3, 4, 1, '3032-12-30', '3032-12-30', 100, 1);  
    
INSERT INTO WaffleOrder(idOrder, idStore, totalAmount, paymentStatus, orderDate)
    VALUES (1, 1, 2, 0, '2020-12-30');
    
INSERT INTO WaffleOrder(idOrder, idStore, totalAmount, paymentStatus, orderDate)
    VALUES (2, 1, 2, 0, '2020-12-30');

-- -----------------------------------------------------
-- Prozeduren
-- -----------------------------------------------------
-- ---------------------------------------
-- Erste Prozedur: Benachrichtigen 
-- ---------------------------------------
DROP PROCEDURE IF EXISTS `NotifyPersonal`;
DELIMITER //

CREATE PROCEDURE `NotifyPersonal` (s_reason VARCHAR(255), s_ingredient INT, s_store INT)
BEGIN 
	DECLARE v_message VARCHAR(255);
    DECLARE v_name VARCHAR(255);
    DECLARE v_Ingredient_name VARCHAR(255);
    DECLARE v_max_p_notification_id INT;
    
	SELECT w.name INTO v_name FROM WaffleStore w WHERE idStore = s_store;
    SELECT name INTO v_Ingredient_name FROM INGREDIENT i WHERE i.idingredient = s_ingredient;
    
    SELECT (IFNULL(MAX(idNotification) + 1, 1)) INTO v_max_p_notification_id FROM PERSONALNOTIFICATION;
    
	CASE s_reason
        WHEN 'niedrig' THEN SET v_message = 'Angestellte des Geschäfts ' || v_name ||'. Bitte '|| v_Ingredient_name ||' nachbestellen';
        WHEN 'abgelaufen' THEN SET v_message = 'Angestellte des Geschäfts ' || v_name ||'. Bitte ' ||''|| v_Ingredient_name ||' entsorgen';
        WHEN 'gesperrt' THEN SET v_message = 'Angestellte des Geschäfts ' || v_name || ', ' || v_Ingredient_name || ' ist bis auf weiteres gesperrt';
    END CASE;
    
    INSERT INTO PersonalNotification (idNotification, idStore, message, messageReason, idIngredient, ingredientName, time)
        VALUES (v_max_p_notification_id, s_store, v_message, s_reason, s_ingredient, v_Ingredient_name, SYSDATE());
END //

DELIMITER ;

-- ---------------------------------------
-- Zweite Prozedur: Lager aktualisieren
-- ---------------------------------------
DROP PROCEDURE IF EXISTS `InventoryUpdate`;
DELIMITER //

CREATE PROCEDURE `InventoryUpdate` (
	in_idStore INT,
    in_idIngredient INT,
    ingredientAmount INT,
    calcModeString VARCHAR(255), -- add or sub
    
    expiryDateOnInsert DATE,
    deliveryDateOnInsert DATE
)
BEGIN 
    DECLARE v_hasIngreadient BOOLEAN;
    DECLARE v_amountOfIngreadients INT;
    DECLARE v_ingreadientsSearchResults INT;
    
    DECLARE v_max_idIngredient INT;
    
    DECLARE v_currentIngredientAmount INT;
    DECLARE v_deleteID INT;
    DECLARE v_deleteAmount INT;
    
	-- Check if this ingridient already exists --
    SELECT count(*) INTO v_ingreadientsSearchResults FROM INGREDIENT WHERE INGREDIENT.idIngredient = in_idIngredient;
    SET v_hasIngreadient = v_ingreadientsSearchResults > 0;
    
    -- Count ingredient Amount --
    SELECT sum(amount) INTO v_amountOfIngreadients
    FROM INVENTORY
    WHERE 
    (
        inventory.idingredient = in_idIngredient
        AND
        inventory.idstore = in_idStore  
        AND
        INVENTORY.expirydate >= sysDate() 
    ); 
       
    -- Select Mode --   
    IF  calcModeString like 'add' THEN
		IF v_hasIngreadient THEN    
			-- Add new ingreadient --
            Select MAX(idInventory) from INVENTORY INTO v_max_idIngredient;
            SET v_max_idIngredient = v_max_idIngredient + 1;
            
			INSERT INTO INVENTORY 
			(
				idInventory,
				idIngredient,
				idStore,
				expirydate,                    
				deliverydate, 
				amount,
				isaccessible
			)
			VALUES
			(
				v_max_idIngredient,
				in_idIngredient,
				in_idStore,
				expiryDateOnInsert,
				deliveryDateOnInsert,
				ingredientAmount,
				1
			);
         ELSE 
			-- There is no Ingreadient, we can't add it--
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No Ingredient With That Name'; 
        END IF;
     ELSEIF calcModeString like 'sub' THEN 
     
		IF v_hasIngreadient THEN -- TRUE
			IF v_amountOfIngreadients = ingredientAmount THEN -- TRUE
				-- We take the same amount of what is left -
				DELETE FROM INVENTORY                    
				WHERE 
				(   
					inventory.idingredient = in_idIngredient
					AND
					inventory.idstore = in_idStore
				);
				-- ---------------------------------------------------------     
			ELSEIF ingredientAmount < ingredientAmount THEN
				-- There are not enogh. Throw exeption. --------------------
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not Enogh Ingredients';                   
			ELSE                    
				-- There are enough the take. -------------------------------    
				SET v_currentIngredientAmount = ingredientAmount;
		
				WHILE v_currentIngredientAmount > 0 DO
                                            
					SELECT idinventory INTO v_deleteID FROM inventory
					WHERE 
					(
						inventory.idingredient = in_idIngredient
						AND
						inventory.idstore = in_idStore 
						AND
						INVENTORY.expirydate >= CURRENT_TIMESTAMP
					)
					LIMIT 1;                    
                        
					-- Get amount
					SELECT amount INTO v_deleteAmount FROM inventory
					WHERE inventory.idinventory = v_deleteID;
                        
					IF v_deleteAmount > v_currentIngredientAmount THEN
						-- Reduce amount
						UPDATE inventory SET amount = v_deleteAmount - v_currentIngredientAmount
							WHERE inventory.idinventory = v_deleteID;
					ELSE
						Delete from inventory 
                            WHERE inventory.idinventory = v_deleteID;
					END IF;
                        
					-- Reduce
					SET v_currentIngredientAmount = v_currentIngredientAmount - v_deleteAmount;                        
				END WHILE;                                
			END IF;                
		ELSE
			-- ERROR - ingredient does not exist!
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No Ingredient With That Name'; 
           END IF;            
	ELSE                
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid Mode'; 
     END IF;        
END //

DELIMITER ;

-- ---------------------------------------
-- Dritte Prozedur: Lager aktualisieren und Ingredient hinzufügen
-- ---------------------------------------
DROP PROCEDURE IF EXISTS `OnInventoryAdd`;
DELIMITER //

CREATE PROCEDURE `OnInventoryAdd` (
    s_idProduct INT,
    s_idOrder INT,
    s_extenal_amount INT
)
BEGIN 
	DECLARE loop_counter INT DEFAULT s_extenal_amount;
    DECLARE done1, done2 BOOLEAN DEFAULT FALSE;
    
    DECLARE v_store INT;
    DECLARE v_waffle_id INT;
    
    DECLARE v_operator VARCHAR(3) DEFAULT 'add';
    
    DECLARE v_cursor_ingredientid INT;
    DECLARE v_cursor_amount INT;
    
    DECLARE v_cursor_expiryDate DATE;
    DECLARE v_cursor_deliveryDate DATE;
    
    DECLARE v_Ingredient_Cursor_On_Insert CURSOR FOR
        SELECT idIngredient, amount FROM WAFFLEINGREDIENT WHERE idWaffle = v_waffle_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;
    
    SELECT idStore INTO v_store FROM WAFFLEORDER WHERE idOrder = s_idOrder;
    SELECT idWaffle INTO v_waffle_id FROM Waffle WHERE idWaffle = s_idProduct;

	REPEAT
       OPEN v_Ingredient_Cursor_On_Insert;
       loop1 : LOOP
          FETCH FROM v_Ingredient_Cursor_On_Insert INTO v_cursor_ingredientId, v_cursor_amount;
          
          IF done1 THEN
             CLOSE v_Ingredient_Cursor_On_Insert;
             LEAVE loop1;
		  END IF;
          
          BLOCK1 : BEGIN
          
            DECLARE v_Ingredient_Cursor_On_Delete CURSOR FOR
					SELECT expiryDate, deliveryDate FROM Inventory WHERE idIngredient = v_cursor_ingredientid;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;
            
            OPEN v_Ingredient_Cursor_On_Delete;
            loop2 : LOOP
               FETCH FROM v_Ingredient_Cursor_On_Delete INTO v_cursor_expiryDate, v_cursor_deliveryDate;
               
               IF done2 THEN
                  SET done2 = FALSE;
                  LEAVE loop2;
			   END IF;
               
            END LOOP loop2;
		 END BLOCK1;
	   END LOOP loop1;
       CALL InventoryUpdate(v_store, v_cursor_ingredientId, v_cursor_amount, v_operator, v_cursor_expiryDate, v_cursor_deliveryDate);
       SET loop_counter = loop_counter - 1;
    UNTIL loop_counter = 0
    END REPEAT;

END //

DELIMITER ;

-- ---------------------------------------
-- Vierte Prozedur: Lager aktualisieren und Ingredient rausnehmen
-- ---------------------------------------
DROP PROCEDURE IF EXISTS `OnInventoryDelete`;
DELIMITER //

CREATE PROCEDURE `OnInventoryDelete`(
    s_idProduct INT,
    s_idOrder INT,
    s_extenal_amount INT
)
BEGIN
    DECLARE loop_counter INT DEFAULT s_extenal_amount;
    DECLARE max_row INT DEFAULT 0;
    
    DECLARE v_store INT;
    DECLARE v_waffle_id INT;
    
    DECLARE v_cursor_ingredientid INT;
    DECLARE v_cursor_amount INT;
    
    DECLARE v_operator VARCHAR(3) DEFAULT 'sub';
    
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE v_Ingredient_Cursor_On_Insert CURSOR FOR SELECT idIngredient, amount FROM WAFFLEINGREDIENT WHERE idWaffle = v_waffle_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT idStore INTO v_store FROM WAFFLEORDER WHERE idOrder = s_idOrder;
    SELECT idWaffle INTO v_waffle_id FROM Waffle WHERE idWaffle = s_idProduct;
    
    REPEAT
	OPEN v_Ingredient_Cursor_On_Insert;
		cursor_loop : LOOP
        FETCH v_Ingredient_Cursor_On_Insert INTO v_cursor_ingredientId, v_cursor_amount;
            
        IF done THEN 
           LEAVE cursor_loop; 
        END IF;
            
        END LOOP;
	CLOSE v_Ingredient_Cursor_On_Insert;

	SET loop_counter = loop_counter - 1;
    CALL InventoryUpdate(v_store, v_cursor_ingredientId, v_cursor_amount, v_operator, NULL, NULL); 
    UNTIL loop_counter = 0 
    END REPEAT;
  
END //

DELIMITER ;

-- -----------------------------------------------------
-- Funktionen
-- -----------------------------------------------------

-- ---------------------------------------
-- Erste Funktion: Preiswertrechner 	--
-- ---------------------------------------
DROP FUNCTION IF EXISTS `GrossNetCalculator`;
DELIMITER //

CREATE FUNCTION GrossNetCalculator(bruttoPreis FLOAT, mwst FLOAT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE Ergebnis FLOAT;
    DECLARE myMwst FLOAT;
    
    SET myMwst = IFNULL(mwst, 0.19);
    SET Ergebnis = bruttoPreis * (1 + myMwst);
    
    Return Ergebnis;
END //

DELIMITER ;

-- ---------------------------------------
-- Zweite Funktion: Nährwertrechner 	--
-- ---------------------------------------
DROP FUNCTION IF EXISTS `NutritionCalculator`;
DELIMITER //

CREATE FUNCTION NutritionCalculator(in_idNui INT)
RETURNS VARCHAR(64)
DETERMINISTIC
BEGIN
    DECLARE v_calories FLOAT;
    DECLARE v_saturatedFat FLOAT;
    DECLARE v_transFat FLOAT;
    DECLARE v_carbohydrates FLOAT;
    DECLARE v_sugar FLOAT;
    DECLARE v_protein FLOAT;
    DECLARE v_salt FLOAT;
    
    DECLARE myHealtyCalories FLOAT DEFAULT 350;
    DECLARE myHealtySugar FLOAT DEFAULT 10;
    DECLARE Ergebnis VARCHAR(64);
    
    SELECT CALORIES, SATURATEDFAT, TRANSFAT, CARBOHYDRATES, SUGAR, PROTEIN, SALT 
    INTO  v_calories, v_saturatedFat, v_transFat, v_carbohydrates, v_sugar, v_protein, v_salt 
    FROM NutritionalInformation WHERE idNuIn = in_idNui;
    
    IF (v_calories > myHealtyCalories) OR (v_sugar > myHealtySugar) THEN
       IF (v_transFat > 3) OR (v_saturatedFat > 15) OR (v_sugar > 10) THEN
            SET Ergebnis = 'Ungesund';
       ELSE 
            SET Ergebnis = 'Mäßig Gesund';
       END IF;
	ELSE
	   SET Ergebnis = 'Gesund';
    END IF;
    
    Return Ergebnis;
END //

DELIMITER ;

-- ---------------------------------------
-- Dritte Funktion: Bestellzeitaufwand 	--
-- ---------------------------------------
DROP FUNCTION IF EXISTS `OrderTimeCalculator`;
DELIMITER //

CREATE FUNCTION `OrderTimeCalculator`(in_idWaffle INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE i_waffletime_in_s INT DEFAULT 0;

    SELECT SUM(ing.processingTimeSec * wi.amount) INTO i_waffletime_in_s FROM WaffleIngredient wi, Ingredient ing
    WHERE wi.idWaffle = in_idwaffle AND ing.idIngredient = wi.idIngredient;
    
    RETURN i_waffletime_in_s;
END //

DELIMITER ;

-- -----------------------------------------------------
-- Trigger
-- -----------------------------------------------------

-- ---------------------------------------
-- Erster Trigger: Bestandsänderung 	--
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnInventoryUpdate`;
DELIMITER //

CREATE TRIGGER `OnInventoryUpdate`
BEFORE UPDATE ON Inventory
FOR EACH ROW
BEGIN
    DECLARE id INT DEFAULT New.idIngredient;
    DECLARE store INT DEFAULT New.idStore;
    
    IF New.Amount <> Old.Amount THEN
       IF New.Amount < 2 THEN
           SET New.isAccessible = 0;
           CALL NotifyPersonal('gesperrt', id, store);
       ELSEIF New.Amount < 5 THEN
           CALL NotifyPersonal('niedrig', id, store);
       ELSEIF New.Amount > 5 THEN
           SET New.isAccessible = 1;
       END IF;
    END IF;
END //

DELIMITER ;

-- ---------------------------------------
-- Zweiter Trigger: Bestellung erhalten Insert --
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnProductOrderInsert`;
DELIMITER //

CREATE TRIGGER `OnProductOrderInsert`
BEFORE INSERT ON PRODUCTORDER
FOR EACH ROW
BEGIN
     DECLARE v_processingTime FLOAT;
     DECLARE v_calculatedTime FLOAT;
     
     SELECT processingTimeSec INTO v_processingTime FROM WAFFLE WHERE idWaffle = NEW.idProduct;
     
     SET v_calculatedTime = New.Amount * IFNULL(v_processingTime, 100);
     SET New.CalculatedTime = v_calculatedTime;
     
     
     CALL OnInventoryDelete(NEW.idProduct, NEW.idOrder, NEW.Amount);
END //

DELIMITER ;

-- ---------------------------------------
-- Dritter Trigger: Bestellung erhalten Update --
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnProductOrderUpdate`;
DELIMITER //

CREATE TRIGGER `OnProductOrderUpdate`
BEFORE UPDATE ON PRODUCTORDER
FOR EACH ROW
BEGIN
     DECLARE v_amount_difference FLOAT DEFAULT Old.Amount - New.Amount;
     
     IF v_amount_difference < 0 THEN
        CALL OnInventoryDelete(Old.idProduct, Old.idOrder, ABS(v_amount_difference));
     ELSEIF v_amount_difference < 0 THEN
        CALL OnInventoryAdd(Old.idProduct, Old.idOrder, v_amount_difference);
     END IF;
END //

DELIMITER ;

-- ---------------------------------------
-- Vierter Trigger: Bestellung erhalten Delete --
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnProductOrderDelete`;
DELIMITER //

CREATE TRIGGER `OnProductOrderDelete`
BEFORE DELETE ON PRODUCTORDER
FOR EACH ROW
BEGIN
   CALL OnInventoryAdd(Old.idProduct, Old.idOrder, Old.Amount);
END //

DELIMITER ;

-- ---------------------------------------
-- Fünfter Trigger: Bestellung abges.   --
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnFinishOrder`;
DELIMITER //

CREATE TRIGGER `OnFinishOrder`
BEFORE UPDATE ON WAFFLEORDER
FOR EACH ROW
BEGIN
    DECLARE v1 INT DEFAULT 0;
    
    IF (New.paymentStatus = 1) THEN
	   SELECT SUM(product.price * productorder.amount) INTO v1
       FROM productorder
       inner join product on productorder.idproduct = product.idproduct
       WHERE IDORDER = NEW.idOrder
       GROUP BY productorder.idorder;
       
       SET NEW.totalamount = v1;
    END IF;
END //

DELIMITER ;

-- ---------------------------------------
-- Sechster Trigger: Lebensmittel abgel. Insert --
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnInventoryUpdateInsert`;
DELIMITER //

CREATE TRIGGER `OnInventoryUpdateInsert`
BEFORE INSERT ON INVENTORY
FOR EACH ROW
BEGIN
     DECLARE id INT DEFAULT New.idIngredient;
     DECLARE store INT DEFAULT New.idStore;
     
     IF New.ExpiryDate < sysdate() THEN
          CALL NotifyPersonal('abgelaufen', id, store);
	 END IF;
END //

DELIMITER ;

-- ---------------------------------------
-- Siebter Trigger: Lebensmittel abgel. Update --
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnInventoryUpdateUpdate`;
DELIMITER //

CREATE TRIGGER `OnInventoryUpdateUpdate`
BEFORE UPDATE ON INVENTORY
FOR EACH ROW
BEGIN
     DECLARE id INT DEFAULT New.idIngredient;
     DECLARE store INT DEFAULT New.idStore;
     
     IF New.ExpiryDate < sysdate() THEN
          CALL NotifyPersonal('abgelaufen', id, store);
	 END IF;
END //

DELIMITER ;

-- ---------------------------------------
-- Achter Trigger: Zutat hinzug. / Update Update
-- ---------------------------------------
DROP TRIGGER IF EXISTS IngredientChanged;
DELIMITER // 

CREATE TRIGGER IngredientChanged
AFTER UPDATE ON INGREDIENT 
for each row 
BEGIN
    DECLARE v_oldPrice FLOAT;
    DECLARE v_newPrice FLOAT;
    DECLARE v_cursorID FLOAT;
    DECLARE v_cursorAmount FLOAT;

    DECLARE DONE1 BOOLEAN DEFAULT FALSE;
    DECLARE v_ingredientID FLOAT DEFAULT NEW.idIngredient ; 

    DECLARE v_waffleToChange CURSOR FOR 
        SELECT idWaffle, amount 
        FROM waffleingredient
        WHERE idingredient = v_ingredientID;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;

    OPEN v_waffleToChange;
    loop1 : LOOP
        FETCH FROM v_waffleToChange INTO v_CursorID, v_cursorAmount;

        IF DONE1 THEN
            LEAVE loop1;
        END IF;

        SET v_oldPrice = OLD.price * v_CursorAmount;
        SET v_newPrice = NEW.price * v_CursorAmount;

        UPDATE PRODUCT 
        SET price = (price - v_oldPrice) + v_newPrice
        where idproduct = v_CursorID;

    END LOOP loop1;
    CLOSE v_waffleToChange;

END //
DELIMITER ;


-- ---------------------------------------
-- Neunter Trigger: Waffel hinzug. / Update Insert
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnWaffleInsert`;
DELIMITER //

CREATE TRIGGER `OnWaffleInsert`
BEFORE INSERT ON WAFFLE
FOR EACH ROW
BEGIN
    DECLARE v_processingTime FLOAT DEFAULT OrderTimeCalculator(New.idWaffle);
    DECLARE v_idNuIn INT;
    DECLARE v_nutrition VARCHAR(64);
    
    SELECT idNuIn INTO v_idNuIn FROM PRODUCT WHERE idProduct = New.IdWaffle;
    
    SET v_nutrition = NutritionCalculator(v_idNuIn);

    SET New.creationDate = SYSDATE();
    SET New.processingTimeSec = IFNULL(v_processingTime, 100);
    SET New.healty = IFNULL(v_nutrition, 'Mäßig Gesund');
END //

DELIMITER ;

-- ---------------------------------------
-- Zehnter Trigger: Waffel hinzug. / Update Update
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnWaffleUpdate`;
DELIMITER //

CREATE TRIGGER `OnWaffleUpdate`
BEFORE INSERT ON WAFFLE
FOR EACH ROW
BEGIN
    DECLARE v_processingTime FLOAT DEFAULT OrderTimeCalculator(New.idWaffle);
    DECLARE v_idNuIn INT;
    DECLARE v_nutrition VARCHAR(64);
    
    SELECT idNuIn INTO v_idNuIn FROM PRODUCT WHERE idProduct = New.IdWaffle;
    
    SET v_nutrition = NutritionCalculator(v_idNuIn);

    SET New.creationDate = SYSDATE();
    SET New.processingTimeSec = IFNULL(v_processingTime, 100);
    SET New.healty = IFNULL(v_nutrition, 'Mäßig Gesund');
END //

DELIMITER ;